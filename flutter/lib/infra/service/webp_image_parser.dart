import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:io' show gzip;
import 'package:image/image.dart' as img;

class WebPMetadataParser {
  /// PNG 우선 시도 후 실패시 WebP 방식으로 폴백하는 메타데이터 추출
  static Map<String, String>? extractMetadata(Uint8List imageBytes) {
    try {
      // 1단계: PNG 텍스트 청크 방식으로 시도
      print('PNG 텍스트 청크 추출 시도');
      final pngResult = extractPngTextChunks(imageBytes);

      if (pngResult.isNotEmpty) {
        print('PNG 텍스트 청크에서 메타데이터 추출 성공');
        return pngResult;
      }

      // 2단계: WebP EXIF 메타데이터 청크 확인
      print('PNG 추출 실패, WebP EXIF 청크 확인');
      final webpExifResult = extractWebPExifMetadata(imageBytes);

      if (webpExifResult != null && webpExifResult.isNotEmpty) {
        print('WebP EXIF에서 메타데이터 추출 성공');
        return webpExifResult;
      }

      // 3단계: WebP 알파 채널 LSB 방식으로 시도
      print('WebP EXIF 실패, 알파 채널 LSB 방식으로 시도');
      final webpResult = extractWebPMetadata(imageBytes);

      if (webpResult != null && webpResult.isNotEmpty) {
        print('WebP 알파 채널에서 메타데이터 추출 성공');
        return webpResult;
      }

      print('모든 메타데이터 추출 방식 실패');
      return null;

    } catch (e) {
      print('메타데이터 추출 중 오류: $e');
      return null;
    }
  }

  /// WebP 이미지의 알파 채널에서 LSB 스테가노그래피로 숨겨진 메타데이터 추출
  static Map<String, String>? extractWebPMetadata(Uint8List imageBytes) {
    try {
      print('WebP 메타데이터 추출 시도');

      final image = img.decodeWebP(imageBytes);
      if (image == null) {
        print('WebP 디코딩 실패');
        return null;
      }

      if (!image.hasAlpha) {
        print('알파 채널이 없는 WebP 이미지');
        return null;
      }

      print('이미지 크기: ${image.width}x${image.height}, 알파 채널 존재');

      // 다양한 방법으로 추출 시도
      String? extractedText;

      // 방법 1: 표준 LSB 추출
      extractedText = _extractStandardLSB(image);
      if (extractedText != null && _isValidJson(extractedText)) {
        print('표준 LSB 방식 성공');
        return _parseToMap(extractedText);
      }

      // 방법 2: 역순 LSB 추출
      extractedText = _extractReverseLSB(image);
      if (extractedText != null && _isValidJson(extractedText)) {
        print('역순 LSB 방식 성공');
        return _parseToMap(extractedText);
      }

      // 방법 3: Raw 바이트에서 직접 찾기
      extractedText = _extractFromRawBytes(image);
      if (extractedText != null && _isValidJson(extractedText)) {
        print('Raw 바이트 방식 성공');
        return _parseToMap(extractedText);
      }

      // 방법 4: 완전히 다른 접근 - 압축된 데이터일 가능성
      extractedText = _extractCompressedData(image);
      if (extractedText != null && _isValidJson(extractedText)) {
        print('압축 해제 방식 성공');
        return _parseToMap(extractedText);
      }

      print('모든 WebP 추출 방법 실패');
      return null;
    } catch (e) {
      print('WebP 메타데이터 추출 중 오류: $e');
      return null;
    }
  }

