import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:dartz/dartz.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';
import 'package:naiapp/infra/gen/novelAI_repository.dart';
import 'package:naiapp/domain/gen/diffusion_model.dart' as df;
import 'package:naiapp/domain/gen/i_novelAI_repository.dart';
import 'package:naiapp/view/core/util/app_snackbar.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';
import 'package:naiapp/application/home/auto_generation_controller.dart';
import 'package:naiapp/application/home/diffusion_model_builder.dart';
import 'package:naiapp/application/home/model_config_controller.dart';
import 'package:naiapp/application/image/image_page_controller.dart';
import 'package:naiapp/main.dart'; // startCallback

class ImageGenerationController extends SkeletonController {
  late final INovelAIRepository _novelAIRepository = Get.find<INovelAIRepository>();
  late final HomeImageController homeImageController = Get.find<HomeImageController>();
  late final HomeSettingController homeSettingController = Get.find<HomeSettingController>();
  late final AutoGenerationController autoGenerationController = Get.find<AutoGenerationController>();
  late final ModelConfigController modelConfigController = Get.find<ModelConfigController>();
  late final DiffusionModelBuilder diffusionModelBuilder = Get.find<DiffusionModelBuilder>();

  final isGenerating = false.obs;
  final RxBool autoSave = false.obs;
  final RxInt anlasLeft = (-1).obs;

  @override
  Future<bool> initLoading() async {
    await getAnlasRemaining();
    return true;
  }

  static const Map<String, String> posMap = {
    "nai-diffusion-4-full": ", no text, best quality, very aesthetic, absurdres",
    "nai-diffusion-4-5-curated": "location, masterpiece, no text, -0.8::feet::, rating:general"
  };

  Future<void> setAutoSave(bool value) async {
    autoSave.value = value;
  }

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

  Future<void> getVibeBytes() async {
    if (!modelConfigController.supportsVibeTransfer ||
        homeImageController.vibeParseImageBytes.isEmpty) {
      return;
    }
    Either<String, List<VibeImage>> result = await _novelAIRepository.vibeParse(
        homeImageController.vibeParseImageBytes, modelConfigController.usingModel.value);
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

  void generateImage() async {
    String positiveDef = posMap[modelConfigController.usingModel.value] ?? '';
    diffusionModelBuilder.updateQualityTags(positiveDef, diffusionModelBuilder.negativeDef);

    if (isGenerating.value) return;

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

    df.DiffusionModel setting = diffusionModelBuilder.buildSetting();

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
        
        homeImageController.cacheImage(base64Str, imageBytes);

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
          callback: startCallback,
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
}
