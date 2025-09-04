import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/home_auto_generation_controller.dart';
import 'package:naiapp/application/home/home_character_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';
import 'package:naiapp/domain/gen/diffusion_model.dart' as df;
import 'package:naiapp/domain/gen/i_novelAI_repository.dart';
import 'package:naiapp/application/image/image_page_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeGenerationController extends GetxController {
  final INovelAIRepository _novelAIRepository = Get.find<INovelAIRepository>();
  final SharedPreferences prefs = Get.find<SharedPreferences>();

  // Dependencies
  HomeSettingController get _setting => Get.find<HomeSettingController>();
  HomeCharacterController get _character => Get.find<HomeCharacterController>();
  HomeImageController get _image => Get.find<HomeImageController>();
  HomeAutoGenerationController get _autoGen => Get.find<HomeAutoGenerationController>();

  final isGenerating = false.obs;
  final positivePromptController = TextEditingController();
  final negativePromptController = TextEditingController();

  final _addQualityTags = false.obs;
  bool get addQualityTags => _addQualityTags.value;
  set addQualityTags(bool value) => _addQualityTags.value = value;

  final usingModel = 'nai-diffusion-4-5-full'.obs;
  final RxString selectedNoiseSchedule = 'karras'.obs;

  Map<String, String> modelNames = {
    'nai-diffusion-4-5-full': 'V4.5 Full',
    'nai-diffusion-4-5-curated': 'V4.5 Curated',
    'nai-diffusion-4-full': 'V4 Full',
    'nai-diffusion-4-curated-preview': 'V4 Curated',
    'nai-diffusion-3': 'V3 Full',
  };

  List<String> noiseScheduleOptions = [
    'karras',
    'exponential',
    'polyexponential'
  ];

  static Map<String, String> posMap = {
    "nai-diffusion-4-full":
        ", no text, best quality, very aesthetic, absurdres",
    "nai-diffusion-4-5-curated":
        "location, masterpiece, no text, -0.8::feet::, rating:general"
  };

  String positiveDef = "";
  String negativeDef =
      "nsfw, blurry, lowres, error, worst quality, bad quality, jpeg artifacts, very displeasing, white blank page, blank page, ";

  RxInt anlasLeft = (-1).obs;

  @override
  void onClose() {
    positivePromptController.dispose();
    negativePromptController.dispose();
    super.onClose();
  }

  Future<void> getAnlasRemaining() async {
    final result = await _novelAIRepository.getAnlasRemaining();
    result.fold(
      (l) => print('Anlas 잔여량 조회 중 오류 발생: $l'),
      (r) {
        anlasLeft.value = r;
      },
    );
  }

  Future<void> generateImage() async {
    positiveDef = posMap[usingModel.value] ?? '';
    if (isGenerating.value) return;

    _setting.validateResolutionBeforeGenerate();

    isGenerating.value = true;
    if (_setting.randomSeed.value) {
      _setting.seedController.text = "";
    }
    if (_setting.seedController.text.isEmpty) {
      _setting.randomSeed.value = true;
    }

    await _image.getVibeBytes();

    df.DiffusionModel setting = buildSetting();

    final result = await _novelAIRepository.generateImage(setting: setting);
    result.fold(
      (l) {
        Get.snackbar('오류', '이미지 생성 중 오류가 발생했습니다: $l',
          backgroundColor: Colors.red, colorText: Colors.white);
        isGenerating.value = false;
      },
      (base64Str) {
        getAnlasRemaining();
        final imageBytes = base64Decode(base64Str);
        _image.onImageGenerated(base64Str, imageBytes, setting.input);

        _autoGen.onImageGenerated();
        try {
          Get.find<ImagePageController>().scrollCheck();
        } catch (e) {}

        if (_setting.autoSave.value) {
          _image.saveLastImage();
        }

        try {
          if (_image.imageViewPageController.page != 0 &&
              _image.imageViewPageController.page != 29) {
            _image.imageViewPageController.jumpToPage(
                _image.imageViewPageController.page!.toInt() + 1);
          }
        } catch (e) {}

        _image.currentImageBytes.value =
            _image.generatedImageBytes.value;
        isGenerating.value = false;
      },
    );
  }

  df.DiffusionModel buildSetting() {
    int storageSeed = (_setting.randomSeed.value ||
            _setting.seedController.text.isEmpty)
        ? 999999999
        : int.parse(_setting.seedController.text);

    int actualSeed = (_setting.randomSeed.value ||
            _setting.seedController.text.isEmpty)
        ? Random().nextInt(4294967296)
        : int.parse(_setting.seedController.text);

    var pos = positivePromptController.text;
    var neg = negativePromptController.text;

    List<int> size;
    int xSize = int.tryParse(_setting.xSizeController.text) ?? 512;
    int ySize = int.tryParse(_setting.ySizeController.text) ?? 512;
    size = [xSize, ySize];

    int step = _setting.samplingSteps.value.toInt();
    double cfgReScale = _setting.cfgReScale.value.toDouble();
    double promptGuidance = _setting.promptGuidance.value.toDouble();
    String sampler = _setting.selectedSamplerValue;

    List<df.CharacterPrompt> charProm = _character.characterPrompts.map((e) {
      return df.CharacterPrompt(
        prompt: e['positive'].text,
        uc: e['negative'].text,
        center: e['prompt'].center,
        enabled: true,
      );
    }).toList();
    List<df.CharCaption> charCapPos = _character.characterPrompts.map((e) {
      return df.CharCaption(
        char_caption: e['positive'].text,
        centers: [e['prompt'].center],
      );
    }).toList();

    List<df.CharCaption> charCapNeg = _character.characterPrompts.map((e) {
      return df.CharCaption(
        char_caption: e['negative'].text,
        centers: [e['prompt'].center],
      );
    }).toList();

    List<String> vibeBytes;
    List<double> vibeStrengths;
    try {
      vibeBytes = _image.vibeParseImageBytes
          .map((e) => base64Encode(e.bytes!))
          .toList();
      vibeStrengths = _image.vibeParseImageBytes
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
}
