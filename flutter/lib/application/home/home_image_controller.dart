import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';
import '../../domain/gen/diffusion_model.dart' as df;

import 'package:get/get.dart';
import 'dart:typed_data';

class HomeImageController extends SkeletonController {
  Rx<Uint8List> currentImageBytes = Uint8List(0).obs;
  Rx<Uint8List> generatedImageBytes = Uint8List(0).obs;
  RxList<VibeImage> vibeParseImageBytes = <VibeImage>[].obs;
  final generatedImagePath = ''.obs;

  RxList<GenerationHistoryItem> filteredGenerationHistory =
      <GenerationHistoryItem>[].obs;
  RxList<GenerationHistoryItem> generationHistory =
      <GenerationHistoryItem>[].obs;

  PageController imageViewPageController =
      PageController(initialPage: 0, keepPage: false);
  RxInt currentImageViewIndex = 0.obs;

  @override
  Future<bool> initLoading() async {
    return true; // Return true to indicate loading is complete
  }

  Future<void> saveImage() async {
    try {
      if (currentImageBytes.value.isEmpty) {
        int reversedIndex =
            generationHistory.length - imageViewPageController.page!.toInt();
        currentImageBytes.value =
            base64Decode(generationHistory[reversedIndex].imagePath);
      }
    } catch (e) {
      currentImageBytes.value = generatedImageBytes.value;
    }
    await global.saveImageWithMetadata(currentImageBytes.value);
  }

  Future<void> saveLastImage() async {
    if (generatedImageBytes.value.isEmpty) {
      Get.snackbar('오류', '저장할 이미지가 없습니다.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    await global.saveImageWithMetadata(generatedImageBytes.value);
  }

  void searchImageByPrompt(String prompt) {
    print('Searching for prompt: $prompt');
    if (prompt.isEmpty) {
      filteredGenerationHistory.value = generationHistory;
      print('Prompt is empty, showing all history.');
      return;
    }

    filteredGenerationHistory.value = generationHistory
        .where(
            (item) => item.prompt.toLowerCase().contains(prompt.toLowerCase()))
        .toList();
    print(
        'Filtered history count: ${filteredGenerationHistory.length} for prompt: $prompt');
  }

  void onPageChanged(int index) {
    currentImageViewIndex.value = index;
    int reversedIndex = generationHistory.length - index - 1; // 역순으로 인덱스 계산
    currentImageBytes.value =
        base64Decode(generationHistory[reversedIndex].imagePath);
  }

  df.DiffusionModel diffusionModelFromExifMap({
    required String defaultModel,
    required Map<String, String> textChunks,
  }) {
    // Comment 필드에서 JSON 데이터 추출
    final jsonStr = textChunks['Comment'] ?? '';
    if (jsonStr.isEmpty) {
      throw Exception('메타데이터가 없습니다.');
    }

    try {
      // JSON 문자열을 Map으로 변환
      final Map<String, dynamic> exifData = jsonDecode(jsonStr);

      // 기본값 설정
      String modelCode = textChunks['Source'] ?? defaultModel;

      print('Model Code: $modelCode');
      String model = defaultModel;
      if (modelCode.contains("B5A2A797")) {
        model = "nai-diffusion-4-5-curated";
      } else if (modelCode.contains("37442FCA")) {
        model = "nai-diffusion-4-full";
      } else if (modelCode.contains("7BCCAA2C")) {
        model = "nai-diffusion-3";
      }

      // v4_prompt와 v4_negative_prompt 데이터 추출
      final v4Prompt = exifData['v4_prompt'] ?? {};
      final v4NegativePrompt = exifData['v4_negative_prompt'] ?? {};

      // 캡션 정보 추출
      final caption = v4Prompt['caption'] ?? {};
      final baseCaption = caption['base_caption'] ?? '';
      final negativeCaption =
          v4NegativePrompt['caption']?['base_caption'] ?? '';

      // CharacterPrompts 추출 및 변환
      final List<dynamic> charCaptionsRaw = caption['char_captions'] ?? [];
      final List<dynamic> negCharCaptionsRaw =
          v4NegativePrompt['caption']?['char_captions'] ?? [];

      List<df.CharacterPrompt> characterPrompts = [];

      // 캐릭터 프롬프트 처리
      for (int i = 0; i < charCaptionsRaw.length; i++) {
        final charCaption = charCaptionsRaw[i];
        String prompt = charCaption['char_caption'] ?? '';

        // 네거티브 프롬프트 가져오기 (해당 인덱스가 존재할 경우)
        String uc = '';
        if (i < negCharCaptionsRaw.length) {
          uc = negCharCaptionsRaw[i]['char_caption'] ?? '';
        }

        // centers 정보 가져오기
        List<dynamic> centersRaw = charCaption['centers'] ?? [];
        df.Center center = df.Center(x: 0.5, y: 0.5); // 기본값

        if (centersRaw.isNotEmpty) {
          final centerData = centersRaw[0];
          center = df.Center(
            x: (centerData['x'] as num).toDouble(),
            y: (centerData['y'] as num).toDouble(),
          );
        }

        characterPrompts.add(df.CharacterPrompt(
          prompt: prompt,
          uc: uc,
          center: center,
          enabled: true,
        ));
      }

      // 시드 정보
      final int seed = exifData['seed'] ?? 999999999;

      // 기타 파라미터 추출
      final int steps = exifData['steps'] ?? 28;
      final double scale = (exifData['scale'] as num?)?.toDouble() ?? 5.0;
      final double cfgRescale =
          (exifData['cfg_rescale'] as num?)?.toDouble() ?? 0.0;
      final String sampler = exifData['sampler'] ?? 'k_euler_ancestral';
      final String noiseSchedule = exifData['noise_schedule'] ?? 'karras';
      final int width = exifData['width'] ?? 832;
      final int height = exifData['height'] ?? 1216;

      List<String> referenceImageMultiple = [];
      if (exifData['reference_image_multiple'] != null) {
        referenceImageMultiple = List<String>.from(
            exifData['reference_image_multiple'] as List<dynamic>);
      }
      List<double> referenceStrengthMultiple = [];
      if (exifData['reference_strength_multiple'] != null) {
        referenceStrengthMultiple = List<double>.from(
            exifData['reference_strength_multiple'] as List<dynamic>);
      }

      // DiffusionModel 생성 및 반환
      return df.DiffusionModel(
        input: baseCaption,
        model: model,
        action: 'generate',
        parameters: df.Parameters(
          seed: seed,
          steps: steps,
          sampler: sampler,
          width: width,
          height: height,
          scale: scale,
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
              base_caption: baseCaption,
              char_captions: charCaptionsRaw
                  .map((cc) => df.CharCaption(
                      char_caption: cc['char_caption'] ?? '',
                      centers: (cc['centers'] as List<dynamic>?)
                              ?.map((c) => df.Center(
                                    x: (c['x'] as num).toDouble(),
                                    y: (c['y'] as num).toDouble(),
                                  ))
                              .toList() ??
                          []))
                  .toList(),
            ),
            use_order: true,
            use_coords: true,
          ),
          add_original_image: false,
          reference_image_multiple: referenceImageMultiple,
          reference_strength_multiple: referenceStrengthMultiple,
          v4_negative_prompt: df.V4NegativePrompt(
            caption: df.Caption(
              base_caption: negativeCaption,
              char_captions: negCharCaptionsRaw
                  .map((cc) => df.CharCaption(
                      char_caption: cc['char_caption'] ?? '',
                      centers: (cc['centers'] as List<dynamic>?)
                              ?.map((c) => df.Center(
                                    x: (c['x'] as num).toDouble(),
                                    y: (c['y'] as num).toDouble(),
                                  ))
                              .toList() ??
                          []))
                  .toList(),
            ),
            legacy_uc: false,
          ),
          cfg_rescale: cfgRescale,
          noise_schedule: noiseSchedule,
          deliberate_euler_ancestral_bug: false,
          prefer_brownian: true,
          characterPrompts: characterPrompts,
          negative_prompt: negativeCaption,
        ),
      );
    } catch (e) {
      throw Exception('메타데이터 파싱 중 오류 발생: $e');
    }
  }

