import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/domain/gen/tag_suggestion_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive.dart';
import 'package:dartz/dartz.dart';
import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import '../../domain/gen/diffusion_model.dart';
import '../../domain/gen/i_novelAI_repository.dart';
import '../../domain/gen/v5_usage.dart';

/// NovelAI Persistent Token을 사용해 이미지 생성 및 변형 기능을 제공합니다.
class NovelAIRepository implements INovelAIRepository {
  // NovelAI REST endpoints
  static const String _imageUrl = 'https://image.novelai.net/ai/generate-image';
  static const String _streamingImageUrl =
      'https://image.novelai.net/ai/generate-image-stream';
  static const String _variationUrl =
      'https://image.novelai.net/ai/generate-image-variation';
  static const String _suggestionUrl =
      'https://image.novelai.net/ai/generate-image/suggest-tags';
  static const String _anlasRemainingUrl =
      "https://image.novelai.net/user/subscription";

  static const String _vibeParseUrl =
      "https://image.novelai.net/ai/encode-vibe";

  final http.Client _httpClient;
  final SharedPreferences _prefs;

  NovelAIRepository({http.Client? httpClient, SharedPreferences? prefs})
      : _httpClient = httpClient ?? http.Client(),
        _prefs = prefs ??
            (throw Exception(
                'SharedPreferences not provided to NovelAIRepository'));

  String? _getPersistentToken() =>
      _prefs.getString('NOVEL_AI_PERSISTENT_TOKEN');

