import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';

// 전역 이미지 캐시 매니저 (싱글톤)
class ImageCacheManager extends GetxService {
  static ImageCacheManager get instance => Get.find<ImageCacheManager>();

  // 이미지 캐시맵 - base64 string을 키로 사용
  final Map<String, Uint8List> _imageCache = {};

  // 캐시 크기 제한 (메모리 관리용)
  static const int maxCacheSize = 1000;

  // 이미지 가져오기 (캐시 우선, 없으면 디코딩)
  Uint8List getImageBytes(String base64Data) {
    if (_imageCache.containsKey(base64Data)) {
      return _imageCache[base64Data]!;
    }

    // 캐시에 없으면 디코딩하고 캐시에 추가
    try {
      final decoded = base64Decode(base64Data);

      // 캐시 크기 체크해서 너무 크면 오래된 것부터 삭제
      if (_imageCache.length >= maxCacheSize) {
        _clearOldCache();
      }

      _imageCache[base64Data] = decoded;
      return decoded;
    } catch (e) {
      rethrow;
    }
  }

  // 여러 이미지 미리 캐싱
  Future<void> preloadImages(List<String> base64DataList) async {
    for (int i = 0; i < base64DataList.length; i++) {
      final base64Data = base64DataList[i];

      if (!_imageCache.containsKey(base64Data)) {
        try {
          final decoded = base64Decode(base64Data);

          // 캐시 크기 체크
          if (_imageCache.length >= maxCacheSize) {
            _clearOldCache();
          }

          _imageCache[base64Data] = decoded;

          // 10개마다 yield로 UI 블록 방지
          if (i % 10 == 0) {
            await Future.delayed(Duration.zero);
          }
        } catch (e) {
        }
      }
    }

  }

  // 오래된 캐시 정리 (LRU 비슷하게, 간단버전)
  void _clearOldCache() {
    if (_imageCache.length > maxCacheSize * 0.8) {
      final keysToRemove = _imageCache.keys.take(100).toList();
      for (final key in keysToRemove) {
        _imageCache.remove(key);
      }
    }
  }

  // 특정 이미지 캐시 삭제
  void removeFromCache(String base64Data) {
    _imageCache.remove(base64Data);
  }

  // 전체 캐시 정리
  void clearAllCache() {
    _imageCache.clear();
  }

  // 캐시 상태 확인
  int get cacheSize => _imageCache.length;
  bool isImageCached(String base64Data) => _imageCache.containsKey(base64Data);
}