  /// NovelAI 공식 방식: stealth_pngcomp 매직 넘버와 gzip 압축 사용
  static String? _extractStandardLSB(img.Image image) {
    try {
      print('NovelAI 공식 방식으로 LSB 추출 시도');

      // Python 코드의 byteize 함수 구현
      final alphaData = _byteizeAlpha(image);
      if (alphaData == null || alphaData.isEmpty) {
        print('알파 데이터 추출 실패');
        return null;
      }

      print('Byteized 알파 데이터 크기: ${alphaData.length}');
      print('첫 20바이트: ${alphaData.take(20).toList()}');

      // LSBExtractor 구현
      int pos = 0;

      // 매직 넘버 확인: "stealth_pngcomp"
      const magic = "stealth_pngcomp";
      if (pos + magic.length > alphaData.length) {
        print('데이터가 너무 짧음 (매직 넘버)');
        return null;
      }

      final magicBytes = alphaData.sublist(pos, pos + magic.length);
      final readMagic = utf8.decode(magicBytes, allowMalformed: false);
      pos += magic.length;

      print('읽은 매직: "$readMagic"');
      if (magic != readMagic) {
        print('매직 넘버 불일치: 예상="$magic", 실제="$readMagic"');
        return null;
      }

      print('매직 넘버 확인 성공!');

      // 32비트 정수 읽기 (Big Endian, 길이)
      if (pos + 4 > alphaData.length) {
        print('데이터가 너무 짧음 (길이)');
        return null;
      }

      final lengthBytes = alphaData.sublist(pos, pos + 4);
      final dataLength = (lengthBytes[0] << 24) |
      (lengthBytes[1] << 16) |
      (lengthBytes[2] << 8) |
      lengthBytes[3];
      pos += 4;

      final readLen = dataLength ~/ 8; // Python: read_len = reader.read_32bit_integer() // 8
      print('압축된 데이터 길이: $readLen 바이트');

      if (pos + readLen > alphaData.length) {
        print('데이터가 너무 짧음 (압축 데이터)');
        return null;
      }

      // 압축된 JSON 데이터 읽기
      final compressedData = alphaData.sublist(pos, pos + readLen);
      print('압축된 데이터 첫 10바이트: ${compressedData.take(10).toList()}');

      // Gzip 압축 해제
      try {
        final decompressed = gzip.decode(compressedData);
        final jsonText = utf8.decode(decompressed);

        print('Gzip 압축 해제 성공!');
        print('JSON 텍스트 길이: ${jsonText.length}');
        print('JSON 시작 부분: ${jsonText.substring(0, math.min(200, jsonText.length))}');

        return jsonText;

      } catch (e) {
        print('Gzip 압축 해제 실패: $e');
        return null;
      }

    } catch (e) {
      print('NovelAI 공식 방식 LSB 추출 오류: $e');
      return null;
    }
  }