  static String _newCorrelationId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    return timestamp.substring(timestamp.length - 6);
  }

  static String _errorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.isNotEmpty) return message;
      }
    } catch (_) {
      // A proxy or server can return a non-JSON error body.
    }
    return responseBody;
  }

  @override
  Future<Either<String, String>> generateImage({
    required DiffusionModel setting,
    void Function(Uint8List imageBytes)? onIntermediateImage,
  }) async {
    final token = _getPersistentToken();
    if (token == null) return const Left('Persistent token이 설정되지 않았습니다.');

    final headers = {
      'accept': '*/*',
      'authorization': 'Bearer $token',
      'content-type': 'application/json',
    };

    // Build payload directly from Setting
    final payload = setting.toJson();
    final Map<String, dynamic> parameters =
        Map<String, dynamic>.from(setting.parameters.toJson());
    payload['parameters'] = parameters;

    final model = setting.model;
    final supportsVibeTransfer = model.startsWith('nai-diffusion-3') ||
        model.startsWith('nai-diffusion-4') ||
        model.startsWith('nai-diffusion-5');
    final usesEncodedVibes = model.startsWith('nai-diffusion-4') ||
        model.startsWith('nai-diffusion-5');
    final supportsCharacterReference = model.startsWith('nai-diffusion-4-5') ||
        model.startsWith('nai-diffusion-5');

    if (!supportsVibeTransfer) {
      parameters.remove('reference_image_multiple');
      parameters.remove('reference_information_extracted_multiple');
      parameters.remove('reference_strength_multiple');
    }
    if (usesEncodedVibes) {
      parameters.remove('reference_information_extracted_multiple');
    }

    if (!supportsCharacterReference) {
      parameters.remove('director_reference_descriptions');
      parameters.remove('director_reference_images');
      parameters.remove('director_reference_information_extracted');
      parameters.remove('director_reference_secondary_strength_values');
      parameters.remove('director_reference_strength_values');
      parameters.remove('inpaintImg2ImgStrength');
      payload.remove('use_new_shared_trial');
    }

    final List<dynamic> directorImages =
        (parameters['director_reference_images'] as List<dynamic>?) ?? [];
    final List<dynamic> directorDescriptions =
        (parameters['director_reference_descriptions'] as List<dynamic>?) ?? [];
    final bool directorActive =
        directorImages.isNotEmpty || directorDescriptions.isNotEmpty;

    if (directorActive) {
      parameters['inpaintImg2ImgStrength'] ??= 1;
      payload['use_new_shared_trial'] = true;
    }
    // print('Payload: ${jsonEncode(payload)}');

    if (_prefs.getBool(imageGenerationStreamingModePreferenceKey) ?? false) {
      parameters['stream'] = 'msgpack';
      return _generateImageMessagePack(
        headers: headers,
        payload: payload,
        onIntermediateImage: onIntermediateImage,
      );
    }

    try {
      final resp = await _httpClient.post(
        Uri.parse(_imageUrl),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final zipBytes = resp.bodyBytes;
        final archive = ZipDecoder().decodeBytes(zipBytes);
        if (archive.isEmpty) return const Left('No images in ZIP');
        final file = archive.firstWhere((e) => e.isFile);
        final imageBytes = file.content as List<int>;
        final base64Image = base64Encode(imageBytes);
        return Right(base64Image);
      } else {
        return Left('Image generation failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  Future<Either<String, String>> _generateImageMessagePack({
    required Map<String, String> headers,
    required Map<String, dynamic> payload,
    void Function(Uint8List imageBytes)? onIntermediateImage,
  }) async {
    final correlationId = _newCorrelationId();
    final request = http.Request('POST', Uri.parse(_streamingImageUrl))
      ..headers.addAll({
        ...headers,
        'accept': 'application/msgpack',
        'x-correlation-id': correlationId,
        'x-initiated-at': DateTime.now().toUtc().toIso8601String(),
      })
      ..body = jsonEncode(payload);

    try {
      final response = await _httpClient.send(request);
      if (response.statusCode != 200 && response.statusCode != 201) {
        final responseBody = await response.stream.bytesToString();
        return Left(
          'Image streaming failed: ${response.statusCode} '
          '${_errorMessage(responseBody)} '
          '(Correlation ID: $correlationId)',
        );
      }

      Uint8List? finalImage;
      String? streamError;

      void processFrame(Uint8List frame) {
        try {
          final decoded = msgpack.deserialize(frame, copyBinaryData: true);
          if (decoded is! Map) return;

          final eventType = decoded['event_type']?.toString();
          final image = _messagePackImageBytes(decoded['image']);
          if (eventType == 'intermediate' && image != null) {
            try {
              onIntermediateImage?.call(image);
            } catch (_) {
              // A preview rendering failure must not cancel the generation.
            }
          } else if (eventType == 'final' && image != null) {
            finalImage = image;
          } else if (eventType == 'error') {
            streamError =
                (decoded['message'] ?? decoded['error'])?.toString() ??
                    '스트리밍 생성 중 알 수 없는 오류가 발생했습니다.';
          }
        } catch (error) {
          streamError = '메시지팩 응답을 해석할 수 없습니다: $error';
        }
      }

      final frameHeader = Uint8List(4);
      var frameHeaderBytes = 0;
      int? expectedFrameLength;
      var framePayload = BytesBuilder(copy: false);

      await for (final chunk in response.stream) {
        final chunkBytes =
            chunk is Uint8List ? chunk : Uint8List.fromList(chunk);
        var offset = 0;
        while (offset < chunkBytes.length) {
          if (expectedFrameLength == null) {
            final headerBytesToRead =
                (4 - frameHeaderBytes).clamp(0, chunkBytes.length - offset);
            frameHeader.setRange(
              frameHeaderBytes,
              frameHeaderBytes + headerBytesToRead,
              chunkBytes,
              offset,
            );
            frameHeaderBytes += headerBytesToRead;
            offset += headerBytesToRead;
            if (frameHeaderBytes < 4) continue;

            final frameLength =
                ByteData.sublistView(frameHeader).getUint32(0, Endian.big);
            frameHeaderBytes = 0;
            if (frameLength <= 0 || frameLength > 64 * 1024 * 1024) {
              return Left(
                '잘못된 메시지팩 프레임 크기입니다: $frameLength '
                '(Correlation ID: $correlationId)',
              );
            }
            expectedFrameLength = frameLength;
          }

          final payloadBytesToRead = (expectedFrameLength - framePayload.length)
              .clamp(0, chunkBytes.length - offset);
          framePayload.add(
            Uint8List.sublistView(
              chunkBytes,
              offset,
              offset + payloadBytesToRead,
            ),
          );
          offset += payloadBytesToRead;

          if (framePayload.length == expectedFrameLength) {
            processFrame(framePayload.takeBytes());
            framePayload = BytesBuilder(copy: false);
            expectedFrameLength = null;
          }
        }
      }

      if (finalImage != null && finalImage!.isNotEmpty) {
        return Right(base64Encode(finalImage!));
      }
      final hasIncompleteFrame = frameHeaderBytes > 0 ||
          expectedFrameLength != null ||
          framePayload.length > 0;
      return Left(
        '${streamError ?? (hasIncompleteFrame ? '완전하지 않은 메시지팩 프레임을 수신했습니다.' : '스트림에 최종 이미지가 없습니다.')} '
        '(Correlation ID: $correlationId)',
      );
    } catch (error) {
      return Left(
        'Image streaming error: $error (Correlation ID: $correlationId)',
      );
    }
  }

  static Uint8List? _messagePackImageBytes(dynamic image) {
    if (image is Uint8List) return image;
    if (image is List<int>) return Uint8List.fromList(image);
    return null;
  }

  @override
  Future<Either<String, List<String>>> generateImageVariations(
      String imageId) async {
    final token = _getPersistentToken();
    if (token == null) return const Left('Persistent token이 설정되지 않았습니다.');
    final headers = {
      'authorization': 'Bearer $token',
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    final body = jsonEncode({'imageId': imageId});
    try {
      final resp = await _httpClient.post(
        Uri.parse(_variationUrl),
        headers: headers,
        body: body,
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return Right((data['images'] as List).cast<String>());
      } else {
        return Left('Variation failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<void> saveImage(String imageBase64, String path) async {
    final bytes = base64Decode(imageBase64);
    await File(path).writeAsBytes(bytes);
  }

  @override
  Future<Either<String, TagSuggestionModel>> suggestTags(
      String prompt, String model) async {
    final headers = {
      'accept': 'application/json',
    };
    String endPoint = '$_suggestionUrl?model=$model&prompt=$prompt';

    try {
      final resp = await _httpClient.get(
        Uri.parse(endPoint),
        headers: headers,
      );
      if (resp.statusCode == 200) {
        TagSuggestionModel tagSuggestionModel =
            TagSuggestionModel.fromJson(jsonDecode(resp.body));
        return Right(tagSuggestionModel);
      }
      return Left('Tag suggestion failed: ${resp.statusCode} ${resp.body}');
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, int>> getAnlasRemaining() {
    String endpoint = _anlasRemainingUrl;
    final token = _getPersistentToken();
    final headers = {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      'authorization': 'Bearer $token',
    };

    try {
      return _httpClient.get(Uri.parse(endpoint), headers: headers).then(
        (resp) {
          if (resp.statusCode == 200) {
            final data = jsonDecode(resp.body) as Map<String, dynamic>;
            final remaining =
                data['trainingStepsLeft'] as Map<String, dynamic>?;
            if (remaining != null) {
              return Right(remaining['fixedTrainingStepsLeft'] +
                  remaining['purchasedTrainingSteps']);
            } else {
              return const Left('Invalid response: remaining is missing');
            }
          } else {
            return Left(
                'ANLAS remaining fetch failed: ${resp.statusCode} ${resp.body}');
          }
        },
      );
    } catch (e) {
      return Future.value(Left('Network error: $e'));
    }
  }

  @override
  Future<Either<String, V5Usage?>> getV5Usage() async {
    final token = _getPersistentToken();
    if (token == null || token.isEmpty) {
      return const Left('Persistent token이 설정되지 않았습니다.');
    }

    try {
      final response = await _httpClient.get(
        Uri.parse(_anlasRemainingUrl),
        headers: {
          'Accept': 'application/json',
          'authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        return Left(
          'V5 사용량 조회 실패: ${response.statusCode} ${_errorMessage(response.body)}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final usage = data['usage'];
      if (usage is! Map<String, dynamic>) return const Right(null);

      return Right(V5Usage.fromJson(usage));
    } on FormatException catch (error) {
      return Left('V5 사용량 응답 형식이 올바르지 않습니다: $error');
    } catch (error) {
      return Left('V5 사용량 조회 중 네트워크 오류가 발생했습니다: $error');
    }
  }

  @override
  Future<Either<String, List<VibeImage>>> vibeParse(
      List<VibeImage> base64imageData, String model) async {
    final token = _getPersistentToken();
    if (token == null) return const Left('Persistent token이 설정되지 않았습니다.');

    final headers = {
      'accept': 'application/octet-stream',
      'authorization': 'Bearer $token',
      'content-type': 'application/json',
    };

    try {
      for (int i = 0; i < base64imageData.length; i++) {
        final double? extractionStrength =
            base64imageData[i].extractionStrength?.value;

        final double prevExtractionStrength =
            base64imageData[i].prevExtractionStrength.value;
        if (extractionStrength == null) continue;

        if (base64imageData[i].image == null) continue;
        if (extractionStrength == prevExtractionStrength) continue;

        String base64image = base64Encode(base64imageData[i].image!);
        final body = jsonEncode({
          'image': base64image,
          'model': model,
          'information_extracted': extractionStrength,
        });
        final correlationId = _newCorrelationId();

        final resp = await _httpClient.post(
          Uri.parse(_vibeParseUrl),
          headers: {...headers, 'x-correlation-id': correlationId},
          body: body,
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          Uint8List data = resp.bodyBytes;
          base64imageData[i].bytes = data;
          base64imageData[i].prevExtractionStrength.value = extractionStrength;
        } else {
          final message = _errorMessage(resp.body);
          if (message ==
              "This model does not support vibe transfer through this endpoint") {
            return const Left('이 모델은 Vibe 파싱을 지원하지 않습니다.');
          }
          return Left(
            'Vibe parse failed: ${resp.statusCode} $message '
            '(Correlation ID: $correlationId)',
          );
        }
      }
      return Right(base64imageData);
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
