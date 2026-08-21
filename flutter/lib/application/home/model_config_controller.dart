import 'package:get/get.dart';
import 'package:naiapp/application/home/director_tool_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';

class ModelConfigController extends SkeletonController {
  late final HomeImageController homeImageController =
      Get.find<HomeImageController>();
  late final DirectorToolController directorToolController =
      Get.find<DirectorToolController>();

  @override
  Future<bool> initLoading() async {
    return true;
  }

  final usingModel = 'nai-diffusion-4-5-full'.obs;

  static const Map<String, String> supportedModelNames = {
    'nai-diffusion-5-full': 'V5 Full',
    'nai-diffusion-5-curated': 'V5 Curated',
    'nai-diffusion-4-5-full': 'V4.5 Full',
    'nai-diffusion-4-5-curated': 'V4.5 Curated',
    'nai-diffusion-4-full': 'V4 Full',
    'nai-diffusion-4-curated-preview': 'V4 Curated',
    'nai-diffusion-3': 'V3 Full',
  };

  final Map<String, String> modelNames = supportedModelNames;

  final List<String> noiseScheduleOptions = [
    'karras',
    'exponential',
    'polyexponential'
  ];

  final RxString selectedNoiseSchedule = 'karras'.obs;

  bool modelSupportsVibeTransfer(String model) {
    return supportsVibeTransferForModel(model);
  }

  static bool supportsVibeTransferForModel(String model) {
    return model.startsWith('nai-diffusion-3') ||
        model.startsWith('nai-diffusion-4') ||
        model.startsWith('nai-diffusion-5');
  }

  static bool isV5Model(String model) {
    return model.startsWith('nai-diffusion-5');
  }

  /// V3 Vibe Transfer accepts a normalized source image in the generation
  /// payload. V4 and newer models require an encode-vibe request first.
  bool modelRequiresVibeEncoding(String model) {
    return requiresVibeEncodingForModel(model);
  }

  static bool requiresVibeEncodingForModel(String model) {
    return model.startsWith('nai-diffusion-4') ||
        model.startsWith('nai-diffusion-5');
  }

  bool modelSupportsCharacterReference(String model) {
    return supportsCharacterReferenceForModel(model);
  }

  static bool supportsCharacterReferenceForModel(String model) {
    return model.startsWith('nai-diffusion-4-5') ||
        model.startsWith('nai-diffusion-5');
  }

  bool get supportsVibeTransfer => modelSupportsVibeTransfer(usingModel.value);

  bool get isV5 => isV5Model(usingModel.value);

  bool get requiresVibeEncoding => modelRequiresVibeEncoding(usingModel.value);

  bool get supportsCharacterReference =>
      modelSupportsCharacterReference(usingModel.value);

  void setModel(String model) {
    final wasVibeEncoded = modelRequiresVibeEncoding(usingModel.value);
    final willUseVibeEncoding = modelRequiresVibeEncoding(model);
    usingModel.value = model;
    // V3 accepts a source image while V4+ stores an encode-vibe result. These
    // formats are not interchangeable, so never carry one across the boundary.
    if (!supportsVibeTransfer || wasVibeEncoded != willUseVibeEncoding) {
      homeImageController.vibeParseImageBytes.clear();
    }
    if (!supportsCharacterReference) {
      directorToolController.reset();
    }
  }
}
