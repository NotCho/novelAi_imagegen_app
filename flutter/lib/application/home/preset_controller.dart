import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/gen/diffusion_model.dart' as df;
import '../../view/core/util/app_snackbar.dart';
import 'home_page_controller.dart';
import 'home_setting_controller.dart';
import 'home_image_controller.dart';
import 'prompt_controller.dart';
import 'diffusion_model_builder.dart';
import 'model_config_controller.dart';

class PresetController extends GetxController {
  final SharedPreferences prefs = Get.find<SharedPreferences>();

  void loadPreset(String presetName) {
    final homeSettingController = Get.find<HomeSettingController>();
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
    final diffusionModelBuilder = Get.find<DiffusionModelBuilder>();
    final homeSettingController = Get.find<HomeSettingController>();
    final setting = diffusionModelBuilder.buildSetting(preserveWildcards: true, saveLastSettings: false);
    homeSettingController.savePreset(presetName, setting);
    AppSnackBar.show(
      '성공',
      '프리셋이 저장되었습니다: $presetName',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void overwritePreset(String presetName) {
    final diffusionModelBuilder = Get.find<DiffusionModelBuilder>();
    final homeSettingController = Get.find<HomeSettingController>();
    final setting = diffusionModelBuilder.buildSetting(preserveWildcards: true, saveLastSettings: false);
    homeSettingController.overwritePreset(presetName, setting);
    AppSnackBar.show(
      '성공',
      '프리셋을 덮어썼습니다: $presetName',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void loadSetting(df.DiffusionModel setting) {
    final promptController = Get.find<PromptController>();
    final modelConfigController = Get.find<ModelConfigController>();
    final diffusionModelBuilder = Get.find<DiffusionModelBuilder>();
    final homeSettingController = Get.find<HomeSettingController>();
    final homeImageController = Get.find<HomeImageController>();

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
    diffusionModelBuilder.addQualityTags = prefs.getBool("addQualityTags") ?? false;
    homeSettingController.setSettings(setting);
    
    if (modelConfigController.modelRequiresVibeEncoding(setting.model)) {
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
  }

  Future<void> getPrevSettings() async {
    final raw = prefs.getString("lastSettings");
    final diffusionModelBuilder = Get.find<DiffusionModelBuilder>();
    diffusionModelBuilder.addQualityTags = prefs.getBool("addQualityTags") ?? false;
    if (raw != null) {
      final data = jsonDecode(raw);
      try {
        final setting = df.DiffusionModel.fromJson(data);
        loadSetting(setting);
      } catch (e) {}
    }
  }
}