  void vibeWeightSliderChanged(int index, double value) {
    // List<Map<String, dynamic>> vibeParseImageBytes = this.vibeParseImageBytes;
    //
    // vibeParseImageBytes[index]['weight'] = value;
    // this.vibeParseImageBytes = vibeParseImageBytes;
    //
    // update();
    vibeParseImageBytes[index].weight.value = value;
  }

  void vibeStrengthSliderChanged(int index, double value) {
    vibeParseImageBytes[index].extractionStrength!.value = value;
  }

  void onRemoveVibeImage(int index) {
    if (index < 0 || index >= vibeParseImageBytes.length) {
      return;
    }
    vibeParseImageBytes.removeAt(index);
  }

  void loadVibeFromExif(df.DiffusionModel textChunks) {
    // Exif에서 Vibe 이미지 정보 로드
    final vibeImages = textChunks.parameters.reference_image_multiple;
    vibeParseImageBytes.clear();
    for (int i = 0; i < vibeImages.length; i++) {
      final vibeImage = vibeImages[i];
      final weight =
          textChunks.parameters.reference_strength_multiple.isNotEmpty
              ? textChunks.parameters.reference_strength_multiple[i]
              : 0.5; // 기본값 설정

      // VibeImage 객체 생성
      final vibeImageObj = VibeImage(
        image: null, // 이미지 데이터는 나중에 로드
        bytes: base64Decode(vibeImage),
        weight: weight.obs,
      );
      vibeImageObj.prevExtractionStrength = weight.obs;

      vibeParseImageBytes.add(vibeImageObj);
    }
  }

  void deleteImages(List<GenerationHistoryItem> selectedItems) {
    // 선택된 인덱스가 유효한지 확인
    if (selectedItems.isEmpty) {
      Get.snackbar('오류', '잘못된 선택입니다.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    for (var item in selectedItems) {
      if (generationHistory.contains(item)) {
        generationHistory.remove(item);
      }
    }

    // 현재 페이지가 삭제된 항목을 포함하고 있다면 페이지를 조정
    if (currentImageViewIndex.value >= generationHistory.length) {
      currentImageViewIndex.value = generationHistory.length - 1;
      imageViewPageController.jumpToPage(currentImageViewIndex.value);
    }
    if (generationHistory.isEmpty) {
      currentImageBytes.value = Uint8List(0);
      generatedImageBytes.value = Uint8List(0);
    } else {
      // 마지막 이미지로 이동
      int lastIndex = generationHistory.length - 1;
      currentImageBytes.value =
          base64Decode(generationHistory[lastIndex].imagePath);
      imageViewPageController.jumpToPage(lastIndex);
    }
  }
}

class GenerationHistoryItem {
  final String imagePath;
  final String prompt;

  GenerationHistoryItem({required this.imagePath, required this.prompt});
}

class VibeImage {
  final Uint8List? image;
  Uint8List? bytes;
  RxDouble weight;
  RxDouble? extractionStrength;
  RxDouble? prevExtractionStrength = 0.0.obs;

  VibeImage({
    this.image,
    this.bytes,
    required this.weight,
    this.extractionStrength,
    this.prevExtractionStrength,
  });
}
