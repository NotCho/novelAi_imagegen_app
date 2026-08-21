import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:naiapp/domain/gen/diffusion_model.dart';
import 'package:naiapp/domain/gen/i_novelAI_repository.dart';
import 'package:naiapp/infra/gen/novelAI_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('streams intermediate images and returns only the final image',
      () async {
    SharedPreferences.setMockInitialValues({
      'NOVEL_AI_PERSISTENT_TOKEN': 'pst-test-token',
      imageGenerationStreamingModePreferenceKey: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final intermediateImage = base64Encode([1, 2, 3]);
    final finalImage = base64Encode([4, 5, 6]);

    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/ai/generate-image-stream');
      expect(request.headers['authorization'], 'Bearer pst-test-token');
      expect(request.headers['accept'], 'text/event-stream');
      expect(request.headers['x-correlation-id'], matches(r'^[a-z0-9]{6}$'));

      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final parameters = body['parameters'] as Map<String, dynamic>;
      expect(parameters['stream'], 'sse');

      return http.Response(
        'data: ${jsonEncode({
              'event_type': 'intermediate',
              'samp_ix': 0,
              'step_ix': 4,
              'gen_id': 1,
              'sigma': 1.0,
              'image': intermediateImage,
            })}\n\n'
        'data: ${jsonEncode({
              'event_type': 'final',
              'samp_ix': 0,
              'step_ix': 28,
              'gen_id': 1,
              'sigma': 0.0,
              'image': finalImage,
            })}\n\n',
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    });
    final repository = NovelAIRepository(httpClient: client, prefs: prefs);
    final previews = <String>[];

    final result = await repository.generateImage(
      setting: _testSetting(),
      onIntermediateImage: previews.add,
    );

    expect(previews, [intermediateImage]);
    result.fold(
      (error) => fail(error),
      (image) => expect(image, finalImage),
    );
  });

  test('uses the regular ZIP endpoint when streaming mode is off', () async {
    SharedPreferences.setMockInitialValues({
      'NOVEL_AI_PERSISTENT_TOKEN': 'pst-test-token',
      imageGenerationStreamingModePreferenceKey: false,
    });
    final prefs = await SharedPreferences.getInstance();

    final client = MockClient((request) async {
      expect(request.url.path, '/ai/generate-image');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final parameters = body['parameters'] as Map<String, dynamic>;
      expect(parameters.containsKey('stream'), isFalse);
      return http.Response('expected test rejection', 400);
    });
    final repository = NovelAIRepository(httpClient: client, prefs: prefs);

    final result = await repository.generateImage(setting: _testSetting());

    result.fold(
      (error) => expect(error, contains('Image generation failed: 400')),
      (_) => fail('The rejected regular request must not succeed.'),
    );
  });
}

DiffusionModel _testSetting() {
  return const DiffusionModel(
    input: 'test prompt',
    model: 'nai-diffusion-5-full',
    action: 'generate',
    parameters: Parameters(
      params_version: 3,
      width: 832,
      height: 1216,
      scale: 5,
      sampler: 'k_euler_ancestral',
      steps: 28,
      n_samples: 1,
      ucPreset: 0,
      qualityToggle: false,
      autoSmea: false,
      dynamic_thresholding: false,
      controlnet_strength: 1,
      legacy: false,
      add_original_image: false,
      cfg_rescale: 0,
      noise_schedule: 'karras',
      legacy_v3_extend: false,
      use_coords: false,
      legacy_uc: false,
      normalize_reference_strength_multiple: true,
      v4_prompt: V4Prompt(
        caption: Caption(base_caption: 'test prompt'),
        use_order: true,
        use_coords: false,
      ),
      v4_negative_prompt: V4NegativePrompt(
        caption: Caption(base_caption: ''),
        legacy_uc: false,
      ),
      seed: 123,
      characterPrompts: [],
      negative_prompt: '',
      deliberate_euler_ancestral_bug: false,
      prefer_brownian: true,
    ),
  );
}
