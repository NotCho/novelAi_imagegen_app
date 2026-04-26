import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/auto_generation_controller.dart';
import 'package:naiapp/application/home/director_tool_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';
import 'package:naiapp/application/home/image_load_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/gen/diffusion_model.dart' as df;

import '../../domain/gen/i_novelAI_repository.dart';
import '../../main.dart';
import '../core/skeleton_controller.dart';

import '../image/image_page_controller.dart';
import '../wildcard/wildcard_controller.dart';
import '../../view/core/util/app_snackbar.dart';

class HomePageController extends SkeletonController {
  HomeImageController homeImageController = Get.find<HomeImageController>();
  HomeSettingController homeSettingController =
      Get.find<HomeSettingController>();
  AutoGenerationController autoGenerationController =
      Get.find<AutoGenerationController>();
  ImageLoadController imageLoadController = Get.find<ImageLoadController>();
  DirectorToolController directorToolController =
      Get.find<DirectorToolController>();

  final isGenerating = false.obs;
  final RxBool _addQualityTags = false.obs;
  RxInt selectedCharacterIndex = 0.obs;
  RxBool confirmRemoveIndex = false.obs;
  final Map<String, Uint8List> imageCache = {};
  RxBool expandHistory = false.obs;
  RxBool autoSave = false.obs;
  final usingModel = 'nai-diffusion-4-5-full'.obs;

  Map<String, String> modelNames = {
    'nai-diffusion-4-5-full': 'V4.5 Full',
    'nai-diffusion-4-5-curated': 'V4.5 Curated',
    'nai-diffusion-4-full': 'V4 Full',
    'nai-diffusion-4-curated-preview': 'V4 Curated',
    'nai-diffusion-3': 'V3 Full',
  };

  bool modelSupportsVibeTransfer(String model) {
    return model.startsWith('nai-diffusion-4');
  }

  bool modelSupportsCharacterReference(String model) {
    return model.startsWith('nai-diffusion-4-5');
  }

  bool get supportsVibeTransfer => modelSupportsVibeTransfer(usingModel.value);

  bool get supportsCharacterReference =>
      modelSupportsCharacterReference(usingModel.value);

  void setModel(String model) {
    usingModel.value = model;
    if (!supportsVibeTransfer) {
      homeImageController.vibeParseImageBytes.clear();
    }
    if (!supportsCharacterReference) {
      directorToolController.reset();
    }
  }

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

  ScrollController characterScrollController =
      ScrollController(); // 스크롤 컨트롤러 추가

  Rx<df.Center> characterPositions = const df.Center(x: 0.5, y: 0.5).obs;

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

