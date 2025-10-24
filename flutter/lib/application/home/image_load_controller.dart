import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/gen/diffusion_model.dart' as df;
import '../../infra/service/webp_image_parser.dart';

/// 이미지 로드 및 메타데이터 파싱을 담당하는 컨트롤러
///
/// 책임:
/// - 갤러리에서 이미지 선택
/// - 이미지 메타데이터(EXIF) 파싱
/// - 메타데이터에서 설정 추출 및 적용
/// - 이미지 로드 상태 관리
class ImageLoadController extends GetxController {
  final HomeImageController homeImageController =
      Get.find<HomeImageController>();
  final HomeSettingController homeSettingController =
      Get.find<HomeSettingController>();

  // 로드된 이미지 데이터
  Rx<Uint8List> loadedImageBytes = Uint8List(0).obs;
  df.DiffusionModel? loadedImageModel;

  // 로드 상태
  RxString loadImageStatus = "이미지를 불러온 후 체크박스 설정 가능".obs;
  RxBool isExifChecked = false.obs;

  // 로드 옵션
  RxMap<String, bool> loadImageOptions = {
    "긍정 프롬프트": true,
    "부정 프롬프트": true,
    "캐릭터": true,
    '세팅': true,
    'Vibe': false,
    '시드': false
  }.obs;

  // 이미지 캐시
  final Map<String, Uint8List> imageCache = {};

  /// 갤러리에서 이미지 선택
  Future<void> getImageFromGallery() async {
    try {
      final result = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (result != null) {
        print('갤러리에서 이미지 선택: ${result.path}');

        // 1. File API로 접근 시도
        try {
          final file = File(result.path);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            await _checkImageMetadata(bytes);
            imageCache[base64Encode(bytes)] = bytes;
            loadedImageBytes.value = bytes;
            return;
          }
        } catch (e) {
          print('File API 접근 실패, 대체 방법 시도: $e');
        }

        // 2. readAsBytes 방식 시도
        try {
          final bytes = await result.readAsBytes();
          print('readAsBytes로 이미지 로드 성공: ${bytes.length} 바이트');
          await _checkImageMetadata(bytes);
          imageCache[base64Encode(bytes)] = bytes;
          loadedImageBytes.value = bytes;
          return;
        } catch (e) {
          print('readAsBytes 실패, 대체 방법 시도: $e');
        }

        // 3. 복사 후 접근 시도
        try {
          final tempDir = await getTemporaryDirectory();
          final tempPath =
              '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.png';
          final tempFile = File(tempPath);

          await File(result.path).copy(tempPath);

          if (await tempFile.exists()) {
            final bytes = await tempFile.readAsBytes();
            await _checkImageMetadata(bytes);
            imageCache[base64Encode(bytes)] = bytes;
            loadedImageBytes.value = bytes;
            await tempFile.delete();
            return;
          }
        } catch (e) {
          print('임시 파일 복사 방식 실패: $e');
        }

        // 4. 이미지 디코딩 후 다시 인코딩
        try {
          final imgBytes = await result.readAsBytes();
          final img.Image? decodedImage = img.decodeImage(imgBytes);

          if (decodedImage != null) {
            final reEncodedBytes = img.encodePng(decodedImage);
            print('이미지 재인코딩 성공: ${reEncodedBytes.length} 바이트');

            final bytes = Uint8List.fromList(reEncodedBytes);
            await _checkImageMetadata(bytes);
            imageCache[base64Encode(bytes)] = bytes;
            loadedImageBytes.value = bytes;
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

  /// 이미지 메타데이터 확인 및 파싱
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
            final homePageController = Get.find<HomePageController>();
            loadedImageModel = homeImageController.diffusionModelFromExifMap(
                defaultModel: homePageController.usingModel.value,
                textChunks: textChunks);
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

  /// 이미지에서 설정 불러오기
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

    final homePageController = Get.find<HomePageController>();

    // 선택된 내용만 적용하기
    if (loadImageOptions['긍정 프롬프트']!) {
      homePageController.positivePromptController.text =
          loadedImageModel!.input;
    }

    if (loadImageOptions['부정 프롬프트']!) {
      homePageController.negativePromptController.text =
          loadedImageModel!.parameters.v4_negative_prompt.caption.base_caption;
    }

    if (loadImageOptions['세팅']!) {
      // 세팅 관련 값 적용
      homePageController.usingModel.value = loadedImageModel!.model;
      homeSettingController.samplingSteps.value =
          loadedImageModel!.parameters.steps;

      homeSettingController.setSettings(loadedImageModel!);

      // 노이즈 스케줄 설정
      homePageController.selectedNoiseSchedule.value = homePageController
              .noiseScheduleOptions
              .contains(loadedImageModel!.parameters.noise_schedule)
          ? loadedImageModel!.parameters.noise_schedule
          : homePageController.noiseScheduleOptions.first;
    }

    if (loadImageOptions['캐릭터']!) {
      // 캐릭터 프롬프트 적용
      homePageController.characterPrompts.clear();
      for (var i = 0;
          i < loadedImageModel!.parameters.characterPrompts.length;
          i++) {
        homePageController.characterPrompts.add({
          'prompt': loadedImageModel!.parameters.characterPrompts[i],
          'positive': TextEditingController(
              text: loadedImageModel!.parameters.characterPrompts[i].prompt),
          'negative': TextEditingController(
              text: loadedImageModel!.parameters.characterPrompts[i].uc),
        });
      }
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

  /// 이미지 다이얼로그 초기화
  void clearImageDialog() {
    loadedImageBytes.value = Uint8List(0);
    loadImageStatus.value = "이미지를 불러온 후 체크박스 설정 가능";
    isExifChecked.value = false;
  }

  /// 이미지 로드 취소
  void cancelImageLoad() {
    Get.back();
    clearImageDialog();
  }
}
