import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/home_auto_generation_controller.dart';
import 'package:naiapp/application/home/home_character_controller.dart';
import 'package:naiapp/application/home/home_generation_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/gen/diffusion_model.dart' as df;
import '../../domain/gen/i_novelAI_repository.dart';
import '../core/skeleton_controller.dart';

class HomePageController extends SkeletonController {
  HomeImageController homeImageController = Get.find<HomeImageController>();
  HomeSettingController homeSettingController =
      Get.find<HomeSettingController>();
  RxBool expandHistory = false.obs;

  RxMap<String, bool> loadImageOptions = {
    "긍정 프롬프트": true,
    "부정 프롬프트": true,
    "캐릭터": true,
    '세팅': true,
    'Vibe': false,
    '시드': false
  }.obs;

  final isPanelExpanded = true.obs; // 초기 상태 - 펼쳐진 상태

// HomePageController에 추가할 함수들

// 64의 배수로 변환하는 함수

  @override
  void onClose() {
    super.onClose();
  }

  final SharedPreferences prefs = Get.find<SharedPreferences>();

  Future<void> getPrevSettings() async {
    final raw = prefs.getString("lastSettings");
    if (raw != null) {
      final data = jsonDecode(raw);
      try {
        final setting = df.DiffusionModel.fromJson(data);
        loadSetting(setting);
      } catch (e) {
        print('Error loading last settings: $e');
      }
    }
  }

