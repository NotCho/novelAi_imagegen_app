
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/domain/gen/diffusion_model.dart';
import 'package:dartz/dartz.dart';
import 'package:naiapp/domain/gen/tag_suggestion_model.dart';

// NovelAI 이미지 생성을 위한 인터페이스
abstract class INovelAIRepository {
  Future<Either<String, String>> generateImage({
    required DiffusionModel setting,
  });

  Future<Either<String, List<String>>> generateImageVariations(String imageId);

  Future<void> saveImage(String imageBase64, String path);

  Future<void> setApiKey(String apiKey);

  String? getApiKey();

  Future<Either<String, String>> createPersistentToken();

  Future<Either<String, String>> fetchAccessKey(String email, String password);

  Future<Either<String, TagSuggestionModel>> suggestTags(
      String prompt, String model);

  Future<Either<String, int>> getAnlasRemaining();

  Future<Either<String, List<VibeImage>>> vibeParse(
      List<VibeImage> base64imageData, String model);
}
