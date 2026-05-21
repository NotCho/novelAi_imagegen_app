import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naiapp/application/home/director_tool_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';
import 'package:naiapp/application/home/prompt_controller.dart';
import 'package:naiapp/application/wildcard/wildcard_controller.dart';
import 'package:naiapp/application/home/model_config_controller.dart';
import 'package:naiapp/domain/gen/diffusion_model.dart' as df;

class DiffusionModelBuilder {
  final HomeSettingController homeSettingController = Get.find<HomeSettingController>();
  final PromptController promptController = Get.find<PromptController>();
  final WildcardController wildcardController = Get.find<WildcardController>();
  final HomeImageController homeImageController = Get.find<HomeImageController>();
  final DirectorToolController directorToolController = Get.find<DirectorToolController>();
  final ModelConfigController modelConfigController = Get.find<ModelConfigController>();
  final SharedPreferences prefs = Get.find<SharedPreferences>();

  // These should be passed or fetched. They were part of HomePageController.
  bool addQualityTags = false;
  String positiveDef = ", best quality, amazing quality, very aesthetic, absurdres";
  String negativeDef = "nsfw, lowres, {bad}, error, fewer, extra, worst quality, jpeg artifacts, bad quality, watermark, unfinished, displeasing, chromatic aberration, signature, extra digits, artistic error, username, scan, [abstract],";
  
  void updateQualityTags(String pos, String neg) {
    positiveDef = pos;
    negativeDef = neg;
  }

  df.DiffusionModel buildSetting({
    bool preserveWildcards = false,
    bool saveLastSettings = true,
  }) {
    int storageSeed = (homeSettingController.randomSeed.value ||
            homeSettingController.seedController.text == "")
        ? 999999999
        : int.parse(homeSettingController.seedController.text);

    int actualSeed = (homeSettingController.randomSeed.value ||
            homeSettingController.seedController.text == "")
        ? Random().nextInt(4294967296)
        : int.parse(homeSettingController.seedController.text);

    var pos = promptController.positivePromptController.text;
    var neg = promptController.negativePromptController.text;

    final originalPos = pos;
    final originalNeg = neg;

    if (!preserveWildcards) {
      pos = wildcardController.parsePrompt(pos);
      neg = wildcardController.parsePrompt(neg);
    }

    List<int> size;
    int xSize = int.tryParse(homeSettingController.xSizeController.text) ?? 512;
    int ySize = int.tryParse(homeSettingController.ySizeController.text) ?? 512;
    size = [xSize, ySize];

    int step = homeSettingController.samplingSteps.value.toInt();
    double cfgReScale = homeSettingController.cfgReScale.value.toDouble();
    double promptGuidance = homeSettingController.promptGuidance.value.toDouble();
    String sampler = homeSettingController.selectedSamplerValue;

    List<df.CharacterPrompt> charPromOriginal = promptController.characterPrompts.map((e) {
      return df.CharacterPrompt(
        prompt: e['positive'].text,
        uc: e['negative'].text,
        center: e['prompt'].center,
        enabled: e['prompt'].enabled,
      );
    }).toList();

    final enabledCharacterPrompts =
        promptController.characterPrompts.where((e) => e['prompt'].enabled == true).toList();

    List<df.CharacterPrompt> charProm = enabledCharacterPrompts.map((e) {
      return df.CharacterPrompt(
        prompt: preserveWildcards
            ? e['positive'].text
            : wildcardController.parsePrompt(e['positive'].text),
        uc: preserveWildcards
            ? e['negative'].text
            : wildcardController.parsePrompt(e['negative'].text),
        center: e['prompt'].center,
        enabled: e['prompt'].enabled,
      );
    }).toList();
    
    List<df.CharCaption> charCapPos = enabledCharacterPrompts.map((e) {
      return df.CharCaption(
        char_caption: preserveWildcards
            ? e['positive'].text
            : wildcardController.parsePrompt(e['positive'].text),
        centers: [e['prompt'].center],
      );
    }).toList();

    List<df.CharCaption> charCapNeg = enabledCharacterPrompts.map((e) {
      return df.CharCaption(
        char_caption: preserveWildcards
            ? e['negative'].text
            : wildcardController.parsePrompt(e['negative'].text),
        centers: [e['prompt'].center],
      );
    }).toList();

    List<String> vibeBytes;
    List<double> vibeStrengths;
    if (!modelConfigController.supportsVibeTransfer) {
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
        noise_schedule: modelConfigController.selectedNoiseSchedule.value,
        deliberate_euler_ancestral_bug: false,
        prefer_brownian: true,
        characterPrompts: charPromOriginal,
        negative_prompt: originalNeg,
        reference_image_multiple: vibeBytes,
        reference_strength_multiple: vibeStrengths,
      ),
      model: modelConfigController.usingModel.value,
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

    List<df.DirectorReferenceDescription> directorDescriptions = [];
    List<String> directorImages = [];
    List<int> directorInfoExtracted = [];
    List<double> directorSecondaryStrengths = [];
    List<double> directorStrengths = [];

    if (modelConfigController.supportsCharacterReference && directorToolController.isEnabled) {
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
    }

    final bool isDirectorEnabled =
        modelConfigController.supportsCharacterReference && directorToolController.isEnabled;
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
        noise_schedule: modelConfigController.selectedNoiseSchedule.value,
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
      model: modelConfigController.usingModel.value,
      action: 'generate',
    );

    return setting;
  }
}