  @override
  Future<bool> initLoading() async {
    // 포그라운드 서비스에서 건너뛰기 플래그가 설정되어 있으면 초기화 건너뛰기
    final skipInit = prefs.getBool('skip_init_loading') ?? false;
    if (skipInit) {
      await prefs.setBool('skip_init_loading', false); // 플래그 리셋
      print('포그라운드 서비스로부터 복귀 - initLoading 건너뛰기');
      return true;
    }
    
    // 또는 autoGenerate가 이미 활성화되어 있으면 건너뛰기
    if (Get.find<HomeAutoGenerationController>().autoGenerateEnabled.value) {
      print('autoGenerate 이미 활성화됨 - initLoading 건너뛰기');
      return true;
    }

    print('정상적인 initLoading 수행');
    await getPrevSettings(); // This loads the last settings and applies them.

    if (prefs.getString("NOVEL_AI_ACCESS_KEY") == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.toLogin();
      });
      return false; // Stop loading if not logged in
    }

    await Get.find<HomeGenerationController>().getAnlasRemaining();
    return true;
  }

  void logout() {
    prefs.remove("NOVEL_AI_ACCESS_KEY");
    prefs.remove("NOVEL_AI_PERSISTENT_TOKEN");
    router.toLogin();
  }

  void onGridTap() {
    Get.snackbar(
      '알림',
      '이미지 뷰어 모드로 변경합니다.\n이미지 수에 따라 로딩이 길어질 수 있습니다.',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    router.toImage();
    Get.isDialogOpen ?? Get.back();
  }

  RxBool floatingButtonExpanded = false.obs;

  void loadFromImage() {
    final homeImageController = Get.find<HomeImageController>();
    if (homeImageController.loadedImageBytes.value.isEmpty) {
      Get.snackbar('오류', '이미지를 불러오지 못했습니다.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (homeImageController.loadedImageModel == null) {
      Get.snackbar('오류', '메타데이터를 불러오지 못했습니다.',
          backgroundColor: Colors.red, colorText: Colors.white);
      homeImageController.checkImageMetadata(homeImageController.loadedImageBytes.value);
      return;
    }

    final generationController = Get.find<HomeGenerationController>();
    final characterController = Get.find<HomeCharacterController>();
    final loadedImageModel = homeImageController.loadedImageModel!;

    // 선택된 내용만 적용하기
    if (loadImageOptions['긍정 프롬프트']!) {
      generationController.positivePromptController.text = loadedImageModel.input;
    }

    if (loadImageOptions['부정 프롬프트']!) {
      generationController.negativePromptController.text =
          loadedImageModel.parameters.v4_negative_prompt.caption.base_caption;
    }

    if (loadImageOptions['세팅']!) {
      // 세팅 관련 값 적용
      generationController.usingModel.value = loadedImageModel.model;
      homeSettingController.samplingSteps.value =
          loadedImageModel.parameters.steps;

      homeSettingController.setSettings(loadedImageModel);

      // 노이즈 스케줄 설정
      generationController.selectedNoiseSchedule.value =
          generationController.noiseScheduleOptions.contains(loadedImageModel.parameters.noise_schedule)
              ? loadedImageModel.parameters.noise_schedule
              : generationController.noiseScheduleOptions.first;
    }

    if (loadImageOptions['캐릭터']!) {
      // 캐릭터 프롬프트 적용
      characterController.characterPrompts.clear();
      for (var i = 0;
          i < loadedImageModel.parameters.characterPrompts.length;
          i++) {
        characterController.characterPrompts.add({
          'prompt': loadedImageModel.parameters.characterPrompts[i],
          'positive': TextEditingController(
              text: loadedImageModel.parameters.characterPrompts[i].prompt),
          'negative': TextEditingController(
              text: loadedImageModel.parameters.characterPrompts[i].uc),
        });
      }
      Get.back();
    }

    if (loadImageOptions['Vibe']!) {
      homeImageController.loadVibeFromExif(loadedImageModel);
    }

    if (loadImageOptions['시드']!) {
      // 시드 및 랜덤 여부 적용
      homeSettingController.randomSeed.value =
          loadedImageModel.parameters.seed == 999999999;
      homeSettingController.seedController.text =
          homeSettingController.randomSeed.value
              ? ""
              : loadedImageModel.parameters.seed.toString();
    }

    Get.back();
    Get.snackbar('성공', '이미지에서 선택한 설정을 불러왔습니다!',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  void loadFromHistory(int index) {
    if (index < 0 || index >= homeImageController.generationHistory.length)
      return;
    final item = homeImageController.generationHistory[index];
    homeImageController.generatedImagePath.value = item.imagePath;

    // 캐시에 있으면 캐시에서 불러오기
    if (homeImageController.imageCache.containsKey(item.imagePath)) {
      homeImageController.generatedImageBytes.value =
          homeImageController.imageCache[item.imagePath]!;
    } else {
      // 없으면 다시 디코딩
      homeImageController.generatedImageBytes.value =
          base64Decode(item.imagePath);
      // 캐시에 저장
      homeImageController.imageCache[item.imagePath] =
          homeImageController.generatedImageBytes.value;
    }

    Get.find<HomeGenerationController>().positivePromptController.text = item.prompt;
    Get.find<HomeGenerationController>().negativePromptController.text = "";
  }

  void loadSetting(df.DiffusionModel setting) {
    final generationController = Get.find<HomeGenerationController>();
    final characterController = Get.find<HomeCharacterController>();

    generationController.positivePromptController.text = setting.input;
    generationController.negativePromptController.text =
        setting.parameters.v4_negative_prompt.caption.base_caption;
    generationController.usingModel.value = setting.model;

    homeSettingController.randomSeed.value =
        setting.parameters.seed == 999999999;
    homeSettingController.seedController.text =
        homeSettingController.randomSeed.value
            ? ""
            : setting.parameters.seed.toString();

    generationController.selectedNoiseSchedule.value =
        generationController.noiseScheduleOptions.contains(setting.parameters.noise_schedule)
            ? setting.parameters.noise_schedule
            : generationController.noiseScheduleOptions.first;

    generationController.addQualityTags = prefs.getBool("addQualityTags") ?? false;

    homeSettingController.setSettings(setting);
    homeImageController.loadVibeFromExif(setting);

    characterController.characterPrompts.clear();
    for (var i = 0; i < setting.parameters.characterPrompts.length; i++) {
      characterController.characterPrompts.add({
        'prompt': setting.parameters.characterPrompts[i],
        'positive': TextEditingController(
            text: setting.parameters.characterPrompts[i].prompt),
        'negative': TextEditingController(
            text: setting.parameters.characterPrompts[i].uc),
      });
    }
  }

  void loadPreset(String presetName) {
    final setting = homeSettingController.loadPreset(presetName);
    if (setting == null) {
      Get.snackbar('오류', '프리셋을 불러오는 중 오류가 발생했습니다.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    loadSetting(setting);
    Get.snackbar('성공', '프리셋이 불러와졌습니다: $presetName',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  void savePreset(String presetName) {
    if (presetName.isEmpty) {
      Get.snackbar('오류', '프리셋 이름을 입력해주세요.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    final setting = Get.find<HomeGenerationController>().buildSetting();
    homeSettingController.savePreset(presetName, setting);
    Get.snackbar('성공', '프리셋이 저장되었습니다: $presetName',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

// 해상도 값 안전하게 파싱하는 헬퍼 함수
}