  /// Python의 byteize 함수 구현
  static List<int>? _byteizeAlpha(img.Image image) {
    try {
      // 1. 알파 채널 추출
      final List<List<int>> alphaMatrix = [];
      for (int y = 0; y < image.height; y++) {
        final row = <int>[];
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          row.add(pixel.a.toInt());
        }
        alphaMatrix.add(row);
      }

      // 2. 전치 (transpose): alpha.T
      final List<List<int>> transposed = [];
      for (int x = 0; x < image.width; x++) {
        final col = <int>[];
        for (int y = 0; y < image.height; y++) {
          col.add(alphaMatrix[y][x]);
        }
        transposed.add(col);
      }

      // 3. reshape(-1): 1차원 배열로 평탄화
      final List<int> flattened = [];
      for (final col in transposed) {
        flattened.addAll(col);
      }

      print('전치 후 평탄화된 크기: ${flattened.length}');
      print('평탄화된 첫 20개 값: ${flattened.take(20).toList()}');

      // 4. 8의 배수로 자르기: alpha = alpha[:(alpha.shape[0] // 8) * 8]
      final int validLength = (flattened.length ~/ 8) * 8;
      final truncated = flattened.sublist(0, validLength);

      // 5. LSB 추출: alpha = np.bitwise_and(alpha, 1)
      final List<int> lsbBits = truncated.map((val) => val & 1).toList();

      print('LSB 비트 첫 32개: ${lsbBits.take(32).toList()}');

      // 6. 8비트씩 묶어서 바이트로 패킹: alpha = alpha.reshape((-1, 8)) -> np.packbits
      final List<int> packedBytes = [];
      for (int i = 0; i < lsbBits.length; i += 8) {
        int byte = 0;
        for (int j = 0; j < 8; j++) {
          // NumPy packbits는 MSB first (Big Endian)
          byte |= (lsbBits[i + j] << (7 - j));
        }
        packedBytes.add(byte);
      }

      print('패킹된 바이트 수: ${packedBytes.length}');
      print('패킹된 첫 20바이트: ${packedBytes.take(20).toList()}');

      return packedBytes;

    } catch (e) {
      print('Byteize 처리 오류: $e');
      return null;
    }
  }

  /// 역순 LSB 추출 (픽셀 순서 뒤바꾸기)
  static String? _extractReverseLSB(img.Image image) {
    try {
      print('역순 LSB 추출 시도');

      // 역순으로 알파 채널 수집
      final List<int> alphaBytes = [];
      for (int y = image.height - 1; y >= 0; y--) {
        for (int x = image.width - 1; x >= 0; x--) {
          final pixel = image.getPixel(x, y);
          alphaBytes.add(pixel.a.toInt());
        }
      }

      // LSB 추출 및 바이트 조립
      final List<int> bits = alphaBytes.map((b) => b & 1).toList();
      final List<int> messageBytes = [];

      for (int i = 0; i < bits.length - 7; i += 8) {
        int byte = 0;
        for (int j = 0; j < 8; j++) {
          byte += bits[i + j] << j;
        }

        if (byte == 0) break;
        messageBytes.add(byte);
        if (messageBytes.length > 500000) break;
      }

      if (messageBytes.length < 20) return null;

      print('역순 LSB 바이트 샘플: ${messageBytes.take(20).toList()}');
      return _tryDecodeBytes(messageBytes);

    } catch (e) {
      print('역순 LSB 추출 오류: $e');
      return null;
    }
  }

  /// Raw 바이트에서 직접 JSON 패턴 찾기
  static String? _extractFromRawBytes(img.Image image) {
    try {
      print('Raw 바이트에서 JSON 패턴 검색');

      final List<int> alphaBytes = [];
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          alphaBytes.add(pixel.a.toInt());
        }
      }

      // 연속된 바이트들에서 JSON 시작/끝 패턴 찾기
      for (int start = 0; start < alphaBytes.length - 1000; start++) {
        // '{' 패턴 찾기
        if (alphaBytes[start] == 123) {
          // 다양한 길이로 JSON 추출 시도
          for (int length = 500; length < 50000 && start + length < alphaBytes.length; length += 500) {
            try {
              final candidate = alphaBytes.sublist(start, start + length);
              final text = utf8.decode(candidate, allowMalformed: true);

              if (_isValidJson(text)) {
                print('Raw에서 JSON 발견 at $start, length $length');
                return text;
              }
            } catch (e) {
              // 계속 시도
            }
          }
        }
      }

      print('Raw에서 JSON 패턴 찾을 수 없음');
      return null;

    } catch (e) {
      print('Raw 바이트 추출 오류: $e');
      return null;
    }
  }

  /// 압축된 데이터 추출 시도
  static String? _extractCompressedData(img.Image image) {
    try {
      print('압축 데이터 추출 시도');

      // 알파 채널에서 다른 비트들도 시도 (1-7번 비트)
      final List<int> alphaBytes = [];
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          alphaBytes.add(pixel.a.toInt());
        }
      }

      // 여러 비트 조합으로 시도
      for (int bitMask = 1; bitMask <= 15; bitMask++) {
        final List<int> bits = [];

        for (final alpha in alphaBytes) {
          // 비트 마스크에 따라 여러 비트 추출
          for (int bit = 0; bit < 4; bit++) {
            if ((bitMask & (1 << bit)) != 0) {
              bits.add((alpha >> bit) & 1);
            }
          }
        }

        if (bits.length < 1000) continue;

        // 바이트로 조립
        final List<int> messageBytes = [];
        for (int i = 0; i < bits.length - 7; i += 8) {
          int byte = 0;
          for (int j = 0; j < 8; j++) {
            byte += bits[i + j] << j;
          }

          if (byte == 0) break;
          messageBytes.add(byte);
          if (messageBytes.length > 100000) break;
        }

        if (messageBytes.length < 50) continue;

        final decoded = _tryDecodeBytes(messageBytes);
        if (decoded != null && _isValidJson(decoded)) {
          print('압축 방식(마스크: $bitMask) 성공');
          return decoded;
        }
      }

      return null;
    } catch (e) {
      print('압축 데이터 추출 오류: $e');
      return null;
    }
  }

  /// 다양한 인코딩으로 바이트 디코딩 시도
  static String? _tryDecodeBytes(List<int> bytes) {
    // UTF-8 시도
    try {
      final text = utf8.decode(bytes, allowMalformed: false);
      if (text.isNotEmpty && !text.contains('�')) {
        print('UTF-8 디코딩 성공');
        return text;
      }
    } catch (e) {
      // 다음 시도
    }

    // Latin-1 시도
    try {
      final text = String.fromCharCodes(bytes);
      if (text.isNotEmpty) {
        print('Latin-1 디코딩 성공');
        return text;
      }
    } catch (e) {
      // 다음 시도
    }

    // UTF-8 관대한 모드
    try {
      final text = utf8.decode(bytes, allowMalformed: true);
      if (text.isNotEmpty) {
        print('UTF-8 관대한 디코딩 성공');
        return text;
      }
    } catch (e) {
      // 실패
    }

    return null;
  }

  /// JSON 유효성 검사
  static bool _isValidJson(String text) {
    if (text.isEmpty) return false;

    final trimmed = text.trim();
    if (!trimmed.startsWith('{') || !trimmed.contains('}')) return false;

    try {
      jsonDecode(trimmed);
      return true;
    } catch (e) {
      // 키워드 기반 검증
      return trimmed.contains('prompt') ||
          trimmed.contains('parameters') ||
          trimmed.contains('model');
    }
  }

  /// 텍스트를 Map으로 변환
  static Map<String, String> _parseToMap(String text) {
    try {
      final jsonData = jsonDecode(text);
      if (jsonData is Map<String, dynamic>) {
        final result = <String, String>{};
        jsonData.forEach((key, value) {
          result[key] = value.toString();
        });
        return result;
      }
    } catch (e) {
      // JSON 파싱 실패시 Comment로 저장
    }

    return {'Comment': text};
  }

  /// WebP EXIF/XMP 메타데이터 청크에서 추출 시도
  static Map<String, String>? extractWebPExifMetadata(Uint8List bytes) {
    try {
      print('WebP EXIF 청크 검색 시도');

      if (bytes.length < 12) return null;

      // WebP 시그니처 확인
      if (!(bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
          bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50)) {
        return null;
      }

      int offset = 12;
      final textChunks = <String, String>{};

      while (offset + 8 < bytes.length) {
        try {
          final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
          final chunkSize = bytes[offset + 4] |
          (bytes[offset + 5] << 8) |
          (bytes[offset + 6] << 16) |
          (bytes[offset + 7] << 24);

          print('WebP 청크: $chunkId, 크기: $chunkSize');

          final dataStart = offset + 8;
          final dataEnd = dataStart + chunkSize;

          if (dataEnd > bytes.length) break;

          // ALPH 청크에서 메타데이터 찾기 (NovelAI가 여기 숨겼을 가능성)
          if (chunkId == 'ALPH') {
            print('ALPH 청크 발견, 메타데이터 검색');
            final alphData = bytes.sublist(dataStart, dataEnd);

            // ALPH 청크 내부에서 JSON 패턴 찾기
            final alphResult = _searchJsonInBytes(alphData, 'ALPH');
            if (alphResult != null) {
              textChunks['Comment'] = alphResult;
              return textChunks;
            }

            // ALPH 청크의 압축 해제 시도
            final decompressed = _tryDecompressAlpha(alphData);
            if (decompressed != null) {
              final jsonResult = _searchJsonInBytes(decompressed, 'ALPH-압축해제');
              if (jsonResult != null) {
                textChunks['Comment'] = jsonResult;
                return textChunks;
              }
            }
          }

          // EXIF 청크 처리
          if (chunkId == 'EXIF') {
            print('EXIF 청크 발견, 메타데이터 검색');
            final exifData = bytes.sublist(dataStart, dataEnd);
            final jsonResult = _searchJsonInBytes(exifData, 'EXIF');
            if (jsonResult != null) {
              textChunks['Comment'] = jsonResult;
              return textChunks;
            }
          }

          // XMP 청크 처리
          if (chunkId == 'XMP ') {
            print('XMP 청크 발견');
            try {
              final xmpText = utf8.decode(bytes.sublist(dataStart, dataEnd), allowMalformed: true);
              if (xmpText.contains('prompt') || xmpText.contains('{')) {
                textChunks['XMP'] = xmpText;
                return textChunks;
              }
            } catch (e) {
              print('XMP 디코딩 실패: $e');
            }
          }

          // 다른 청크들도 확인 (NovelAI가 어디에 숨겼는지 모르니까)
          if (chunkSize > 100 && chunkSize < 100000) {
            final chunkData = bytes.sublist(dataStart, dataEnd);
            final jsonResult = _searchJsonInBytes(chunkData, chunkId);
            if (jsonResult != null) {
              textChunks['Comment'] = jsonResult;
              return textChunks;
            }
          }

          offset = dataEnd + (chunkSize % 2);

        } catch (e) {
          print('WebP 청크 처리 오류: $e');
          break;
        }
      }

      return textChunks.isNotEmpty ? textChunks : null;

    } catch (e) {
      print('WebP EXIF 추출 오류: $e');
      return null;
    }
  }

  /// 바이트 배열에서 JSON 패턴 검색
  static String? _searchJsonInBytes(Uint8List data, String chunkName) {
    try {
      print('$chunkName 청크에서 JSON 검색 (크기: ${data.length})');

      // 1. 직접 JSON 패턴 찾기
      for (int i = 0; i < data.length - 10; i++) {
        if (data[i] == 123) { // '{'
          for (int j = i + 10; j < math.min(i + 50000, data.length); j++) {
            if (data[j] == 125) { // '}'
              try {
                final candidate = data.sublist(i, j + 1);
                final text = utf8.decode(candidate, allowMalformed: false);
                if (_isValidJson(text)) {
                  print('$chunkName에서 JSON 발견 ($i-$j)');
                  return text;
                }
              } catch (e) {
                // 계속 검색
              }
            }
          }
        }
      }

      // 2. 전체 데이터를 텍스트로 변환해서 JSON 찾기
      try {
        final fullText = utf8.decode(data, allowMalformed: true);
        final jsonStart = fullText.indexOf('{');
        if (jsonStart >= 0) {
          final jsonEnd = fullText.lastIndexOf('}');
          if (jsonEnd > jsonStart) {
            final candidate = fullText.substring(jsonStart, jsonEnd + 1);
            if (_isValidJson(candidate)) {
              print('$chunkName에서 텍스트 변환 후 JSON 발견');
              return candidate;
            }
          }
        }
      } catch (e) {
        print('$chunkName 텍스트 변환 실패: $e');
      }

      print('$chunkName에서 JSON 패턴 없음');
      return null;

    } catch (e) {
      print('$chunkName JSON 검색 오류: $e');
      return null;
    }
  }

  /// ALPH 청크 압축 해제 시도
  static Uint8List? _tryDecompressAlpha(Uint8List alphData) {
    try {
      print('ALPH 청크 압축 해제 시도');

      // WebP ALPH 청크는 보통 첫 바이트가 압축 방법을 나타냄
      if (alphData.isEmpty) return null;

      print('ALPH 첫 10바이트: ${alphData.take(10).toList()}');

      // ALPH 청크에서 압축되지 않은 부분 찾기
      // 때로는 압축된 데이터 뒤에 메타데이터가 붙어있을 수 있음
      for (int offset = 1; offset < math.min(100, alphData.length); offset++) {
        try {
          final remaining = alphData.sublist(offset);
          if (remaining.length > 100) {
            // JSON 패턴이 있는지 확인
            final text = utf8.decode(remaining, allowMalformed: true);
            if (text.contains('{') && text.contains('}')) {
              print('ALPH 오프셋 $offset에서 텍스트 패턴 발견');
              return remaining;
            }
          }
        } catch (e) {
          // 다음 오프셋 시도
        }
      }

      // 간단한 XOR 디코딩 시도 (일부 스테가노그래피에서 사용)
      for (int key = 1; key < 256; key++) {
        try {
          final decoded = Uint8List.fromList(alphData.map((b) => b ^ key).toList());
          final text = utf8.decode(decoded, allowMalformed: true);
          if (_isValidJson(text)) {
            print('ALPH XOR(키:$key) 디코딩 성공');
            return decoded;
          }
        } catch (e) {
          // 다음 키 시도
        }
      }

      return null;
    } catch (e) {
      print('ALPH 압축 해제 오류: $e');
      return null;
    }
  }

  /// PNG 텍스트 청크 추출
  static Map<String, String> extractPngTextChunks(Uint8List bytes) {
    try {
      const pngSignatureLength = 8;
      final textChunks = <String, String>{};
      int i = pngSignatureLength;

      while (i + 8 < bytes.length) {
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
          final nullIndex = chunkData.indexOf(0);
          if (nullIndex != -1) {
            final key = utf8.decode(chunkData.sublist(0, nullIndex));
            final value = utf8.decode(chunkData.sublist(nullIndex + 1));
            textChunks[key] = value;
          }
        }

        i = dataEnd + 4;
      }

      return textChunks;
    } catch (e) {
      print('PNG 텍스트 청크 추출 실패: $e');
      return <String, String>{};
    }
  }
}