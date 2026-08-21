import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/image_generation_controller.dart';
import 'package:naiapp/application/home/model_config_controller.dart';
import 'package:naiapp/infra/gen/novelAI_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('encodes a V4 vibe with the API request contract', () async {
    SharedPreferences.setMockInitialValues({
      'NOVEL_AI_PERSISTENT_TOKEN': 'pst-test-token',
    });
    final prefs = await SharedPreferences.getInstance();

    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/ai/encode-vibe');
      expect(request.headers['authorization'], 'Bearer pst-test-token');
      expect(request.headers['content-type'], startsWith('application/json'));
      expect(request.headers['accept'], 'application/octet-stream');
      expect(request.headers['x-correlation-id'], matches(r'^[a-z0-9]{6}$'));

      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['model'], 'nai-diffusion-4-5-full');
      expect(body['image'], base64Encode([1, 2, 3]));
      expect(body['information_extracted'], 0.75);

      return http.Response.bytes([4, 5, 6], 201);
    });

    final vibe = VibeImage(
      image: Uint8List.fromList([1, 2, 3]),
      weight: 0.6.obs,
      extractionStrength: 0.75.obs,
    );
    final repository = NovelAIRepository(httpClient: client, prefs: prefs);

    final result = await repository.vibeParse([vibe], 'nai-diffusion-4-5-full');

    result.fold(
      (error) => fail(error),
      (encodedVibes) {
        expect(encodedVibes.single.bytes, Uint8List.fromList([4, 5, 6]));
        expect(encodedVibes.single.prevExtractionStrength.value, 0.75);
      },
    );
  });

  test('normalizes a V3 Vibe source to a black 448px square', () {
    final source = img.Image(width: 200, height: 100);
    img.fill(source, color: img.ColorRgb8(255, 255, 255));

    final normalized = HomeImageController.prepareV3VibeImage(
      Uint8List.fromList(img.encodePng(source)),
    );
    final decoded = img.decodeImage(normalized)!;

    expect(decoded.width, 448);
    expect(decoded.height, 448);
    expect(decoded.getPixel(0, 0).r, 0);
    expect(decoded.getPixel(224, 224).r, 255);
  });

  test('V5 models use the same reference feature contract as V4.5', () {
    for (final model in [
      'nai-diffusion-5-full',
      'nai-diffusion-5-curated',
    ]) {
      expect(ModelConfigController.supportedModelNames[model], isNotNull);
      expect(ModelConfigController.isV5Model(model), isTrue);
      expect(
        ModelConfigController.supportsVibeTransferForModel(model),
        isTrue,
      );
      expect(
        ModelConfigController.requiresVibeEncodingForModel(model),
        isTrue,
      );
      expect(
        ModelConfigController.supportsCharacterReferenceForModel(model),
        isTrue,
      );
    }

    expect(ModelConfigController.isV5Model('nai-diffusion-4-5-full'), isFalse);
  });

  test('warns only when V5 generation includes Vibe images', () {
    expect(
      ImageGenerationController.shouldWarnV5VibeTransfer(
        model: 'nai-diffusion-5-full',
        hasVibeImages: true,
      ),
      isTrue,
    );
    expect(
      ImageGenerationController.shouldWarnV5VibeTransfer(
        model: 'nai-diffusion-5-curated',
        hasVibeImages: false,
      ),
      isFalse,
    );
    expect(
      ImageGenerationController.shouldWarnV5VibeTransfer(
        model: 'nai-diffusion-4-5-full',
        hasVibeImages: true,
      ),
      isFalse,
    );
  });
}
