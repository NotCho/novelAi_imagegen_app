import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/domain/gen/tag_suggestion_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive.dart';
import 'package:dartz/dartz.dart';
import '../../domain/gen/diffusion_model.dart';
import '../../domain/gen/i_novelAI_repository.dart';

/// NovelAIRepository: 이메일+비밀번호로 one-time key를 받아 로그인하고,
/// 이미지 생성 및 변형 기능을 제공합니다.
class NovelAIRepository implements INovelAIRepository {
  // Cloud Function endpoint returning { accessKey }
  static const String _keyEndpoint =
      'https://us-central1-nai-login.cloudfunctions.net/get_novelai_key';

  // NovelAI REST endpoints
  static const String _loginUrl = 'https://api.novelai.net/user/login';
  static const String _createTokenUrl =
      'https://api.novelai.net/user/create-persistent-token';
  static const String _imageUrl = 'https://image.novelai.net/ai/generate-image';
  static const String _variationUrl =
      'https://image.novelai.net/ai/generate-image-variation';
  static const String _suggestionUrl =
      'https://image.novelai.net/ai/generate-image/suggest-tags';
  static const String _anlasRemainingUrl =
      "https://api.novelai.net/user/subscription";

  static const String _vibeParseUrl =
      "https://image.novelai.net/ai/encode-vibe";

  final http.Client _httpClient;
  final SharedPreferences _prefs;

  NovelAIRepository({http.Client? httpClient, SharedPreferences? prefs})
      : _httpClient = httpClient ?? http.Client(),
        _prefs = prefs ??
            (throw Exception(
                'SharedPreferences not provided to NovelAIRepository'));

  @override
  String? getApiKey() => _prefs.getString('NOVEL_AI_ACCESS_KEY');

  String tempAccessKey = "";

  @override
  Future<void> setApiKey(String apiKey) async {
    await _prefs.setString('NOVEL_AI_ACCESS_KEY', apiKey);
  }

  @override
  Future<Either<String, String>> createPersistentToken() async {
    if (tempAccessKey.isEmpty) {
      final oneTimeKey = getApiKey();
      if (oneTimeKey == null) {
        return const Left('AccessKey가 설정되지 않았습니다. fetchAccessKey를 먼저 호출하세요.');
      } else {
        tempAccessKey = oneTimeKey;
      }
    }
    try {
      final loginResp = await _httpClient.post(
        Uri.parse(_loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({'key': tempAccessKey}),
      );
      if (loginResp.statusCode != 200 && loginResp.statusCode != 201) {
        return Left('로그인 실패: ${loginResp.body}');
      }
      final loginData = jsonDecode(loginResp.body) as Map<String, dynamic>;
      final jwt = loginData['accessToken'] as String?;
      if (jwt == null || jwt.isEmpty) {
        return const Left('Invalid response: accessToken이 없습니다.');
      }
      final pstResp = await _httpClient.post(
        Uri.parse(_createTokenUrl),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'overwrite': true}),
      );
      if (pstResp.statusCode != 201) {
        return Left('Persistent token 생성 실패: ${pstResp.body}');
      }
      final pstData = jsonDecode(pstResp.body) as Map<String, dynamic>;
      final pst = pstData['token'] as String?;
      if (pst == null || pst.isEmpty) {
        return const Left('Invalid response: persistent token이 없습니다.');
      }
      await _prefs.setString('NOVEL_AI_PERSISTENT_TOKEN', pst);
      await _prefs.setString('NOVEL_AI_ACCESS_KEY', tempAccessKey);
      return Right(pst);
    } catch (e) {
      return Left('Network error during token creation: $e');
    }
  }

  String? _getPersistentToken() =>
      _prefs.getString('NOVEL_AI_PERSISTENT_TOKEN');

  @override
  Future<Either<String, String>> generateImage({
    required DiffusionModel setting,
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

    try {
      final resp = await _httpClient.post(
        Uri.parse(_imageUrl),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (resp.statusCode == 200) {
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
  Future<Either<String, String>> fetchAccessKey(
      String email, String password) async {
    try {
      final resp = await _httpClient.post(
        Uri.parse(_keyEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (resp.statusCode != 200) {
        return Left('Key fetch failed: ${resp.body}');
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final key = data['accessKey'] as String?;
      if (key == null || key.isEmpty) {
        return const Left('Invalid response: accessKey is missing');
      }
      tempAccessKey = key;
      return Right(key);
    } catch (e) {
      return Left('Network error: $e');
    }
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
  Future<Either<String, List<VibeImage>>> vibeParse(
      List<VibeImage> base64imageData, String model) async {
    final token = _getPersistentToken();
    if (token == null) return const Left('Persistent token이 설정되지 않았습니다.');

    final headers = {
      'accept': 'application/json',
      'authorization': 'Bearer $token',
    };

    try {
      for (int i = 0; i < base64imageData.length; i++) {
        double? extractionStrength =
            base64imageData[i].extractionStrength?.value;

        double? prevExtractionStrength =
            base64imageData[i].prevExtractionStrength?.value;
        if (extractionStrength == null && prevExtractionStrength == null) {
          continue;
        }

        if (base64imageData[i].image == null) continue;
        if (extractionStrength == prevExtractionStrength) continue;

        String base64image = base64Encode(base64imageData[i].image!);
        final body = jsonEncode({'image': base64image, 'model': model});

        final resp = await _httpClient.post(
          Uri.parse(_vibeParseUrl),
          headers: headers,
          body: body,
        );
        if (resp.statusCode == 200) {
          Uint8List data = resp.bodyBytes;
          base64imageData[i].bytes = data;
          base64imageData[i].prevExtractionStrength!.value =
              base64imageData[i].extractionStrength!.value;
        } else {
          if (jsonDecode(resp.body)['message'] ==
              "This model does not support vibe transfer through this endpoint") {
            return const Left('이 모델은 Vibe 파싱을 지원하지 않습니다.');
          }
          return Left('Vibe parse failed: ${resp.statusCode} ${resp.body}');
        }
      }
      return Right(base64imageData);
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
