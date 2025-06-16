import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async'; // 타이머를 위한 import 추가

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/gen/diffusion_model.dart' as df;

import '../../domain/gen/i_novelAI_repository.dart';
import '../../infra/service/webp_image_parser.dart';
import '../../main.dart';
import '../core/skeleton_controller.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../image/image_page_controller.dart';

class HomePageController extends SkeletonController {
  HomeImageController homeImageController = Get.find<HomeImageController>();
  HomeSettingController homeSettingController =
      Get.find<HomeSettingController>();
  final isGenerating = false.obs;
  final autoGenerateEnabled = false.obs; // 자동 생성 활성화 여부
  RxDouble autoGenerateSeconds = 5.0.obs; // 자동 생성 대기 시간 (초)
  RxDouble autoGenerateRandomDelay = 0.0.obs; // 자동 생성 대기 시간 랜덤 범위
  final remainingSeconds = 0.obs; // 남은 시간 표시용
  Timer? _autoGenerateTimer; // 자동 생성 타이머
  Timer? get autoGenerateTimer => _autoGenerateTimer;
  final RxBool _addQualityTags = false.obs;
  RxInt selectedCharacterIndex = 0.obs;
  RxBool confirmRemoveIndex = false.obs;
  final Map<String, Uint8List> imageCache = {};
  RxBool expandHistory = false.obs;
  RxBool autoSave = false.obs;
  RxString loadImageStatus = "이미지를 불러온 후 체크박스 설정 가능".obs;
  RxBool isExifChecked = false.obs;
  final usingModel = 'nai-diffusion-4-full'.obs;
  Rx<Uint8List> loadedImageBytes = Uint8List(0).obs;
  RxInt maxAutoGenerateCount = 0.obs; // 최대 자동 생성 이미지 수
  RxInt currentAutoGenerateCount = 0.obs; // 현재 자동 생성 이미지 수

  df.DiffusionModel? loadedImageModel;

  Map<String, String> modelNames = {
    'nai-diffusion-4-5-full': 'V4.5 Full',
    'nai-diffusion-4-5-curated': 'V4.5 Curated',
    'nai-diffusion-4-full': 'V4 Full',
    'nai-diffusion-4-curated-preview': 'V4 Curated',
    'nai-diffusion-3': 'V3 Full',
  };

  RxMap<String, bool> loadImageOptions = {
    "긍정 프롬프트": true,
    "부정 프롬프트": true,
    "캐릭터": true,
    '세팅': true,
    'Vibe': false,
    '시드': false
  }.obs;

  List<String> noiseScheduleOptions = [
    'karras',
    'exponential',
    'polyexponential'
  ];

  double convertPosition(double value) {
    return value * 10;
  }

  RxString selectedNoiseSchedule = 'karras'.obs; // 초기값 설정

  bool get addQualityTags => _addQualityTags.value;

  set addQualityTags(bool value) => _addQualityTags.value = value;

  RxList<Map<String, dynamic>> characterPrompts = <Map<String, dynamic>>[].obs;

  Future<void> setAutoSave(bool value) async {
    autoSave.value = value;
  }

  RxInt anlasLeft = (-1).obs; // Anlas 사용 횟수

  final isPanelExpanded = true.obs; // 초기 상태 - 펼쳐진 상태
  final positivePromptController = TextEditingController();
  final negativePromptController = TextEditingController();

  final autoGenerateCountController =
      TextEditingController(text: '0'); // 자동 생성 이미지 수 입력 컨트롤러
  ScrollController characterScrollController =
      ScrollController(); // 스크롤 컨트롤러 추가

  Rx<df.Center> characterPositions = df.Center(x: 0.5, y: 0.5).obs;

  void setCharacterPosition(int x, int y) {
    // 소수점 첫째자리 까지만 저장
    double parsedX = double.parse((((x * 2) + 1) * 0.1).toStringAsFixed(1));
    double parsedY = double.parse((((y * 2) + 1) * 0.1).toStringAsFixed(1));

    characterPositions.value = df.Center(
      x: parsedX,
      y: parsedY,
    );

    characterPrompts[selectedCharacterIndex.value]['prompt'] =
        characterPrompts[selectedCharacterIndex.value]['prompt']
            .copyWith(center: characterPositions.value);
    print('Character position set to: x=$parsedX, y=$parsedY');
    update();
  }

