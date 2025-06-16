import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/core/router.dart';

import '../image/ImageSaveManager.dart';

class GlobalController extends GetxController {
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set isLoading(bool value) => _isLoading.value = value;

  String _jwtToken = '';
  final router = Get.find<ISkeletonRouter>();

  set jwtToken(String jwtToken) {
    _jwtToken = jwtToken;
  }

  String get jwtToken => _jwtToken;

  Future<void> tryLogin() async {}

  Future<void> pageInitLoadingFail() async {
    Get.defaultDialog(
      title: '알림',
      middleText: '페이지를 불러오는데 실패했습니다.',
      confirm: TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('확인'),
      ),
    );
  }


  Future<void> saveMultipleImages(List<Uint8List> imageBytesList) async {
      await ExifPreservingImageSaver().saveMultipleImagesWithExif(imageBytesList);

  }

  Future<void> saveImageWithMetadata(Uint8List imageBytes) async {
    final imageName = "novelai_${DateTime.now().millisecondsSinceEpoch}";
    await ExifPreservingImageSaver()
        .saveImageWithExif(imageBytes, customName: imageName);
  }

  Map<String, String> extractPngTextChunks(Uint8List bytes) {
    const pngSignatureLength = 8;
    final textChunks = <String, String>{};
    int i = pngSignatureLength;

    while (i + 8 < bytes.length) {
      // 청크 길이 (4바이트 빅엔디안)
      final length = (bytes[i] << 24) |
          (bytes[i + 1] << 16) |
          (bytes[i + 2] << 8) |
          (bytes[i + 3]);
      final chunkType = String.fromCharCodes(bytes.sublist(i + 4, i + 8));
      final dataStart = i + 8;
      final dataEnd = dataStart + length;

      if (dataEnd > bytes.length) break;

      if (chunkType == 'tEXt') {
        final chunkData = bytes.sublist(dataStart, dataEnd);
        // 키워드와 텍스트는 널(0x00)로 구분
        final nullIndex = chunkData.indexOf(0);
        if (nullIndex != -1) {
          final key = utf8.decode(chunkData.sublist(0, nullIndex));
          final value = utf8.decode(chunkData.sublist(nullIndex + 1));
          textChunks[key] = value;
        }
      }

      // CRC(4바이트)까지 건너뛰기
      i = dataEnd + 4;
    }

    return textChunks;
  }
}
