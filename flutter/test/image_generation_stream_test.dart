import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:naiapp/domain/gen/diffusion_model.dart';
import 'package:naiapp/domain/gen/i_novelAI_repository.dart';
import 'package:naiapp/infra/gen/novelAI_repository.dart';
import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('decodes chunked MessagePack previews and returns only the final image',
      () async {
    SharedPreferences.setMockInitialValues({
      'NOVEL_AI_PERSISTENT_TOKEN': 'pst-test-token',
      imageGenerationStreamingModePreferenceKey: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final intermediateImage = Uint8List.fromList([1, 2, 3]);
    final finalImage = Uint8List.fromList([4, 5, 6]);
    final streamBytes = BytesBuilder(copy: false)
      ..add(_messagePackFrame({
        'event_type': 'intermediate',
        'samp_ix': 0,
        'step_ix': 4,
        'gen_id': 1,
        'sigma': 1.0,
        'image': intermediateImage,
      }))
      ..add(_messagePackFrame({
        'event_type': 'final',
        'samp_ix': 0,
        'step_ix': 28,
        'gen_id': 1,
        'sigma': 0.0,
        'image': finalImage,
      }));
    final responseBytes = streamBytes.takeBytes();

    final client = MockClient.streaming((request, bodyStream) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/ai/generate-image-stream');
      expect(request.headers['authorization'], 'Bearer pst-test-token');
      expect(request.headers['accept'], 'application/msgpack');
      expect(request.headers['x-correlation-id'], matches(r'^[a-z0-9]{6}$'));
      expect(DateTime.tryParse(request.headers['x-initiated-at']!), isNotNull);

      final requestBytes = await bodyStream.toBytes();
      final body =
          jsonDecode(utf8.decode(requestBytes)) as Map<String, dynamic>;
      final parameters = body['parameters'] as Map<String, dynamic>;
      expect(parameters['stream'], 'msgpack');

      return http.StreamedResponse(
        Stream<List<int>>.fromIterable([
          responseBytes.sublist(0, 2),
          responseBytes.sublist(2, 11),
          responseBytes.sublist(11, responseBytes.length - 3),
          responseBytes.sublist(responseBytes.length - 3),
        ]),
        200,
        headers: {'content-type': 'application/msgpack'},
      );
    });
    final repository = NovelAIRepository(httpClient: client, prefs: prefs);
    final previews = <Uint8List>[];

    final result = await repository.generateImage(
      setting: _testSetting(),
      onIntermediateImage: previews.add,
    );

    expect(previews, hasLength(1));
    expect(previews.single, orderedEquals(intermediateImage));
    result.fold(
      (error) => fail(error),
      (image) => expect(image, base64Encode(finalImage)),
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

Uint8List _messagePackFrame(Map<String, dynamic> event) {
  final payload = msgpack.serialize(event);
  final frame = Uint8List(4 + payload.length);
  ByteData.sublistView(frame).setUint32(0, payload.length, Endian.big);
  frame.setRange(4, frame.length, payload);
  return frame;
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