  void onCharaAddButtonTap() {
    characterPrompts.add({
      'prompt': const df.CharacterPrompt(
        prompt: '',
        uc: '',
        center: df.Center(x: 0.5, y: 0.5),
        enabled: true,
      ),
      'positive': TextEditingController(),
      'negative': TextEditingController(),
    });
    selectedCharacterIndex.value = characterPrompts.length - 1;
    characterScrollController.animateTo(
      characterScrollController.position.maxScrollExtent + 25,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  onCharaRemoveButtonTap() {
    int index = selectedCharacterIndex.value;
    if (confirmRemoveIndex.value) {
      if (index - 1 < 0) {
        if (characterPrompts.length > 1) {
          selectedCharacterIndex.value = 0;
        } else {
          selectedCharacterIndex.value = index + 1;
        }
        selectedCharacterIndex.value = 0;
      } else {
        selectedCharacterIndex.value = index - 1;
      }
      characterPrompts.removeAt(index);
      confirmRemoveIndex.value = false;
    } else {
      confirmRemoveIndex.value = true;
    }
  }

// HomePageController에 추가할 함수들

// 64의 배수로 변환하는 함수

  void getAnlasRemaining() async {
    final result = await _novelAIRepository.getAnlasRemaining();
    result.fold(
      (l) => print('Anlas 잔여량 조회 중 오류 발생: $l'),
      (r) {
        anlasLeft.value = r;
      },
    );
  }

  void onCharaTap(int index) {
    if (index < 0 || index >= characterPrompts.length) return;
    selectedCharacterIndex.value = index;
    characterPositions.value = characterPrompts[index]['prompt'].center;
    characterScrollController.animateTo(
      0 + (index * 61),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    positivePromptController.dispose();
    negativePromptController.dispose();
    _cancelAutoGenerateTimer(); // 타이머 취소
    super.onClose();
  }

  void _cancelAutoGenerateTimer() {
    _autoGenerateTimer?.cancel();
    _autoGenerateTimer = null;
  }

  void _startAutoGenerateTimer() {
    if (!autoGenerateEnabled.value) return;

    // 기본 시간 설정
    double baseSeconds = autoGenerateSeconds.value;

    // 랜덤 범위 계산 (최대 변동 폭)
    double randomRange = baseSeconds * autoGenerateRandomDelay.value;

    // -randomRange부터 +randomRange 사이의 랜덤 값 생성
    double randomOffset =
        (Random().nextDouble() * 2 * randomRange) - randomRange;

    // 최종 시간 계산 (기본 시간 ± 랜덤 오프셋)
    double finalSeconds = baseSeconds + randomOffset;

    // 최소 시간 보장 (음수가 되지 않도록)
    finalSeconds = max(1.0, finalSeconds);

    // 최종 시간 설정
    remainingSeconds.value = finalSeconds.round();

    _cancelAutoGenerateTimer();

    _autoGenerateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingSeconds.value--;
      if (remainingSeconds.value <= 0) {
        _cancelAutoGenerateTimer();
        if (!isGenerating.value && autoGenerateEnabled.value) {
          generateImage();
        }
      }
    });
  }

  void toggleAutoGenerate() async {
    autoGenerateEnabled.toggle();
    if (autoGenerateEnabled.value) {
      await FlutterForegroundTask.startService(
        notificationTitle: '서비스 실행 중',
        notificationText: '탭하면 앱으로 돌아갑니다',
        notificationInitialRoute: '/home',
        callback: startCallback, // top-level 함수로 TaskHandler 등록
      );
    } else {
      FlutterForegroundTask.stopService();
    }
    if (autoGenerateEnabled.value && !isGenerating.value) {
      _startAutoGenerateTimer();
    } else {
      _cancelAutoGenerateTimer();
    }
  }

  void setAutoGenerateSeconds(double time) {
    autoGenerateSeconds.value = time;
    if (_autoGenerateTimer != null && _autoGenerateTimer!.isActive) {
      _startAutoGenerateTimer();
    }
  }

  void setAutoGenerateRandomDelay(double delay) {
    autoGenerateRandomDelay.value = delay;
  }

  String getRandomDelayCalculation() {
    double randomRange =
        autoGenerateSeconds.value * autoGenerateRandomDelay.value;
    return "±${randomRange.toStringAsFixed(2)}초";
  }

  final INovelAIRepository _novelAIRepository = Get.find<INovelAIRepository>();
  final SharedPreferences prefs = Get.find<SharedPreferences>();

  Future<void> getPrevSettings() async {
    final raw = prefs.getString("lastSettings");
    addQualityTags = prefs.getBool("addQualityTags") ?? false;
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
    final raw = prefs.getString("lastSettings");
    if (raw != null) {
      Map<String, dynamic> data = jsonDecode(raw);
      try {
        final setting = df.DiffusionModel.fromJson(data);
        loadSetting(setting);
      } catch (e) {
        print('Error loading last settings: $e');
      }
    }
    if (prefs.getString("NOVEL_AI_ACCESS_KEY") == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.toLogin();
      });
    }