  Future<bool> getAnlasRemaining() async {
    final result = await _novelAIRepository.getAnlasRemaining();
    return result.fold(
      (l) {
        print('Anlas 잔여량 조회 중 오류 발생: $l');
        return false;
      },
      (r) {
        anlasLeft.value = r;
        return true;
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
    super.onClose();
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
      } catch (e) {}
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
      } catch (e) {}
    }
    final persistentToken = prefs.getString("NOVEL_AI_PERSISTENT_TOKEN");
    if (persistentToken == null || persistentToken.isEmpty) {
      // 기존 사용자(AccessKey는 있으나 PersistentToken이 없는 경우) 마이그레이션 시도
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

    // Anlas 잔여량 조회 - 실패 시 로그아웃 후 로그인 화면으로 이동
    final anlasResult = await getAnlasRemaining();
    if (!anlasResult) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        logout();
      });
      return true;
    }

    return true;
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

    autoGenerationController.cancelAutoGenerateTimer();
    await getVibeBytes();

    df.DiffusionModel setting = buildSetting();

    final result = await _novelAIRepository.generateImage(setting: setting);
    result.fold(
      (l) {
        AppSnackBar.show(
          '오류',
          '이미지 생성 중 오류가 발생했습니다: $l',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      },
      (base64Str) {
        getAnlasRemaining(); // Anlas 잔여량 갱신
        final imageBytes = base64Decode(base64Str);
        homeImageController.generatedImagePath.value = base64Str;
        homeImageController.generatedImageBytes.value = imageBytes;
        // 캐시에 저장
        imageCache[base64Str] = imageBytes;

        homeImageController.generationHistory.add(
          GenerationHistoryItem(
            imagePath: base64Str,
            prompt: setting.input,
            seed: setting.parameters.seed,
          ),
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

        if (autoGenerationController.autoGenerateEnabled.value) {
          autoGenerationController.startAutoGenerateTimer();
          homeSettingController.autoResolutionChange();
          autoGenerationController.currentAutoGenerateCount.value++;
          if (autoGenerationController.maxAutoGenerateCount.value > 0) {
            if (autoGenerationController.currentAutoGenerateCount.value >=
                autoGenerationController.maxAutoGenerateCount.value) {
              autoGenerationController.autoGenerateEnabled.value = false;
              autoGenerationController.cancelAutoGenerateTimer();
              AppSnackBar.show(
                '알림',
                '최대 자동 생성 이미지 수에 도달했습니다. 자동 생성이 비활성화됩니다.',
                backgroundColor: Colors.orange,
                textColor: Colors.white,
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

  void loadFromHistory(int index) {
    if (index < 0 || index >= homeImageController.generationHistory.length) {
      return;
    }
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
    setModel(setting.model);
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
    if (modelSupportsVibeTransfer(setting.model)) {
      homeImageController.loadVibeFromExif(setting);
    }
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
      AppSnackBar.show(
        '오류',
        '프리셋을 불러오는 중 오류가 발생했습니다.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    loadSetting(setting);
    AppSnackBar.show(
      '성공',
      '프리셋이 불러와졌습니다: $presetName',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void savePreset(String presetName) {
    if (presetName.isEmpty) {
      AppSnackBar.show(
        '오류',
        '프리셋 이름을 입력해주세요.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    final setting =
        buildSetting(preserveWildcards: true, saveLastSettings: false);
    homeSettingController.savePreset(presetName, setting);
    AppSnackBar.show(
      '성공',
      '프리셋이 저장되었습니다: $presetName',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void overwritePreset(String presetName) {
    final setting =
        buildSetting(preserveWildcards: true, saveLastSettings: false);
    homeSettingController.overwritePreset(presetName, setting);
    AppSnackBar.show(
      '성공',
      '프리셋을 덮어썼습니다: $presetName',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  df.DiffusionModel buildSetting({
    bool preserveWildcards = false,
    bool saveLastSettings = true,
  }) {
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

    // 원본 프롬프트 보존 (저장용 - 와일드카드 포함)
    final originalPos = pos;
    final originalNeg = neg;

    // ============================================================
    // TODO: 테스트 후 디버그 로그 삭제할 것 - 와일드카드 파싱
    // ============================================================
    print('========== [WILDCARD DEBUG] ==========');
    print('[원본 긍정 프롬프트] $pos');
    print('[원본 부정 프롬프트] $neg');

    // 와일드카드 파싱 적용 (API 전송용)
    final wildcardController = Get.find<WildcardController>();
    if (!preserveWildcards) {
      pos = wildcardController.parsePrompt(pos);
      neg = wildcardController.parsePrompt(neg);
    }

    print('[파싱 후 긍정 프롬프트] $pos');
    print('[파싱 후 부정 프롬프트] $neg');

    print('======================================');

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

    // 원본 캐릭터 프롬프트 (저장용 - 와일드카드 포함)
    List<df.CharacterPrompt> charPromOriginal = characterPrompts.map((e) {
      return df.CharacterPrompt(
        prompt: e['positive'].text,
        uc: e['negative'].text,
        center: e['prompt'].center,
        enabled: true,
      );
    }).toList();

    // 캐릭터 프롬프트에 와일드카드 파싱 적용 (API 전송용)
    List<df.CharacterPrompt> charProm = characterPrompts.map((e) {
      return df.CharacterPrompt(
        prompt: preserveWildcards
            ? e['positive'].text
            : wildcardController.parsePrompt(e['positive'].text),
        uc: preserveWildcards
            ? e['negative'].text
            : wildcardController.parsePrompt(e['negative'].text),
        center: e['prompt'].center,
        enabled: true,
      );
    }).toList();
    List<df.CharCaption> charCapPos = characterPrompts.map((e) {
      return df.CharCaption(
        char_caption: preserveWildcards
            ? e['positive'].text
            : wildcardController.parsePrompt(e['positive'].text),
        centers: [e['prompt'].center],
      );
    }).toList();

    List<df.CharCaption> charCapNeg = characterPrompts.map((e) {
      return df.CharCaption(
        char_caption: preserveWildcards
            ? e['negative'].text
            : wildcardController.parsePrompt(e['negative'].text),
        centers: [e['prompt'].center],
      );
    }).toList();
    List<String> vibeBytes;
    List<double> vibeStrengths;
    if (!supportsVibeTransfer) {
      vibeBytes = [];
      vibeStrengths = [];
    } else {
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
    }

    final settingOriginal = df.DiffusionModel(
      input: originalPos,
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
            base_caption: originalPos,
          ),
          use_order: true,
          use_coords: false,
        ),
        add_original_image: true,
        v4_negative_prompt: df.V4NegativePrompt(
          caption: df.Caption(base_caption: originalNeg),
          legacy_uc: false,
        ),
        cfg_rescale: cfgReScale,
        noise_schedule: selectedNoiseSchedule.value,
        deliberate_euler_ancestral_bug: false,
        prefer_brownian: true,
        characterPrompts: charPromOriginal,
        negative_prompt: originalNeg,
        reference_image_multiple: vibeBytes,
        reference_strength_multiple: vibeStrengths,
      ),
      model: usingModel.value,
      action: 'generate',
    );

    if (saveLastSettings) {
      prefs.setString("lastSettings", jsonEncode(settingOriginal.toJson()));
      prefs.setBool("addQualityTags", addQualityTags);
    }

    if (preserveWildcards) {
      return settingOriginal;
    }

    if (addQualityTags) {
      pos += positiveDef;
      neg = negativeDef + neg;
    }

    // 디렉터 툴 데이터 준비
    List<df.DirectorReferenceDescription> directorDescriptions = [];
    List<String> directorImages = [];
    List<int> directorInfoExtracted = [];
    List<double> directorSecondaryStrengths = [];
    List<double> directorStrengths = [];

    if (supportsCharacterReference && directorToolController.isEnabled) {
      directorDescriptions.add(
        df.DirectorReferenceDescription(
          caption: df.DirectorCaption(
            base_caption: directorToolController.getBaseCaption(),
            char_captions: [],
          ),
          legacy_uc: false,
        ),
      );
      directorImages.add(directorToolController.referenceImageBase64.value);
      directorInfoExtracted.add(1);
      directorSecondaryStrengths.add(0.0);
      final double clampedStrength =
          directorToolController.fidelity.value.clamp(0.0, 1.0);
      directorStrengths.add(clampedStrength);
    } else {}

    final bool isDirectorEnabled =
        supportsCharacterReference && directorToolController.isEnabled;
    final bool hasCharCaptions = charCapPos.isNotEmpty;

    final int paramsVersion = isDirectorEnabled ? 3 : 1;
    final bool legacyMode = isDirectorEnabled ? false : true;
    final bool addOriginalImage = isDirectorEnabled ? true : false;
    final bool normalizeReferenceStrengthMultiple =
        isDirectorEnabled ? true : false;
    final bool legacyV3Extend = isDirectorEnabled ? false : true;
    final bool qualityToggle = isDirectorEnabled ? true : false;
    final bool v4PromptUseCoords = isDirectorEnabled ? hasCharCaptions : true;

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
        qualityToggle: qualityToggle,
        autoSmea: false,
        dynamic_thresholding: false,
        controlnet_strength: 1,
        legacy: legacyMode,
        legacy_uc: false,
        normalize_reference_strength_multiple:
            normalizeReferenceStrengthMultiple,
        legacy_v3_extend: legacyV3Extend,
        skip_cfg_above_sigma: null,
        use_coords: false,
        params_version: paramsVersion,
        v4_prompt: df.V4Prompt(
          caption: df.Caption(
            base_caption: pos,
            char_captions: charCapPos,
          ),
          use_order: true,
          use_coords: v4PromptUseCoords,
        ),
        add_original_image: addOriginalImage,
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
        director_reference_descriptions: directorDescriptions,
        director_reference_images: directorImages,
        director_reference_information_extracted: directorInfoExtracted,
        director_reference_secondary_strength_values:
            directorSecondaryStrengths,
        director_reference_strength_values: directorStrengths,
      ),
      model: usingModel.value,
      action: 'generate',
    );

    return setting;
  }

// 해상도 값 안전하게 파싱하는 헬퍼 함수

  int min(int a, int b) => a < b ? a : b;

  Size getAspectRatioSize(String size) {
    final parts = size.split('x');
    if (parts.length != 2) return const Size(1, 1);
    final width = int.tryParse(parts[0].trim()) ?? 1;
    final height = int.tryParse(parts[1].trim()) ?? 1;
    return Size(width.toDouble(), height.toDouble());
  }

  Future<void> addVibeImage(Uint8List image) async {
    if (!supportsVibeTransfer) {
      AppSnackBar.show(
        '지원하지 않는 모델',
        'Vibe Transfer는 V4 이상 모델에서 사용할 수 있습니다.',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }
    if (image.isEmpty) {
      AppSnackBar.show(
        '오류',
        '이미지를 선택해주세요.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
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

  Future<void> addDirectorReferenceImage(Uint8List image) async {
    if (!supportsCharacterReference) {
      AppSnackBar.show(
        '지원하지 않는 모델',
        'Character Reference는 V4.5 모델에서 사용할 수 있습니다.',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }
    if (image.isEmpty) {
      AppSnackBar.show(
        '오류',
        '이미지를 선택해주세요.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final success = directorToolController.setReferenceImage(image);
    if (success) {
      Get.back();
      AppSnackBar.show(
        '성공',
        '레퍼런스 이미지가 설정되었습니다.',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  Future<void> getVibeBytes() async {
    if (!supportsVibeTransfer ||
        homeImageController.vibeParseImageBytes.isEmpty) {
      return;
    }
    Either<String, List<VibeImage>> result = await _novelAIRepository.vibeParse(
        homeImageController.vibeParseImageBytes, usingModel.value);
    result.fold(
      (l) {
        AppSnackBar.show(
          '오류',
          'Vibe 이미지 파싱 중 오류가 발생했습니다: $l',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      },
      (r) {},
    );
  }
}
