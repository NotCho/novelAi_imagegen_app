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
      final pngResult = extractPngTextChunks(imageBytes);

      if (pngResult.isNotEmpty) {
        return pngResult;
      }

      // 2단계: WebP EXIF 메타데이터 청크 확인
      final webpExifResult = extractWebPExifMetadata(imageBytes);

      if (webpExifResult != null && webpExifResult.isNotEmpty) {
        return webpExifResult;
      }

      // 3단계: WebP 알파 채널 LSB 방식으로 시도
      final webpResult = extractWebPMetadata(imageBytes);

      if (webpResult != null && webpResult.isNotEmpty) {
        return webpResult;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// WebP 이미지의 알파 채널에서 LSB 스테가노그래피로 숨겨진 메타데이터 추출
  static Map<String, String>? extractWebPMetadata(Uint8List imageBytes) {
    try {

      final image = img.decodeWebP(imageBytes);
      if (image == null) {
        return null;
      }

      if (!image.hasAlpha) {
        return null;
      }


      // 다양한 방법으로 추출 시도
      String? extractedText;

      // 방법 1: 표준 LSB 추출
      extractedText = _extractStandardLSB(image);
      if (extractedText != null && _isValidJson(extractedText)) {
        return _parseToMap(extractedText);
      }

      // 방법 2: 역순 LSB 추출
      extractedText = _extractReverseLSB(image);
      if (extractedText != null && _isValidJson(extractedText)) {
        return _parseToMap(extractedText);
      }

      // 방법 3: Raw 바이트에서 직접 찾기
      extractedText = _extractFromRawBytes(image);
      if (extractedText != null && _isValidJson(extractedText)) {
        return _parseToMap(extractedText);
      }

      // 방법 4: 완전히 다른 접근 - 압축된 데이터일 가능성
      extractedText = _extractCompressedData(image);
      if (extractedText != null && _isValidJson(extractedText)) {
        return _parseToMap(extractedText);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// NovelAI 공식 방식: stealth_pngcomp 매직 넘버와 gzip 압축 사용
  static String? _extractStandardLSB(img.Image image) {
    try {

      // Python 코드의 byteize 함수 구현
      final alphaData = _byteizeAlpha(image);
      if (alphaData == null || alphaData.isEmpty) {
        return null;
      }


      // LSBExtractor 구현
      int pos = 0;

      // 매직 넘버 확인: "stealth_pngcomp"
      const magic = "stealth_pngcomp";
      if (pos + magic.length > alphaData.length) {
        return null;
      }

      final magicBytes = alphaData.sublist(pos, pos + magic.length);
      final readMagic = utf8.decode(magicBytes, allowMalformed: false);
      pos += magic.length;

      if (magic != readMagic) {
        return null;
      }


      // 32비트 정수 읽기 (Big Endian, 길이)
      if (pos + 4 > alphaData.length) {
        return null;
      }

      final lengthBytes = alphaData.sublist(pos, pos + 4);
      final dataLength = (lengthBytes[0] << 24) |
          (lengthBytes[1] << 16) |
          (lengthBytes[2] << 8) |
          lengthBytes[3];
      pos += 4;

      final readLen = dataLength ~/
          8; // Python: read_len = reader.read_32bit_integer() // 8

      if (pos + readLen > alphaData.length) {
        return null;
      }

      // 압축된 JSON 데이터 읽기
      final compressedData = alphaData.sublist(pos, pos + readLen);

      // Gzip 압축 해제
      try {
        final decompressed = gzip.decode(compressedData);
        final jsonText = utf8.decode(decompressed);


        return jsonText;
      } catch (e) {
        return null;
      }
    } catch (e) {
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


      // 4. 8의 배수로 자르기: alpha = alpha[:(alpha.shape[0] // 8) * 8]
      final int validLength = (flattened.length ~/ 8) * 8;
      final truncated = flattened.sublist(0, validLength);

      // 5. LSB 추출: alpha = np.bitwise_and(alpha, 1)
      final List<int> lsbBits = truncated.map((val) => val & 1).toList();


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


      return packedBytes;
    } catch (e) {
      return null;
    }
  }

  /// 역순 LSB 추출 (픽셀 순서 뒤바꾸기)
  static String? _extractReverseLSB(img.Image image) {
    try {

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

      return _tryDecodeBytes(messageBytes);
    } catch (e) {
      return null;
    }
  }

  /// Raw 바이트에서 직접 JSON 패턴 찾기
  static String? _extractFromRawBytes(img.Image image) {
    try {

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
          for (int length = 500;
              length < 50000 && start + length < alphaBytes.length;
              length += 500) {
            try {
              final candidate = alphaBytes.sublist(start, start + length);
              final text = utf8.decode(candidate, allowMalformed: true);

              if (_isValidJson(text)) {
                return text;
              }
            } catch (e) {
              // 계속 시도
            }
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 압축된 데이터 추출 시도
  static String? _extractCompressedData(img.Image image) {
    try {

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
          return decoded;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 다양한 인코딩으로 바이트 디코딩 시도
  static String? _tryDecodeBytes(List<int> bytes) {
    // UTF-8 시도
    try {
      final text = utf8.decode(bytes, allowMalformed: false);
      if (text.isNotEmpty && !text.contains('�')) {
        return text;
      }
    } catch (e) {
      // 다음 시도
    }

    // Latin-1 시도
    try {
      final text = String.fromCharCodes(bytes);
      if (text.isNotEmpty) {
        return text;
      }
    } catch (e) {
      // 다음 시도
    }

    // UTF-8 관대한 모드
    try {
      final text = utf8.decode(bytes, allowMalformed: true);
      if (text.isNotEmpty) {
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

      if (bytes.length < 12) return null;

      // WebP 시그니처 확인
      if (!(bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50)) {
        return null;
      }

      int offset = 12;
      final textChunks = <String, String>{};

      while (offset + 8 < bytes.length) {
        try {
          final chunkId =
              String.fromCharCodes(bytes.sublist(offset, offset + 4));
          final chunkSize = bytes[offset + 4] |
              (bytes[offset + 5] << 8) |
              (bytes[offset + 6] << 16) |
              (bytes[offset + 7] << 24);


          final dataStart = offset + 8;
          final dataEnd = dataStart + chunkSize;

          if (dataEnd > bytes.length) break;

          // ALPH 청크에서 메타데이터 찾기 (NovelAI가 여기 숨겼을 가능성)
          if (chunkId == 'ALPH') {
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
            final exifData = bytes.sublist(dataStart, dataEnd);
            final jsonResult = _searchJsonInBytes(exifData, 'EXIF');
            if (jsonResult != null) {
              textChunks['Comment'] = jsonResult;
              return textChunks;
            }
          }

          // XMP 청크 처리
          if (chunkId == 'XMP ') {
            try {
              final xmpText = utf8.decode(bytes.sublist(dataStart, dataEnd),
                  allowMalformed: true);
              if (xmpText.contains('prompt') || xmpText.contains('{')) {
                textChunks['XMP'] = xmpText;
                return textChunks;
              }
            } catch (e) {
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
          break;
        }
      }

      return textChunks.isNotEmpty ? textChunks : null;
    } catch (e) {
      return null;
    }
  }

  /// 바이트 배열에서 JSON 패턴 검색
  static String? _searchJsonInBytes(Uint8List data, String chunkName) {
    try {

      // 1. 직접 JSON 패턴 찾기
      for (int i = 0; i < data.length - 10; i++) {
        if (data[i] == 123) {
          // '{'
          for (int j = i + 10; j < math.min(i + 50000, data.length); j++) {
            if (data[j] == 125) {
              // '}'
              try {
                final candidate = data.sublist(i, j + 1);
                final text = utf8.decode(candidate, allowMalformed: false);
                if (_isValidJson(text)) {
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
              return candidate;
            }
          }
        }
      } catch (e) {
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// ALPH 청크 압축 해제 시도
  static Uint8List? _tryDecompressAlpha(Uint8List alphData) {
    try {

      // WebP ALPH 청크는 보통 첫 바이트가 압축 방법을 나타냄
      if (alphData.isEmpty) return null;


      // ALPH 청크에서 압축되지 않은 부분 찾기
      // 때로는 압축된 데이터 뒤에 메타데이터가 붙어있을 수 있음
      for (int offset = 1; offset < math.min(100, alphData.length); offset++) {
        try {
          final remaining = alphData.sublist(offset);
          if (remaining.length > 100) {
            // JSON 패턴이 있는지 확인
            final text = utf8.decode(remaining, allowMalformed: true);
            if (text.contains('{') && text.contains('}')) {
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
          final decoded =
              Uint8List.fromList(alphData.map((b) => b ^ key).toList());
          final text = utf8.decode(decoded, allowMalformed: true);
          if (_isValidJson(text)) {
            return decoded;
          }
        } catch (e) {
          // 다음 키 시도
        }
      }

      return null;
    } catch (e) {
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
      return <String, String>{};
    }
  }
}

class WebPMetadataEmbedder {
  /// WebP 파일의 청크를 직접 수정해서 메타데이터 삽입
  /// image 라이브러리의 encodeWebP 함수 없이도 작동
  static Uint8List? embedMetadataInWebP(
      Uint8List imageBytes, Map<String, String> metadata) {
    try {

      if (imageBytes.length < 12) {
        return null;
      }

      // WebP 시그니처 확인
      if (!(imageBytes[0] == 0x52 &&
          imageBytes[1] == 0x49 &&
          imageBytes[2] == 0x46 &&
          imageBytes[3] == 0x46 &&
          imageBytes[8] == 0x57 &&
          imageBytes[9] == 0x45 &&
          imageBytes[10] == 0x42 &&
          imageBytes[11] == 0x50)) {
        return null;
      }

      // 메타데이터를 JSON으로 변환하고 압축
      final jsonText = jsonEncode(metadata);
      final jsonBytes = utf8.encode(jsonText);
      final compressedData = gzip.encode(jsonBytes);


      // NovelAI 방식 데이터 준비
      final novelAIData = _prepareNovelAIData(jsonText);

      // 방법 1: EXIF 청크에 압축된 데이터 삽입
      var result = _insertExifChunk(imageBytes, compressedData);
      if (result != null) {
        return result;
      }

      // 방법 2: 커스텀 청크에 NovelAI 데이터 삽입
      if (novelAIData != null) {
        result = _insertCustomChunk(imageBytes, 'META', novelAIData);
        if (result != null) {
          return result;
        }
      }

      // 방법 3: XMP 청크에 JSON 삽입
      result = _insertXmpChunk(imageBytes, jsonText);
      if (result != null) {
        return result;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// NovelAI 방식으로 데이터 준비 (stealth_pngcomp + gzip)
  static Uint8List? _prepareNovelAIData(String jsonText) {
    try {

      // 1. JSON을 gzip으로 압축
      final jsonBytes = utf8.encode(jsonText);
      final compressedData = gzip.encode(jsonBytes);

      // 2. 헤더 준비
      const magic = "stealth_pngcomp";
      final magicBytes = utf8.encode(magic);

      // 3. 길이 정보 (32비트 Big Endian, 비트 단위)
      final dataLengthInBits = compressedData.length * 8;
      final lengthBytes = [
        (dataLengthInBits >> 24) & 0xFF,
        (dataLengthInBits >> 16) & 0xFF,
        (dataLengthInBits >> 8) & 0xFF,
        dataLengthInBits & 0xFF,
      ];

      // 4. 전체 데이터 조합: magic + length + compressed_data
      final totalData = <int>[];
      totalData.addAll(magicBytes);
      totalData.addAll(lengthBytes);
      totalData.addAll(compressedData);

      return Uint8List.fromList(totalData);
    } catch (e) {
      return null;
    }
  }

  /// EXIF 청크에 메타데이터 삽입
  static Uint8List? _insertExifChunk(Uint8List originalBytes, List<int> data) {
    try {

      // EXIF 청크 생성
      final exifChunk = _createWebPChunk('EXIF', data);

      // WebP 파일에 삽입
      return _insertChunkInWebP(originalBytes, exifChunk, 'EXIF');
    } catch (e) {
      return null;
    }
  }

  /// 커스텀 청크에 메타데이터 삽입
  static Uint8List? _insertCustomChunk(
      Uint8List originalBytes, String chunkType, List<int> data) {
    try {

      // 커스텀 청크 생성
      final customChunk = _createWebPChunk(chunkType, data);

      // WebP 파일에 삽입
      return _insertChunkInWebP(originalBytes, customChunk, chunkType);
    } catch (e) {
      return null;
    }
  }

  /// XMP 청크에 메타데이터 삽입
  static Uint8List? _insertXmpChunk(Uint8List originalBytes, String jsonText) {
    try {

      // XMP 포맷으로 감싸기
      final xmpContent = '''<?xpacket begin="" id=""?>
<x:xmpmeta xmlns:x="adobe:ns:meta/">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about="">
      <exif:UserComment>$jsonText</exif:UserComment>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
<?xpacket end="w"?>''';

      final xmpBytes = utf8.encode(xmpContent);
      final xmpChunk = _createWebPChunk('XMP ', xmpBytes);

      return _insertChunkInWebP(originalBytes, xmpChunk, 'XMP ');
    } catch (e) {
      return null;
    }
  }

  /// WebP 청크 생성
  static Uint8List _createWebPChunk(String chunkType, List<int> data) {
    final chunk = <int>[];

    // 청크 타입 (4바이트, 부족하면 공백으로 패딩)
    final typeBytes = utf8.encode(chunkType);
    if (typeBytes.length >= 4) {
      chunk.addAll(typeBytes.take(4));
    } else {
      chunk.addAll(typeBytes);
      while (chunk.length < 4) {
        chunk.add(0x20); // 공백
      }
    }

    // 청크 크기 (Little Endian)
    final chunkSize = data.length;
    chunk.add(chunkSize & 0xFF);
    chunk.add((chunkSize >> 8) & 0xFF);
    chunk.add((chunkSize >> 16) & 0xFF);
    chunk.add((chunkSize >> 24) & 0xFF);

    // 데이터
    chunk.addAll(data);

    // 패딩 (홀수 크기면 0x00 추가)
    if (chunkSize % 2 == 1) {
      chunk.add(0x00);
    }

    return Uint8List.fromList(chunk);
  }

  /// WebP 파일에 청크 삽입
  static Uint8List? _insertChunkInWebP(
      Uint8List originalBytes, Uint8List newChunk, String chunkType) {
    try {

      // RIFF 헤더 복사 (처음 12바이트)
      final result = <int>[];
      result.addAll(originalBytes.sublist(0, 12));

      // 기존 청크들과 새 청크 처리
      int offset = 12;
      bool chunkInserted = false;

      while (offset < originalBytes.length) {
        if (offset + 8 > originalBytes.length) break;

        // 청크 ID 읽기
        final existingChunkId =
            String.fromCharCodes(originalBytes.sublist(offset, offset + 4));
        final existingChunkSize = originalBytes[offset + 4] |
            (originalBytes[offset + 5] << 8) |
            (originalBytes[offset + 6] << 16) |
            (originalBytes[offset + 7] << 24);

        final dataStart = offset + 8;
        final dataEnd = dataStart + existingChunkSize;
        final paddedEnd = dataEnd + (existingChunkSize % 2); // 패딩 고려

        if (paddedEnd > originalBytes.length) break;


        // 기존 청크가 같은 타입이면 대체
        if (existingChunkId.trim() == chunkType.trim()) {
          result.addAll(newChunk);
          chunkInserted = true;
        } else if ((existingChunkId == 'VP8 ' ||
                existingChunkId == 'VP8L' ||
                existingChunkId == 'VP8X') &&
            !chunkInserted) {
          // VP8 관련 청크 뒤에 새 청크 삽입
          result.addAll(originalBytes.sublist(offset, paddedEnd));
          result.addAll(newChunk);
          chunkInserted = true;
        } else {
          // 다른 청크들은 그대로 복사
          result.addAll(originalBytes.sublist(offset, paddedEnd));
        }

        offset = paddedEnd;
      }

      // 새 청크가 삽입되지 않았다면 끝에 추가
      if (!chunkInserted) {
        result.addAll(newChunk);
      }

      // RIFF 크기 업데이트
      final newFileSize = result.length - 8;
      result[4] = newFileSize & 0xFF;
      result[5] = (newFileSize >> 8) & 0xFF;
      result[6] = (newFileSize >> 16) & 0xFF;
      result[7] = (newFileSize >> 24) & 0xFF;


      return Uint8List.fromList(result);
    } catch (e) {
      return null;
    }
  }

  /// PNG tEXt 청크 추가 (PNG 파일용)
  static Uint8List? addPngTextChunk(
      Uint8List pngBytes, String key, String value) {
    try {

      if (pngBytes.length < 8) return null;

      // PNG 시그니처 확인
      const pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
      for (int i = 0; i < 8; i++) {
        if (pngBytes[i] != pngSignature[i]) {
          return null;
        }
      }

      // tEXt 청크 데이터 준비
      final keyBytes = utf8.encode(key);
      final valueBytes = utf8.encode(value);
      final chunkData = <int>[];
      chunkData.addAll(keyBytes);
      chunkData.add(0); // null separator
      chunkData.addAll(valueBytes);

      // tEXt 청크 생성
      final textChunk = _createPngChunk('tEXt', chunkData);

      // IEND 청크 앞에 삽입
      final iendIndex = _findPngChunk(pngBytes, 'IEND');
      if (iendIndex == -1) {
        return null;
      }

      final result = <int>[];
      result.addAll(pngBytes.sublist(0, iendIndex));
      result.addAll(textChunk);
      result.addAll(pngBytes.sublist(iendIndex));

      return Uint8List.fromList(result);
    } catch (e) {
      return null;
    }
  }

  /// PNG 청크 생성
  static List<int> _createPngChunk(String type, List<int> data) {
    final chunk = <int>[];

    // 길이 (Big Endian)
    final length = data.length;
    chunk.add((length >> 24) & 0xFF);
    chunk.add((length >> 16) & 0xFF);
    chunk.add((length >> 8) & 0xFF);
    chunk.add(length & 0xFF);

    // 타입
    chunk.addAll(utf8.encode(type));

    // 데이터
    chunk.addAll(data);

    // CRC32 계산 (타입 + 데이터)
    final crcData = <int>[];
    crcData.addAll(utf8.encode(type));
    crcData.addAll(data);
    final crc = _calculateCRC32(crcData);

    chunk.add((crc >> 24) & 0xFF);
    chunk.add((crc >> 16) & 0xFF);
    chunk.add((crc >> 8) & 0xFF);
    chunk.add(crc & 0xFF);

    return chunk;
  }

  /// PNG 청크 찾기
  static int _findPngChunk(Uint8List bytes, String chunkType) {
    int offset = 8; // PNG 시그니처 건너뛰기

    while (offset + 8 < bytes.length) {
      final length = (bytes[offset] << 24) |
          (bytes[offset + 1] << 16) |
          (bytes[offset + 2] << 8) |
          bytes[offset + 3];

      final type = String.fromCharCodes(bytes.sublist(offset + 4, offset + 8));

      if (type == chunkType) {
        return offset;
      }

      offset += 8 + length + 4; // 길이 + 타입 + 데이터 + CRC
    }

    return -1;
  }

  /// 간단한 CRC32 계산
  static int _calculateCRC32(List<int> data) {
    // CRC32 테이블
    final crcTable = List<int>.filled(256, 0);
    for (int i = 0; i < 256; i++) {
      int c = i;
      for (int j = 0; j < 8; j++) {
        if (c & 1 != 0) {
          c = 0xEDB88320 ^ (c >> 1);
        } else {
          c >>= 1;
        }
      }
      crcTable[i] = c;
    }

    // CRC 계산
    int crc = 0xFFFFFFFF;
    for (final byte in data) {
      crc = crcTable[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }

    return crc ^ 0xFFFFFFFF;
  }

  /// 메타데이터 테스트 (삽입 후 추출 확인)
  static void testMetadataEmbedding(
      Uint8List imageBytes, Map<String, String> metadata) {
    try {

      // 1. 메타데이터 삽입
      final modifiedBytes = embedMetadataInWebP(imageBytes, metadata);
      if (modifiedBytes == null) {
        return;
      }


      // 2. 삽입된 메타데이터 추출 테스트
      final extractedMetadata =
          WebPMetadataParser.extractMetadata(modifiedBytes);
      if (extractedMetadata == null) {
        return;
      }


      // 3. 데이터 일치 확인
      bool isMatch = true;
      metadata.forEach((key, value) {
        if (extractedMetadata[key] != value) {
          isMatch = false;
        }
      });

      if (isMatch) {
      } else {
      }

    } catch (e) {
    }
  }
}

class WebPChunkEmbedder {
  /// WebP 파일의 청크를 직접 수정해서 메타데이터 삽입
  /// 이 방법은 image 라이브러리의 encodeWebP에 의존하지 않음
  static Uint8List? embedMetadataInWebPChunk(
      Uint8List imageBytes, Map<String, String> metadata) {
    try {

      if (imageBytes.length < 12) {
        return null;
      }

      // WebP 시그니처 확인
      if (!(imageBytes[0] == 0x52 &&
          imageBytes[1] == 0x49 &&
          imageBytes[2] == 0x46 &&
          imageBytes[3] == 0x46 &&
          imageBytes[8] == 0x57 &&
          imageBytes[9] == 0x45 &&
          imageBytes[10] == 0x42 &&
          imageBytes[11] == 0x50)) {
        return null;
      }

      // 메타데이터를 JSON으로 변환하고 압축
      final jsonText = jsonEncode(metadata);
      final jsonBytes = utf8.encode(jsonText);
      final compressedData = gzip.encode(jsonBytes);


      // 커스텀 청크 생성 (EXIF 청크 사용)
      final metadataChunk = _createExifChunk(compressedData);

      // WebP 파일에 청크 삽입
      final modifiedWebP = _insertChunkInWebP(imageBytes, metadataChunk);

      if (modifiedWebP != null) {
        return modifiedWebP;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// EXIF 청크 생성
  static Uint8List _createExifChunk(List<int> data) {
    // EXIF 청크 구조: 'EXIF' + 크기 + 데이터
    final chunkSize = data.length;
    final chunk = <int>[];

    // 청크 ID: 'EXIF'
    chunk.addAll([0x45, 0x58, 0x49, 0x46]); // 'EXIF'

    // 청크 크기 (Little Endian)
    chunk.add(chunkSize & 0xFF);
    chunk.add((chunkSize >> 8) & 0xFF);
    chunk.add((chunkSize >> 16) & 0xFF);
    chunk.add((chunkSize >> 24) & 0xFF);

    // 데이터
    chunk.addAll(data);

    // 패딩 (홀수 크기면 0x00 추가)
    if (chunkSize % 2 == 1) {
      chunk.add(0x00);
    }

    return Uint8List.fromList(chunk);
  }

  /// WebP 파일에 청크 삽입
  static Uint8List? _insertChunkInWebP(
      Uint8List originalBytes, Uint8List newChunk) {
    try {
      // RIFF 헤더 복사 (처음 12바이트)
      final result = <int>[];
      result.addAll(originalBytes.sublist(0, 12));

      // 기존 청크들과 새 청크 처리
      int offset = 12;
      bool exifInserted = false;

      while (offset < originalBytes.length) {
        if (offset + 8 > originalBytes.length) break;

        // 청크 ID 읽기
        final chunkId =
            String.fromCharCodes(originalBytes.sublist(offset, offset + 4));
        final chunkSize = originalBytes[offset + 4] |
            (originalBytes[offset + 5] << 8) |
            (originalBytes[offset + 6] << 16) |
            (originalBytes[offset + 7] << 24);

        final dataStart = offset + 8;
        final dataEnd = dataStart + chunkSize;
        final paddedEnd = dataEnd + (chunkSize % 2); // 패딩 고려

        if (paddedEnd > originalBytes.length) break;


        // VP8/VP8L/VP8X 청크 뒤에 EXIF 삽입
        if ((chunkId == 'VP8 ' || chunkId == 'VP8L' || chunkId == 'VP8X') &&
            !exifInserted) {
          // 현재 청크 복사
          result.addAll(originalBytes.sublist(offset, paddedEnd));

          // EXIF 청크 삽입
          result.addAll(newChunk);
          exifInserted = true;

        } else if (chunkId == 'EXIF') {
          // 기존 EXIF 청크 대체
          result.addAll(newChunk);
          exifInserted = true;
        } else {
          // 다른 청크들은 그대로 복사
          result.addAll(originalBytes.sublist(offset, paddedEnd));
        }

        offset = paddedEnd;
      }

      // EXIF가 삽입되지 않았다면 끝에 추가
      if (!exifInserted) {
        result.addAll(newChunk);
      }

      // RIFF 크기 업데이트
      final newFileSize = result.length - 8;
      result[4] = newFileSize & 0xFF;
      result[5] = (newFileSize >> 8) & 0xFF;
      result[6] = (newFileSize >> 16) & 0xFF;
      result[7] = (newFileSize >> 24) & 0xFF;


      return Uint8List.fromList(result);
    } catch (e) {
      return null;
    }
  }

  /// 간단한 텍스트 청크 방식 (tEXt 청크 유사)
  static Uint8List? embedSimpleTextChunk(
      Uint8List imageBytes, Map<String, String> metadata) {
    try {

      // JSON을 문자열로 변환
      final jsonText = jsonEncode(metadata);
      final textBytes = utf8.encode(jsonText);

      // 커스텀 텍스트 청크 생성
      final textChunk = _createTextChunk('META', textBytes);

      // WebP에 삽입
      return _insertChunkInWebP(imageBytes, textChunk);
    } catch (e) {
      return null;
    }
  }

  /// 텍스트 청크 생성
  static Uint8List _createTextChunk(String chunkId, List<int> textData) {
    final chunk = <int>[];

    // 청크 ID (4바이트)
    final idBytes = utf8.encode(chunkId);
    if (idBytes.length != 4) {
      // 4바이트로 맞추기
      chunk.addAll(idBytes.take(4));
      while (chunk.length < 4) {
        chunk.add(0x20); // 공백으로 패딩
      }
    } else {
      chunk.addAll(idBytes);
    }

    // 크기
    final dataSize = textData.length;
    chunk.add(dataSize & 0xFF);
    chunk.add((dataSize >> 8) & 0xFF);
    chunk.add((dataSize >> 16) & 0xFF);
    chunk.add((dataSize >> 24) & 0xFF);

    // 데이터
    chunk.addAll(textData);

    // 패딩
    if (dataSize % 2 == 1) {
      chunk.add(0x00);
    }

    return Uint8List.fromList(chunk);
  }

  /// PNG tEXt 청크 추가 (PNG 파일용)
  static Uint8List? addPngTextChunk(
      Uint8List pngBytes, String key, String value) {
    try {

      if (pngBytes.length < 8) return null;

      // PNG 시그니처 확인
      const pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
      for (int i = 0; i < 8; i++) {
        if (pngBytes[i] != pngSignature[i]) {
          return null;
        }
      }

      // tEXt 청크 데이터 준비
      final keyBytes = utf8.encode(key);
      final valueBytes = utf8.encode(value);
      final chunkData = <int>[];
      chunkData.addAll(keyBytes);
      chunkData.add(0); // null separator
      chunkData.addAll(valueBytes);

      // tEXt 청크 생성
      final textChunk = _createPngChunk('tEXt', chunkData);

      // IEND 청크 앞에 삽입
      final iendIndex = _findPngChunk(pngBytes, 'IEND');
      if (iendIndex == -1) {
        return null;
      }

      final result = <int>[];
      result.addAll(pngBytes.sublist(0, iendIndex));
      result.addAll(textChunk);
      result.addAll(pngBytes.sublist(iendIndex));

      return Uint8List.fromList(result);
    } catch (e) {
      return null;
    }
  }

  /// PNG 청크 생성
  static List<int> _createPngChunk(String type, List<int> data) {
    final chunk = <int>[];

    // 길이 (Big Endian)
    final length = data.length;
    chunk.add((length >> 24) & 0xFF);
    chunk.add((length >> 16) & 0xFF);
    chunk.add((length >> 8) & 0xFF);
    chunk.add(length & 0xFF);

    // 타입
    chunk.addAll(utf8.encode(type));

    // 데이터
    chunk.addAll(data);

    // CRC32 계산 (타입 + 데이터)
    final crcData = <int>[];
    crcData.addAll(utf8.encode(type));
    crcData.addAll(data);
    final crc = _calculateCRC32(crcData);

    chunk.add((crc >> 24) & 0xFF);
    chunk.add((crc >> 16) & 0xFF);
    chunk.add((crc >> 8) & 0xFF);
    chunk.add(crc & 0xFF);

    return chunk;
  }

  /// PNG 청크 찾기
  static int _findPngChunk(Uint8List bytes, String chunkType) {
    int offset = 8; // PNG 시그니처 건너뛰기

    while (offset + 8 < bytes.length) {
      final length = (bytes[offset] << 24) |
          (bytes[offset + 1] << 16) |
          (bytes[offset + 2] << 8) |
          bytes[offset + 3];

      final type = String.fromCharCodes(bytes.sublist(offset + 4, offset + 8));

      if (type == chunkType) {
        return offset;
      }

      offset += 8 + length + 4; // 길이 + 타입 + 데이터 + CRC
    }

    return -1;
  }

  /// 간단한 CRC32 계산
  static int _calculateCRC32(List<int> data) {
    // 간단한 CRC32 구현 (PNG용)
    int crc = 0xFFFFFFFF;

    for (final byte in data) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if (crc & 1 != 0) {
          crc = (crc >> 1) ^ 0xEDB88320;
        } else {
          crc >>= 1;
        }
      }
    }

    return crc ^ 0xFFFFFFFF;
  }
}