    final tokenResult = await _novelAIRepository.createPersistentToken();
    tokenResult.fold(
      (l) => print('토큰 생성 중 오류가 발생했습니다: $l'),
      (r) => print('토큰 생성 성공: $r'),
    );
    homeSettingController.loadPresets();
    List<String>? list = await prefs.getStringList("customSizeList");
    if (list != null) {
      for (String size in list) {
        List<String> parts = size.split('x');
        if (parts.length == 2) {
          try {
            int width = int.parse(parts[0].trim());
            int height = int.parse(parts[1].trim());
            homeSettingController.sizeOptionsWithCustom
                .add(Size(width.toDouble(), height.toDouble()));
          } catch (e) {
            print('Invalid custom size format: $size');
          }
        }
      }
    }
    getAnlasRemaining();
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

  static Map<String, String> posMap = {
    "nai-diffusion-4-full":
        ", no text, best quality, very aesthetic, absurdres",
    "nai-diffusion-4-5-curated":
        "location, masterpiece, no text, -0.8::feet::, rating:general"
  };

  String positiveDef = "";
  String negativeDef =
      "nsfw, blurry, lowres, error, worst quality, bad quality, jpeg artifacts, very displeasing, white blank page, blank page, ";

  RxBool floatingButtonExpanded = false.obs;

