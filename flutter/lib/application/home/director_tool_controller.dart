import 'dart:math' as math;
import 'dart:typed_data';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:naiapp/view/core/util/app_snackbar.dart';

class DirectorToolController extends GetxController {
  // 참조 이미지
  Rx<Uint8List?> referenceImage = Rx<Uint8List?>(null);
  RxString referenceImageBase64 = ''.obs;

  // Style Aware 체크박스
  RxBool styleAware = false.obs;

  // Fidelity 슬라이더 (0.0 ~ 1.0)
  RxDouble fidelity = 1.0.obs;

  /// 상단 이미지 불러오기 다이얼로그에서 전달받은 이미지를 설정
  bool setReferenceImage(Uint8List bytes) {
    if (bytes.isEmpty) {
      AppSnackBar.show('오류', '이미지를 선택해주세요.');
      return false;
    }

    try {
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage != null) {
        final img.Image processedImage = _prepareDirectorImage(decodedImage);
        final List<int> pngBytes = img.encodePng(processedImage, level: 9);
        final Uint8List processedBytes = Uint8List.fromList(pngBytes);

        referenceImage.value = processedBytes;
        referenceImageBase64.value = base64Encode(pngBytes);

      } else {
        // 디코딩이 되지 않으면 원본 그대로 사용
        referenceImage.value = bytes;
        referenceImageBase64.value = base64Encode(bytes);
      }

      return true;
    } catch (e) {
      AppSnackBar.show('오류', '이미지를 불러올 수 없습니다: $e');
      return false;
    }
  }

  // 이미지 제거
  void removeImage() {
    referenceImage.value = null;
    referenceImageBase64.value = '';
  }

  // Style Aware 토글
  void toggleStyleAware() {
    styleAware.value = !styleAware.value;
  }

  // Fidelity 설정
  void setFidelity(double value) {
    fidelity.value = value;
  }

  // base_caption 값 가져오기
  String getBaseCaption() {
    return styleAware.value ? 'character&style' : 'character';
  }

  // 디렉터 툴이 활성화되어 있는지 확인
  bool get isEnabled => referenceImage.value != null;

  // 초기화
  void reset() {
    referenceImage.value = null;
    referenceImageBase64.value = '';
    styleAware.value = false;
    fidelity.value = 1;
  }

  img.Image _prepareDirectorImage(img.Image source) {
    final ({int width, int height}) targetSize = _selectTargetSize(source);

    final double scale = math.min(
      targetSize.width / source.width,
      targetSize.height / source.height,
    );

    final int resizedWidth = math.max(1, (source.width * scale).round());
    final int resizedHeight = math.max(1, (source.height * scale).round());

    final img.Image resized = img.copyResize(
      source,
      width: resizedWidth,
      height: resizedHeight,
      interpolation: img.Interpolation.linear,
    );

    final img.Image canvas = img.Image(
      width: targetSize.width,
      height: targetSize.height,
      numChannels: 4,
    );

    img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 255));

    final int offsetX = ((targetSize.width - resizedWidth) / 2).round();
    final int offsetY = ((targetSize.height - resizedHeight) / 2).round();

    img.compositeImage(
      canvas,
      resized,
      dstX: offsetX,
      dstY: offsetY,
    );

    return canvas;
  }

  ({int width, int height}) _selectTargetSize(img.Image source) {
    const double squareThreshold = 0.1;
    final double aspectRatio = source.width / source.height;

    if ((aspectRatio - 1).abs() <= squareThreshold) {
      return (width: 1472, height: 1472);
    }

    if (aspectRatio > 1) {
      return (width: 1536, height: 1024);
    }

    return (width: 1024, height: 1536);
  }
}
