import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';
import 'package:naiapp/application/home/home_generation_controller.dart';
import 'package:naiapp/domain/gen/i_novelAI_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

import '../../domain/gen/diffusion_model.dart' as df;
import '../../infra/service/webp_image_parser.dart';

class HomeImageController extends SkeletonController {
  final INovelAIRepository _novelAIRepository = Get.find<INovelAIRepository>();

  final Map<String, Uint8List> imageCache = {};
  Rx<Uint8List> loadedImageBytes = Uint8List(0).obs;
  df.DiffusionModel? loadedImageModel;
  RxString loadImageStatus = "이미지를 불러온 후 체크박스 설정 가능".obs;
  RxBool isExifChecked = false.obs;

  RxMap<String, bool> loadImageOptions = {
    "긍정 프롬프트": true,
    "부정 프롬프트": true,
    "캐릭터": true,
    '세팅': true,
    'Vibe': false,
    '시드': false
  }.obs;

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

  void onImageGenerated(String base64Str, Uint8List imageBytes, String prompt) {
    generatedImagePath.value = base64Str;
    generatedImageBytes.value = imageBytes;
    imageCache[base64Str] = imageBytes;
    generationHistory.add(
      GenerationHistoryItem(imagePath: base64Str, prompt: prompt),
    );
  }

  Future<void> getVibeBytes() async {
    final generationController = Get.find<HomeGenerationController>();
    Either<String, List<VibeImage>> result = await _novelAIRepository.vibeParse(
        vibeParseImageBytes, generationController.usingModel.value);
    result.fold(
      (l) {
        print(l);
        Get.snackbar('오류', 'Vibe 이미지 파싱 중 오류가 발생했습니다: $l',
            backgroundColor: Colors.red, colorText: Colors.white);
      },
      (r) {},
    );
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
    vibeParseImageBytes.add(vibeImage);
    Get.back();
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

  Future<void> checkImageMetadata(Uint8List imageBytes) async {
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
            final generationController = Get.find<HomeGenerationController>();
            loadedImageModel = diffusionModelFromExifMap(
                defaultModel: generationController.usingModel.value, textChunks: textChunks);
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

  Future<void> getImageFromGallery() async {
    try {
      final result = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (result != null) {
        print('갤러리에서 이미지 선택: ${result.path}');

        try {
          final file = File(result.path);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();

            checkImageMetadata(bytes);

            imageCache[base64Encode(bytes)] = bytes;
            loadedImageBytes.value = bytes;

            return;
          }
        } catch (e) {
          print('File API 접근 실패, 대체 방법 시도: $e');
        }

        try {
          final bytes = await result.readAsBytes();
          print('readAsBytes로 이미지 로드 성공: ${bytes.length} 바이트');

          checkImageMetadata(bytes);
          imageCache[base64Encode(bytes)] = bytes;
          loadedImageBytes.value = bytes;

          return;
        } catch (e) {
          print('readAsBytes 실패, 대체 방법 시도: $e');
        }

        try {
          final tempDir = await getTemporaryDirectory();
          final tempPath =
              '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.png';
          final tempFile = File(tempPath);

          await File(result.path).copy(tempPath);

          if (await tempFile.exists()) {
            final bytes = await tempFile.readAsBytes();

            checkImageMetadata(bytes);
            imageCache[base64Encode(bytes)] = bytes;
            loadedImageBytes.value = bytes;

            await tempFile.delete();
            return;
          }
        } catch (e) {
          print('임시 파일 복사 방식 실패: $e');
        }

        try {
          final imgBytes = await result.readAsBytes();
          final img.Image? decodedImage = img.decodeImage(imgBytes);

          if (decodedImage != null) {
            final reEncodedBytes = img.encodePng(decodedImage);
            print('이미지 재인코딩 성공: ${reEncodedBytes.length} 바이트');

            generatedImageBytes.value =
                Uint8List.fromList(reEncodedBytes);
            generatedImagePath.value =
                base64Encode(reEncodedBytes);
            imageCache[base64Encode(reEncodedBytes)] =
                Uint8List.fromList(reEncodedBytes);
            generationHistory.add(
              GenerationHistoryItem(
                  imagePath: base64Encode(reEncodedBytes), prompt: ''),
            );

            return;
          }
        } catch (e) {
          print('이미지 재인코딩 실패: $e');
        }

        Get.snackbar('오류', '이미지를 로드할 수 없습니다.',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('갤러리에서 이미지 로드 중 오류: $e');
      Get.snackbar('오류', '갤러리에서 이미지를 불러오는 중 문제가 발생했습니다: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
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