  void generateImage() async {
    positiveDef = posMap[usingModel.value] ?? '';
    if (isGenerating.value) return;

    // 🔥 생성 전 해상도 유효성 검사 먼저 실행!
    homeSettingController.validateResolutionBeforeGenerate();

    isGenerating.value = true;
    if (homeSettingController.randomSeed.value) {
      homeSettingController.seedController.text = "";
    }
    if (homeSettingController.seedController.text.isEmpty) {
      homeSettingController.randomSeed.value = true;
    }

    _cancelAutoGenerateTimer();
    await getVibeBytes();

    df.DiffusionModel setting = buildSetting();

    final result = await _novelAIRepository.generateImage(setting: setting);
    result.fold(
      (l) => Get.snackbar('오류', '이미지 생성 중 오류가 발생했습니다: $l',
          backgroundColor: Colors.red, colorText: Colors.white),
      (base64Str) {
        getAnlasRemaining(); // Anlas 잔여량 갱신
        final imageBytes = base64Decode(base64Str);
        homeImageController.generatedImagePath.value = base64Str;
        homeImageController.generatedImageBytes.value = imageBytes;
        // 캐시에 저장
        imageCache[base64Str] = imageBytes;

        homeImageController.generationHistory.add(
          GenerationHistoryItem(imagePath: base64Str, prompt: setting.input),
        );

        FlutterForegroundTask.updateService(
          notificationTitle: '자동 생성 활성화',
          notificationText:
              '현재 생성된 이미지 수 : ${homeImageController.generationHistory.length}개 | ${(autoSave.value) ? "자동 저장중" : "저장 안함"}',
          notificationInitialRoute: '',
          callback: startCallback, // top-level 함수로 TaskHandler 등록
        );
        try {
          Get.find<ImagePageController>().scrollCheck();
        } catch (e) {}

        if (autoGenerateEnabled.value) {
          _startAutoGenerateTimer();
          homeSettingController.autoResolutionChange();
          currentAutoGenerateCount.value++;
          if (maxAutoGenerateCount.value > 0) {
            if (currentAutoGenerateCount.value >= maxAutoGenerateCount.value) {
              autoGenerateEnabled.value = false;
              _cancelAutoGenerateTimer();
              Get.snackbar(
                '알림',
                '최대 자동 생성 이미지 수에 도달했습니다. 자동 생성이 비활성화됩니다.',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            }
          }
        }
      },
    );
    if (autoSave.value) {
      homeImageController.saveLastImage();
    }

    try {
      if (homeImageController.imageViewPageController.page != 0 &&
          homeImageController.imageViewPageController.page != 29) {
        homeImageController.imageViewPageController.jumpToPage(
            homeImageController.imageViewPageController.page!.toInt() + 1);
      }
    } catch (e) {}
    homeImageController.currentImageBytes.value =
        homeImageController.generatedImageBytes.value;
    isGenerating.value = false;
  }

  void loadFromImage() {
    if (loadedImageBytes.value.isEmpty) {
      Get.snackbar('오류', '이미지를 불러오지 못했습니다.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (loadedImageModel == null) {
      Get.snackbar('오류', '메타데이터를 불러오지 못했습니다.',
          backgroundColor: Colors.red, colorText: Colors.white);
      _checkImageMetadata(loadedImageBytes.value);
      return;
    }

    // 선택된 내용만 적용하기
    if (loadImageOptions['긍정 프롬프트']!) {
      positivePromptController.text = loadedImageModel!.input;
    }

    if (loadImageOptions['부정 프롬프트']!) {
      negativePromptController.text =
          loadedImageModel!.parameters.v4_negative_prompt.caption.base_caption;
    }

    if (loadImageOptions['세팅']!) {
      // 세팅 관련 값 적용
      usingModel.value = loadedImageModel!.model;
      homeSettingController.samplingSteps.value =
          loadedImageModel!.parameters.steps;

      homeSettingController.setSettings(loadedImageModel!);

      // 노이즈 스케줄 설정
      selectedNoiseSchedule.value = noiseScheduleOptions
              .contains(loadedImageModel!.parameters.noise_schedule)
          ? loadedImageModel!.parameters.noise_schedule
          : noiseScheduleOptions.first;
    }

    if (loadImageOptions['캐릭터']!) {
      // 캐릭터 프롬프트 적용
      characterPrompts.clear();
      for (var i = 0;
          i < loadedImageModel!.parameters.characterPrompts.length;
          i++) {
        characterPrompts.add({
          'prompt': loadedImageModel!.parameters.characterPrompts[i],
          'positive': TextEditingController(
              text: loadedImageModel!.parameters.characterPrompts[i].prompt),
          'negative': TextEditingController(
              text: loadedImageModel!.parameters.characterPrompts[i].uc),
        });
      }
      Get.back();
    }

    if (loadImageOptions['Vibe']!) {
      homeImageController.loadVibeFromExif(loadedImageModel!);
    }

    if (loadImageOptions['시드']!) {
      // 시드 및 랜덤 여부 적용
      homeSettingController.randomSeed.value =
          loadedImageModel!.parameters.seed == 999999999;
      homeSettingController.seedController.text =
          homeSettingController.randomSeed.value
              ? ""
              : loadedImageModel!.parameters.seed.toString();
    }

    Get.back();
    Get.snackbar('성공', '이미지에서 선택한 설정을 불러왔습니다!',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  void clearImageDialog() {
    loadedImageBytes.value = Uint8List(0);
    loadImageStatus.value = "이미지를 불러온 후 체크박스 설정 가능";
    isExifChecked.value = false;
  }

  void cancelImageLoad() async {
    Get.back();
    clearImageDialog();
  }

  Future<void> _checkImageMetadata(Uint8List imageBytes) async {
    try {
      Map<String, String>? textChunks =
          WebPMetadataParser.extractMetadata(imageBytes);
      String? metadata;
      if (textChunks == null || textChunks.isEmpty) {
        loadImageStatus.value = "실패, 메타데이터 없음";
        print('메타데이터를 찾을 수 없습니다');
        return;
      }
      metadata = textChunks['Comment'];

      if (metadata != null) {
        try {
          final jsonData = jsonDecode(metadata);
          if (jsonData is Map && jsonData.containsKey('prompt')) {
            final prompt = jsonData['prompt'];
            loadImageStatus.value = "메타데이터 로드됨: $prompt";
            isExifChecked.value = true;
          }

          try {
            loadedImageModel = homeImageController.diffusionModelFromExifMap(
                defaultModel: usingModel.value, textChunks: textChunks);
            print('DiffusionModel 생성 완료');
          } catch (e) {
            loadImageStatus.value = "실패, 메타데이터 파싱불가: $e\n메타데이터: $metadata";
            print('Exif 추출 실패: $e');
          }
        } catch (e) {
          loadImageStatus.value = "실패, 메타데이터 파싱불가: $e\n메타데이터: $metadata";
          print('JSON 파싱 실패: $e');
        }
      } else {
        loadImageStatus.value = "실패, 메타데이터 없음";
        print('갤러리 이미지에서 메타데이터를 찾을 수 없습니다');
      }
    } catch (e) {
      loadImageStatus.value = "실패, 메타데이터 확인 중 오류: $e";
      print('메타데이터 확인 중 오류: $e');
    }
  }

  void loadFromHistory(int index) {
    if (index < 0 || index >= homeImageController.generationHistory.length)
      return;
    final item = homeImageController.generationHistory[index];
    homeImageController.generatedImagePath.value = item.imagePath;

    // 캐시에 있으면 캐시에서 불러오기
    if (imageCache.containsKey(item.imagePath)) {
      homeImageController.generatedImageBytes.value =
          imageCache[item.imagePath]!;
    } else {
      // 없으면 다시 디코딩
      homeImageController.generatedImageBytes.value =
          base64Decode(item.imagePath);
      // 캐시에 저장
      imageCache[item.imagePath] =
          homeImageController.generatedImageBytes.value;
    }

    positivePromptController.text = item.prompt;
  }

  void loadSetting(df.DiffusionModel setting) {
    positivePromptController.text = setting.input;
    negativePromptController.text =
        setting.parameters.v4_negative_prompt.caption.base_caption;
    usingModel.value = setting.model;
    homeSettingController.randomSeed.value =
        setting.parameters.seed == 999999999;
    selectedNoiseSchedule.value =
        noiseScheduleOptions.contains(setting.parameters.noise_schedule)
            ? setting.parameters.noise_schedule
            : noiseScheduleOptions.first;
    homeSettingController.seedController.text =
        homeSettingController.randomSeed.value
            ? ""
            : setting.parameters.seed.toString();
    addQualityTags = prefs.getBool("addQualityTags") ?? false;
    homeSettingController.setSettings(setting);
    homeImageController.loadVibeFromExif(setting);
    characterPrompts.clear();
    for (var i = 0; i < setting.parameters.characterPrompts.length; i++) {
      characterPrompts.add({
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
    final setting = buildSetting();
    homeSettingController.savePreset(presetName, setting);
    Get.snackbar('성공', '프리셋이 저장되었습니다: $presetName',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  df.DiffusionModel buildSetting() {
    int storageSeed = (homeSettingController.randomSeed.value ||
            homeSettingController.seedController.text == "")
        ? 999999999
        : int.parse(homeSettingController.seedController.text);

    // 실제 API 요청에 사용할 시드
    int actualSeed = (homeSettingController.randomSeed.value ||
            homeSettingController.seedController.text == "")
        ? Random().nextInt(4294967296) // 실제 요청에는 진짜 랜덤 값 사용
        : int.parse(homeSettingController.seedController.text);

    var pos = positivePromptController.text;
    var neg = negativePromptController.text;

    // SettingController에서 값 가져오기
    List<int> size;
    int xSize = int.tryParse(homeSettingController.xSizeController.text) ?? 512;
    int ySize = int.tryParse(homeSettingController.ySizeController.text) ?? 512;
    size = [xSize, ySize];

    int step = homeSettingController.samplingSteps.value.toInt();

    double cfgReScale = homeSettingController.cfgReScale.value.toDouble();

    double promptGuidance =
        homeSettingController.promptGuidance.value.toDouble();

    String sampler = homeSettingController.selectedSamplerValue;
    List<df.CharacterPrompt> charProm = characterPrompts.map((e) {
      return df.CharacterPrompt(
        prompt: e['positive'].text,
        uc: e['negative'].text,
        center: e['prompt'].center,
        enabled: true,
      );
    }).toList();
    List<df.CharCaption> charCapPos = characterPrompts.map((e) {
      return df.CharCaption(
        char_caption: e['positive'].text,
        centers: [e['prompt'].center],
      );
    }).toList();

    List<df.CharCaption> charCapNeg = characterPrompts.map((e) {
      return df.CharCaption(
        char_caption: e['negative'].text,
        centers: [e['prompt'].center],
      );
    }).toList();
    List<String> vibeBytes;
    List<double> vibeStrengths;
    try {
      vibeBytes = homeImageController.vibeParseImageBytes
          .map((e) => base64Encode(e.bytes!))
          .toList();
      vibeStrengths = homeImageController.vibeParseImageBytes
          .map((e) => e.weight.value)
          .toList();
    } catch (e) {
      vibeBytes = [];
      vibeStrengths = [];
    }

    final settingOriginal = df.DiffusionModel(
      input: pos,
      parameters: df.Parameters(
        seed: storageSeed,
        steps: step,
        sampler: sampler,
        width: size[0],
        height: size[1],
        scale: promptGuidance,
        n_samples: 1,
        ucPreset: 0,
        qualityToggle: true,
        autoSmea: false,
        dynamic_thresholding: false,
        controlnet_strength: 1,
        legacy: false,
        legacy_uc: false,
        normalize_reference_strength_multiple: true,
        legacy_v3_extend: false,
        skip_cfg_above_sigma: null,
        use_coords: false,
        params_version: 3,
        v4_prompt: df.V4Prompt(
          caption: df.Caption(
            base_caption: pos,
          ),
          use_order: true,
          use_coords: false,
        ),
        add_original_image: true,
        v4_negative_prompt: df.V4NegativePrompt(
          caption: df.Caption(base_caption: neg),
          legacy_uc: false,
        ),
        cfg_rescale: cfgReScale,
        noise_schedule: selectedNoiseSchedule.value,
        deliberate_euler_ancestral_bug: false,
        prefer_brownian: true,
        characterPrompts: charProm,
        negative_prompt: neg,
        reference_image_multiple: vibeBytes,
        reference_strength_multiple: vibeStrengths,
      ),
      model: usingModel.value,
      action: 'generate',
    );

    prefs.setString("lastSettings", jsonEncode(settingOriginal.toJson()));
    prefs.setBool("addQualityTags", addQualityTags);

    if (addQualityTags) {
      pos += positiveDef;
      neg = negativeDef + neg;
    }

    final setting = df.DiffusionModel(
      input: pos,
      parameters: df.Parameters(
        seed: actualSeed,
        steps: step,
        sampler: sampler,
        width: size[0],
        height: size[1],
        scale: promptGuidance,
        n_samples: 1,
        ucPreset: 0,
        qualityToggle: false,
        autoSmea: false,
        dynamic_thresholding: false,
        controlnet_strength: 1,
        legacy: true,
        legacy_uc: false,
        normalize_reference_strength_multiple: false,
        legacy_v3_extend: true,
        skip_cfg_above_sigma: null,
        use_coords: false,
        params_version: 1,
        v4_prompt: df.V4Prompt(
          caption: df.Caption(
            base_caption: pos,
            char_captions: charCapPos,
          ),
          use_order: true,
          use_coords: true,
        ),
        add_original_image: false,
        v4_negative_prompt: df.V4NegativePrompt(
          caption: df.Caption(base_caption: neg, char_captions: charCapNeg),
          legacy_uc: false,
        ),
        cfg_rescale: cfgReScale,
        noise_schedule: selectedNoiseSchedule.value,
        deliberate_euler_ancestral_bug: false,
        prefer_brownian: true,
        characterPrompts: charProm,
        negative_prompt: neg,
        reference_image_multiple: vibeBytes,
        reference_strength_multiple: vibeStrengths,
      ),
      model: usingModel.value,
      action: 'generate',
    );

    return setting;
  }

// 해상도 값 안전하게 파싱하는 헬퍼 함수

// 이미지 로딩 개선 버전
  void getImageFromGallery() async {
    try {
      final result = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        // 이미지 품질 조정 (더 낮은 값도 시도해 볼 수 있음)
        imageQuality: 100,
      );

      if (result != null) {
        print('갤러리에서 이미지 선택: ${result.path}');

        try {
          final file = File(result.path);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();

            // 이미지 처리 전에 포맷 확인

            _checkImageMetadata(bytes);

            // UI 업데이트
            imageCache[base64Encode(bytes)] = bytes;
            loadedImageBytes.value = bytes;

            return; // 성공했으면 여기서 종료
          }
        } catch (e) {
          print('File API 접근 실패, 대체 방법 시도: $e');
        }

        // 2. readAsBytes 방식 시도
        try {
          final bytes = await result.readAsBytes();
          print('readAsBytes로 이미지 로드 성공: ${bytes.length} 바이트');

          // UI 업데이트
          imageCache[base64Encode(bytes)] = bytes;
          loadedImageBytes.value = bytes;

          return; // 성공했으면 여기서 종료
        } catch (e) {
          print('readAsBytes 실패, 대체 방법 시도: $e');
        }

        // 3. 복사 후 접근 시도 (가장 안전한 방법)
        try {
          // 임시 디렉토리에 복사
          final tempDir = await getTemporaryDirectory();
          final tempPath =
              '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.png';
          final tempFile = File(tempPath);

          // 원본 파일 복사
          await File(result.path).copy(tempPath);

          if (await tempFile.exists()) {
            final bytes = await tempFile.readAsBytes();

            // UI 업데이트
            imageCache[base64Encode(bytes)] = bytes;
            loadedImageBytes.value = bytes;

            await tempFile.delete();
            return;
          }
        } catch (e) {
          print('임시 파일 복사 방식 실패: $e');
        }

        // 4. 다른 방법으로 시도: 이미지 디코딩 후 다시 인코딩
        try {
          // 여기서는 image 패키지를 사용해서 디코딩 후 다시 인코딩
          final imgBytes = await result.readAsBytes();
          final img.Image? decodedImage = img.decodeImage(imgBytes);

          if (decodedImage != null) {
            // 디코딩 성공, PNG로 다시 인코딩
            final reEncodedBytes = img.encodePng(decodedImage);
            print('이미지 재인코딩 성공: ${reEncodedBytes.length} 바이트');

            // UI 업데이트
            homeImageController.generatedImageBytes.value =
                Uint8List.fromList(reEncodedBytes);
            homeImageController.generatedImagePath.value =
                base64Encode(reEncodedBytes);
            imageCache[base64Encode(reEncodedBytes)] =
                Uint8List.fromList(reEncodedBytes);
            homeImageController.generationHistory.add(
              GenerationHistoryItem(
                  imagePath: base64Encode(reEncodedBytes), prompt: ''),
            );

            return;
          }
        } catch (e) {
          print('이미지 재인코딩 실패: $e');
        }

        // 모든 방법 실패
        Get.snackbar('오류', '이미지를 로드할 수 없습니다.',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('갤러리에서 이미지 로드 중 오류: $e');
      Get.snackbar('오류', '갤러리에서 이미지를 불러오는 중 문제가 발생했습니다: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  int min(int a, int b) => a < b ? a : b;

  Size getAspectRatioSize(String size) {
    final parts = size.split('x');
    if (parts.length != 2) return const Size(1, 1);
    final width = int.tryParse(parts[0].trim()) ?? 1;
    final height = int.tryParse(parts[1].trim()) ?? 1;
    return Size(width.toDouble(), height.toDouble());
  }

  Future<void> addVibeImage(Uint8List image) async {
    if (image.isEmpty) {
      Get.snackbar('오류', '이미지를 선택해주세요.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    VibeImage vibeImage = VibeImage(
        image: image,
        weight: 0.6.obs,
        extractionStrength: 1.0.obs,
        prevExtractionStrength: 0.0.obs);
    homeImageController.vibeParseImageBytes.add(vibeImage);
    Get.back();
  }

  Future<void> getVibeBytes() async {
    Either<String, List<VibeImage>> result = await _novelAIRepository.vibeParse(
        homeImageController.vibeParseImageBytes, usingModel.value);
    result.fold(
      (l) {
        print(l);
        Get.snackbar('오류', 'Vibe 이미지 파싱 중 오류가 발생했습니다: $l',
            backgroundColor: Colors.red, colorText: Colors.white);
      },
      (r) {},
    );
  }
}
