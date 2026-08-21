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
import '../core/skeleton_controller.dart';
import '../../view/core/util/app_snackbar.dart';

class HomePageController extends SkeletonController {
  late final HomeImageController homeImageController =
      Get.find<HomeImageController>();
  late final HomeSettingController homeSettingController =
      Get.find<HomeSettingController>();
  late final AutoGenerationController autoGenerationController =
      Get.find<AutoGenerationController>();
  late final DirectorToolController directorToolController =
      Get.find<DirectorToolController>();
  late final PromptController promptController = Get.find<PromptController>();
  late final ModelConfigController modelConfigController =
      Get.find<ModelConfigController>();
  late final ImageGenerationController imageGenerationController =
      Get.find<ImageGenerationController>();
  late final ImageLoadController imageLoadController =
      Get.find<ImageLoadController>();

  final SharedPreferences prefs = Get.find<SharedPreferences>();

  RxBool expandHistory = false.obs;
  final isPanelExpanded = true.obs;
  RxBool floatingButtonExpanded = false.obs;
  final hideSeed = false.obs;
  final liquidGlassMode = false.obs;
  final liquidGlassBlur = 1.0.obs;
  final liquidGlassRefraction = 1.5.obs;
  final liquidGlassAberration = 0.0.obs;
  final liquidGlassThickness = 27.0.obs;
  final liquidGlassLightIntensity = 1.0.obs;
  final liquidGlassSaturation = 1.6.obs;

  Future<void> setHideSeed(bool value) async {
    hideSeed.value = value;
    await prefs.setBool("hideSeed", value);
  }

  Future<void> setLiquidGlassBlur(double value) async {
    liquidGlassBlur.value = value;
    await prefs.setDouble("liquidGlassBlur", value);
  }

  Future<void> setLiquidGlassRefraction(double value) async {
    liquidGlassRefraction.value = value;
    await prefs.setDouble("liquidGlassRefraction", value);
  }

  Future<void> setLiquidGlassAberration(double value) async {
    liquidGlassAberration.value = value;
    await prefs.setDouble("liquidGlassAberration", value);
  }

  Future<void> setLiquidGlassThickness(double value) async {
    liquidGlassThickness.value = value;
    await prefs.setDouble("liquidGlassThickness", value);
  }

  Future<void> setLiquidGlassLightIntensity(double value) async {
    liquidGlassLightIntensity.value = value;
    await prefs.setDouble("liquidGlassLightIntensity", value);
  }

  Future<void> setLiquidGlassSaturation(double value) async {
    liquidGlassSaturation.value = value;
    await prefs.setDouble("liquidGlassSaturation", value);
  }

  @override
  Future<bool> initLoading() async {
    hideSeed.value = prefs.getBool("hideSeed") ?? false;
    liquidGlassMode.value = prefs.getBool("liquidGlassMode") ?? false;
    liquidGlassBlur.value = prefs.getDouble("liquidGlassBlur") ?? 1.0;
    liquidGlassRefraction.value =
        prefs.getDouble("liquidGlassRefraction") ?? 1.5;
    liquidGlassAberration.value =
        prefs.getDouble("liquidGlassAberration") ?? 0.0;
    liquidGlassThickness.value =
        prefs.getDouble("liquidGlassThickness") ?? 27.0;
    liquidGlassLightIntensity.value =
        prefs.getDouble("liquidGlassLightIntensity") ?? 1.0;
    liquidGlassSaturation.value =
        prefs.getDouble("liquidGlassSaturation") ?? 1.6;
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
            modelConfigController.noiseScheduleOptions
                    .contains(setting.parameters.noise_schedule)
                ? setting.parameters.noise_schedule
                : modelConfigController.noiseScheduleOptions.first;

        homeSettingController.seedController.text =
            homeSettingController.randomSeed.value
                ? ""
                : setting.parameters.seed.toString();

        imageGenerationController
            .setAutoSave(prefs.getBool("addQualityTags") ?? false);
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
      } catch (e) {}
    }

    final persistentToken = prefs.getString("NOVEL_AI_PERSISTENT_TOKEN");
    if (persistentToken == null || persistentToken.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.toLogin();
      });
      return true;
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
