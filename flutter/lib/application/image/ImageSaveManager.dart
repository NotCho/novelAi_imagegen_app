import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class ExifPreservingImageSaver {
  static final ExifPreservingImageSaver _instance =
  ExifPreservingImageSaver._internal();

  factory ExifPreservingImageSaver() => _instance;

  ExifPreservingImageSaver._internal();

  /// EXIF 메타데이터를 보존하면서 이미지 저장
  ///
  Future<bool> saveImageWithExif(Uint8List imageBytes,
      {String? customName}) async {
    try {
      // 웹인지 확인
      if (kIsWeb) {} else {
        final hasPermission = await _checkPermissions();
        if (!hasPermission) return false;
      }

      // 2. 임시 파일로 저장 (EXIF 보존)
      final tempFile = await _createTempFile(imageBytes, customName);

      // 3. MediaStore를 통해 갤러리에 저장 (Android) 또는 Photos 프레임워크 사용 (iOS)
      final success = await _saveToGalleryPreservingMetadata(tempFile);

      // 4. 임시 파일 정리
      await tempFile.delete();

      if (success) {
        _showSuccessMessage();
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

  Future<bool> saveMultipleImagesWithExif(List<Uint8List> imageBytesList, {
    String? customName,
  }) async {
    try {
      // 1. 권한 확인
      final hasPermission = await _checkPermissions();
      if (!hasPermission) return false;

      for (var imageBytes in imageBytesList) {
        print('이미지 바이트 길이: ${imageBytes.length}');
        // 2. 임시 파일로 저장 (EXIF 보존)
        final tempFile = await _createTempFile(imageBytes, customName);

        // 3. MediaStore를 통해 갤러리에 저장 (Android) 또는 Photos 프레임워크 사용 (iOS)
        final success = await _saveToGalleryPreservingMetadata(tempFile);
        print('이미지 저장 성공 여부: $success');

        // 4. 임시 파일 정리
        await tempFile.delete();

        if (!success) {
          _showErrorMessage('이미지 저장에 실패했습니다');
          return false;
        }
      }

      _showSuccessMessage();
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
  Future<File> _createTempFile(Uint8List imageBytes, String? customName) async {
    final tempDir = await getTemporaryDirectory();
    final fileName =
        customName ?? "image_${DateTime
            .now()
            .millisecondsSinceEpoch}";
    final filePath = '${tempDir.path}/$fileName.png';

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

      return result != null && result
          .toString()
          .isNotEmpty;
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

      return result != null && result
          .toString()
          .isNotEmpty;
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
  void _showSuccessMessage() {
    Get.snackbar(
      '저장 완료',
      '이미지가 메타데이터와 함께 갤러리에 저장되었습니다',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
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
}
