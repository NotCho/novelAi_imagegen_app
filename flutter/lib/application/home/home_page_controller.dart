import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/auto_generation_controller.dart';
import 'package:naiapp/application/home/director_tool_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';
import 'package:naiapp/application/home/image_generation_controller.dart';
import 'package:naiapp/application/home/image_load_controller.dart';
import 'package:naiapp/application/home/model_config_controller.dart';
import 'package:naiapp/application/home/prompt_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/gen/diffusion_model.dart' as df;
import '../../domain/gen/i_novelAI_repository.dart';
import '../core/skeleton_controller.dart';
import '../../view/core/util/app_snackbar.dart';

class HomePageController extends SkeletonController {
  late final HomeImageController homeImageController = Get.find<HomeImageController>();
  late final HomeSettingController homeSettingController = Get.find<HomeSettingController>();
  late final AutoGenerationController autoGenerationController = Get.find<AutoGenerationController>();
  late final DirectorToolController directorToolController = Get.find<DirectorToolController>();
  late final PromptController promptController = Get.find<PromptController>();
  late final ModelConfigController modelConfigController = Get.find<ModelConfigController>();
  late final ImageGenerationController imageGenerationController = Get.find<ImageGenerationController>();
  late final ImageLoadController imageLoadController = Get.find<ImageLoadController>();

  final INovelAIRepository _novelAIRepository = Get.find<INovelAIRepository>();
  final SharedPreferences prefs = Get.find<SharedPreferences>();

  RxBool expandHistory = false.obs;
  final isPanelExpanded = true.obs; 
  RxBool floatingButtonExpanded = false.obs;
  final hideSeed = false.obs;

  Future<void> setHideSeed(bool value) async {
    hideSeed.value = value;
    await prefs.setBool("hideSeed", value);
  }

  @override
  Future<bool> initLoading() async {
    hideSeed.value = prefs.getBool("hideSeed") ?? false;
    final raw = prefs.getString("lastSettings");
    if (raw != null) {
      Map<String, dynamic> data = jsonDecode(raw);
      try {
        final setting = df.DiffusionModel.fromJson(data);
        promptController.positivePromptController.text = setting.input;
        promptController.negativePromptController.text =
            setting.parameters.v4_negative_prompt.caption.base_caption;
        modelConfigController.setModel(setting.model);
        homeSettingController.randomSeed.value =
            setting.parameters.seed == 999999999;
        
        modelConfigController.selectedNoiseSchedule.value =
            modelConfigController.noiseScheduleOptions.contains(setting.parameters.noise_schedule)
                ? setting.parameters.noise_schedule
                : modelConfigController.noiseScheduleOptions.first;
                
        homeSettingController.seedController.text =
            homeSettingController.randomSeed.value
                ? ""
                : setting.parameters.seed.toString();
                
        imageGenerationController.setAutoSave(prefs.getBool("addQualityTags") ?? false);
        homeSettingController.setSettings(setting);

        if (modelConfigController.modelSupportsVibeTransfer(setting.model)) {
          homeImageController.loadVibeFromExif(setting);
        }

        promptController.characterPrompts.clear();
        for (var i = 0; i < setting.parameters.characterPrompts.length; i++) {
          promptController.characterPrompts.add({
            'prompt': setting.parameters.characterPrompts[i],
            'positive': TextEditingController(
                text: setting.parameters.characterPrompts[i].prompt),
            'negative': TextEditingController(
                text: setting.parameters.characterPrompts[i].uc),
          });
        }
      } catch (e) {}
    }
    
    final persistentToken = prefs.getString("NOVEL_AI_PERSISTENT_TOKEN");
    if (persistentToken == null || persistentToken.isEmpty) {
      final accessKey = prefs.getString("NOVEL_AI_ACCESS_KEY");
      if (accessKey != null && accessKey.isNotEmpty) {
        final tokenResult = await _novelAIRepository.createPersistentToken();
        final shouldGoLogin = tokenResult.fold(
          (l) {
            print('토큰 생성 중 오류가 발생했습니다: $l');
            return true;
          },
          (r) {
            print('토큰 생성 성공: $r');
            return false;
          },
        );
        if (shouldGoLogin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            router.toLogin();
          });
          return true;
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.toLogin();
        });
        return true;
      }
    }

    homeSettingController.loadPresets();
    List<String>? list = prefs.getStringList("customSizeList");

    if (list != null) {
      for (String size in list) {
        List<String> parts = size.split('x');
        if (parts.length == 2) {
          try {
            int width = int.parse(parts[0].trim());
            int height = int.parse(parts[1].trim());
            homeSettingController.sizeOptionsWithCustom
                .add(Size(width.toDouble(), height.toDouble()));
          } catch (e) {}
        }
      }
    }
    return true;
  }

  @override
  void onReady() {
    super.onReady();
    _fetchAnlasOnce();
  }

  bool _anlasFetched = false;
  Future<void> _fetchAnlasOnce() async {
    if (_anlasFetched) return;
    _anlasFetched = true;
    try {
      final anlasResult = await imageGenerationController.getAnlasRemaining();
      if (!anlasResult) {
        logout();
      }
    } catch (e) {
      print('[HomePageController] Anlas fetch failed: $e');
    }
  }

  void logout() {
    prefs.remove("NOVEL_AI_ACCESS_KEY");
    prefs.remove("NOVEL_AI_PERSISTENT_TOKEN");
    router.toLogin();
  }

  void onGridTap() {
    router.toImage();
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSnackBar.show(
        '알림',
        '이미지 뷰어 모드로 변경합니다.\n이미지 수에 따라 로딩이 길어질 수 있습니다.',
        backgroundColor: Colors.blue,
        textColor: Colors.white,
      );
    });
  }
}
