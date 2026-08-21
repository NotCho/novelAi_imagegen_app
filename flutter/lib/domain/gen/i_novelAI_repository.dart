import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/domain/gen/diffusion_model.dart';
import 'package:dartz/dartz.dart';
import 'package:naiapp/domain/gen/tag_suggestion_model.dart';
import 'package:naiapp/domain/gen/v5_usage.dart';

const String imageGenerationStreamingModePreferenceKey =
    'imageGenerationStreamingMode';

// NovelAI 이미지 생성을 위한 인터페이스
abstract class INovelAIRepository {
  Future<Either<String, String>> generateImage({
    required DiffusionModel setting,
    void Function(String base64Image)? onIntermediateImage,
  });

  Future<Either<String, List<String>>> generateImageVariations(String imageId);

  Future<void> saveImage(String imageBase64, String path);

  Future<Either<String, TagSuggestionModel>> suggestTags(
      String prompt, String model);

  Future<Either<String, int>> getAnlasRemaining();

  /// Returns null when the account is not eligible for the V5 Opus allowance.
  Future<Either<String, V5Usage?>> getV5Usage();

  Future<Either<String, List<VibeImage>>> vibeParse(
      List<VibeImage> base64imageData, String model);
}
