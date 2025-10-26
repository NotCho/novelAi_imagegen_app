import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/infra/service/webp_image_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class ExifPreservingImageSaver {
  static final ExifPreservingImageSaver _instance =
  ExifPreservingImageSaver._internal();

  factory ExifPreservingImageSaver() => _instance;

  ExifPreservingImageSaver._internal();

  /// EXIF 메타데이터를 보존하면서 이미지 저장
  /// PNG는 EXIF Comment에, WebP는 알파채널에 저장
  Future<bool> saveImageWithExif(
      Uint8List imageBytes, {
        String? customName,
        required bool saveInPng,
        Map<String, String>? metadata, // 추가된 매개변수
      }) async {
    try {
      // 웹인지 확인
      if (kIsWeb) {} else {
        final hasPermission = await _checkPermissions();
        if (!hasPermission) return false;
      }

      Uint8List finalImageBytes = imageBytes;

      // 메타데이터 삽입 처리
      if (metadata != null && metadata.isNotEmpty) {
        if (saveInPng) {
          // PNG는 tEXt 청크에 삽입
          print('PNG 형식으로 메타데이터와 함께 저장');
          final jsonText = jsonEncode(metadata);
          final modifiedBytes = WebPMetadataEmbedder.addPngTextChunk(
              imageBytes,
              'Comment',
              jsonText
          );

          if (modifiedBytes != null) {
            finalImageBytes = modifiedBytes;
            print('PNG 메타데이터 삽입 성공!');
          } else {
            print('PNG 메타데이터 삽입 실패, 알파채널 방식 시도');
            final alphaResult = WebPMetadataEmbedder.embedMetadataInWebP(imageBytes, metadata);
            if (alphaResult != null) {
              finalImageBytes = alphaResult;
              print('PNG 알파채널 메타데이터 삽입 성공!');
            } else {
              _showWarningMessage('메타데이터 삽입에 실패했지만 이미지는 저장됩니다');
            }
          }
        } else {
          // WebP는 청크 방식 우선, 실패시 알파채널 방식
          print('WebP 형식으로 메타데이터와 함께 저장');

          // 방법 1: 청크 방식
          var modifiedBytes = WebPChunkEmbedder.embedMetadataInWebPChunk(imageBytes, metadata);
          if (modifiedBytes != null) {
            finalImageBytes = modifiedBytes;
            print('WebP 청크 메타데이터 삽입 성공!');
          } else {
            print('WebP 청크 방식 실패, 알파채널 방식 시도');

            // 방법 2: 알파채널 방식
            modifiedBytes = WebPMetadataEmbedder.embedMetadataInWebP(imageBytes, metadata);

            if (modifiedBytes != null) {
              finalImageBytes = modifiedBytes;
              print('WebP 알파채널 메타데이터 삽입 성공!');
            } else {
              print('WebP 메타데이터 삽입 실패, 원본으로 저장');
              _showWarningMessage('메타데이터 삽입에 실패했지만 이미지는 저장됩니다');
            }
          }
        }
      }

      // 2. 임시 파일로 저장
      final tempFile = await _createTempFile(
          finalImageBytes,
          customName,
          saveInPng ? 'png' : 'webp'
      );

      // 3. MediaStore를 통해 갤러리에 저장
      final success = await _saveToGalleryPreservingMetadata(tempFile);

      // 4. 임시 파일 정리
      await tempFile.delete();

      if (success) {
        _showSuccessMessage(saveInPng ? 'PNG' : 'WebP');
        return true;
      } else {
        _showErrorMessage('이미지 저장에 실패했습니다');
        return false;
      }
    } catch (e) {
      _showErrorMessage('이미지 저장 중 오류: $e');
      return false;
    }
  }

  Future<bool> saveMultipleImagesWithExif(
      List<Uint8List> imageBytesList, {
        String? customName,
        required bool saveInPng,
        List<Map<String, String>>? metadataList, // 각 이미지별 메타데이터
      }) async {
    try {
      // 1. 권한 확인
      final hasPermission = await _checkPermissions();
      if (!hasPermission) return false;

      for (int i = 0; i < imageBytesList.length; i++) {
        final imageBytes = imageBytesList[i];
        final metadata = (metadataList != null && i < metadataList.length)
            ? metadataList[i]
            : null;

        print('이미지 ${i + 1}/${imageBytesList.length} 처리 중...');
        print('이미지 바이트 길이: ${imageBytes.length}');

        Uint8List finalImageBytes = imageBytes;

        // 메타데이터 삽입 처리
        if (metadata != null && metadata.isNotEmpty) {
          if (saveInPng) {
            // PNG는 tEXt 청크에 삽입
            print('이미지 ${i + 1}: PNG 메타데이터 삽입');
            final jsonText = jsonEncode(metadata);
            final modifiedBytes = WebPMetadataEmbedder.addPngTextChunk(
                imageBytes,
                'Comment',
                jsonText
            );

            if (modifiedBytes != null) {
              finalImageBytes = modifiedBytes;
              print('이미지 ${i + 1}: PNG 메타데이터 삽입 성공');
            } else {
              // PNG 실패시 알파채널 시도
              final alphaResult = WebPMetadataEmbedder.embedMetadataInWebP(imageBytes, metadata);
              if (alphaResult != null) {
                finalImageBytes = alphaResult;
                print('이미지 ${i + 1}: PNG 알파채널 메타데이터 삽입 성공');
              } else {
                print('이미지 ${i + 1}: PNG 메타데이터 삽입 실패');
              }
            }
          } else {
            // WebP는 청크 방식 우선
            print('이미지 ${i + 1}: WebP 메타데이터 삽입');

            var modifiedBytes = WebPMetadataEmbedder.embedMetadataInWebP(imageBytes, metadata);

            if (modifiedBytes != null) {
              finalImageBytes = modifiedBytes;
              print('이미지 ${i + 1}: WebP 청크 메타데이터 삽입 성공');
            } else {
              // 청크 방식 실패시 간단한 방식 시도
              modifiedBytes = WebPMetadataEmbedder.embedMetadataInWebP(imageBytes, metadata);

              if (modifiedBytes != null) {
                finalImageBytes = modifiedBytes;
                print('이미지 ${i + 1}: WebP 알파채널 메타데이터 삽입 성공');
              } else {
                print('이미지 ${i + 1}: WebP 메타데이터 삽입 실패');
              }
            }
          }
        }

        // 2. 임시 파일로 저장
        final fileName = customName != null
            ? "${customName}_${i + 1}"
            : "image_${DateTime.now().millisecondsSinceEpoch}_${i + 1}";

        final tempFile = await _createTempFile(
            finalImageBytes,
            fileName,
            saveInPng ? 'png' : 'webp'
        );

        // 3. 갤러리에 저장
        final success = await _saveToGalleryPreservingMetadata(tempFile);
        print('이미지 ${i + 1} 저장 성공 여부: $success');

        // 4. 임시 파일 정리
        await tempFile.delete();

        if (!success) {
          _showErrorMessage('이미지 ${i + 1} 저장에 실패했습니다');
          return false;
        }
      }

      _showSuccessMessage(saveInPng ? 'PNG' : 'WebP', isMultiple: true);
      return true;
    } catch (e) {
      _showErrorMessage('이미지 저장 중 오류: $e');
      return false;
    }
  }

  /// 권한 확인 및 요청
  Future<bool> _checkPermissions() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      PermissionStatus status;

      if (sdkInt >= 33) {
        // Android 13+
        status = await Permission.photos.status;
        if (status.isDenied) {
          status = await Permission.photos.request();
        }
      } else {
        // Android 12 이하
        status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
      }

      if (status.isPermanentlyDenied) {
        await _showPermissionDialog();
        return false;
      }

      return status.isGranted;
    } catch (e) {
      print('권한 확인 오류: $e');
      return false;
    }
  }

  /// 임시 파일 생성 (원본 바이트 그대로 저장)
  Future<File> _createTempFile(
      Uint8List imageBytes,
      String? customName,
      String extension,
      ) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = customName ?? "image_${DateTime.now().millisecondsSinceEpoch}";
    final filePath = '${tempDir.path}/$fileName.$extension';

    final file = File(filePath);
    await file.writeAsBytes(imageBytes); // 원본 바이트 그대로 저장

    return file;
  }

  /// 메타데이터 보존하면서 갤러리에 저장
  Future<bool> _saveToGalleryPreservingMetadata(File imageFile) async {
    try {
      // ImageGallerySaverPlus를 사용해서 파일 직접 저장
      // 이 방법이 메타데이터를 가장 잘 보존함
      final result = await ImageGallerySaverPlus.saveFile(
        imageFile.path,
        name: imageFile.path
            .split('/')
            .last
            .split('.')
            .first,
        isReturnPathOfIOS: false,
      );

      return result != null && result.toString().isNotEmpty;
    } catch (e) {
      print('갤러리 저장 오류: $e');

      // 대체 방법: MediaStore 직접 사용 (Android)
      return await _fallbackSaveMethod(imageFile);
    }
  }

  /// 대체 저장 방법
  Future<bool> _fallbackSaveMethod(File imageFile) async {
    try {
      // 파일을 바이트로 읽어서 다시 저장
      final bytes = await imageFile.readAsBytes();

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: imageFile.path
            .split('/')
            .last
            .split('.')
            .first,
      );

      return result != null && result.toString().isNotEmpty;
    } catch (e) {
      print('대체 저장 방법 실패: $e');
      return false;
    }
  }

  /// 권한 설정 다이얼로그
  Future<void> _showPermissionDialog() async {
    Get.dialog(
      AlertDialog(
        title: const Text('권한 설정 필요'),
        content: const Text('이미지를 저장하려면 사진 접근 권한이 필요합니다.\n'
            '설정에서 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('나중에'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  /// 성공 메시지
  void _showSuccessMessage(String format, {bool isMultiple = false}) {
    final message = isMultiple
        ? '모든 이미지가 $format 형식으로 갤러리에 저장되었습니다'
        : '이미지가 $format 형식으로 갤러리에 저장되었습니다';

    Get.snackbar(

      '저장 완료',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(milliseconds: 1000),
    );
  }

  /// 경고 메시지
  void _showWarningMessage(String message) {
    Get.snackbar(
      '경고',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  /// 에러 메시지
  void _showErrorMessage(String message) {
    Get.snackbar(
      '오류',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// WebP 메타데이터 테스트용 메서드
  Future<void> testWebPMetadata(Uint8List imageBytes, Map<String, String> metadata) async {
    try {
      print('=== WebP 메타데이터 테스트 시작 ===');

      // 1. 메타데이터 삽입
      final modifiedBytes = WebPMetadataEmbedder.embedMetadataInWebP(imageBytes, metadata);
      if (modifiedBytes == null) {
        print('테스트 실패: 메타데이터 삽입 불가');
        return;
      }

      print('테스트: 메타데이터 삽입 성공');

      // 2. 삽입된 메타데이터 추출 테스트
      final extractedMetadata = WebPMetadataParser.extractMetadata(modifiedBytes);
      if (extractedMetadata == null) {
        print('테스트 실패: 메타데이터 추출 불가');
        return;
      }

      print('테스트: 메타데이터 추출 성공');
      print('원본 메타데이터: $metadata');
      print('추출된 메타데이터: $extractedMetadata');

      // 3. 데이터 일치 확인
      bool isMatch = true;
      metadata.forEach((key, value) {
        if (extractedMetadata[key] != value) {
          print('불일치 발견: $key -> 원본: $value, 추출: ${extractedMetadata[key]}');
          isMatch = false;
        }
      });

      if (isMatch) {
        print('✅ 테스트 성공: 메타데이터 완벽 일치!');
      } else {
        print('❌ 테스트 실패: 메타데이터 불일치');
      }

      print('=== WebP 메타데이터 테스트 완료 ===');

    } catch (e) {
      print('테스트 오류: $e');
    }
  }
}