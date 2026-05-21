import 'package:get/get.dart';
import 'package:naiapp/application/home/director_tool_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';

class ModelConfigController extends SkeletonController {
  late final HomeImageController homeImageController = Get.find<HomeImageController>();
  late final DirectorToolController directorToolController = Get.find<DirectorToolController>();

  @override
  Future<bool> initLoading() async {
    return true;
  }

  final usingModel = 'nai-diffusion-4-5-full'.obs;

  final Map<String, String> modelNames = {
    'nai-diffusion-4-5-full': 'V4.5 Full',
    'nai-diffusion-4-5-curated': 'V4.5 Curated',
    'nai-diffusion-4-full': 'V4 Full',
    'nai-diffusion-4-curated-preview': 'V4 Curated',
    'nai-diffusion-3': 'V3 Full',
  };

  final List<String> noiseScheduleOptions = [
    'karras',
    'exponential',
    'polyexponential'
  ];

  final RxString selectedNoiseSchedule = 'karras'.obs;

  bool modelSupportsVibeTransfer(String model) {
    return model.startsWith('nai-diffusion-4');
  }

  bool modelSupportsCharacterReference(String model) {
    return model.startsWith('nai-diffusion-4-5');
  }

  bool get supportsVibeTransfer => modelSupportsVibeTransfer(usingModel.value);

  bool get supportsCharacterReference =>
      modelSupportsCharacterReference(usingModel.value);

  void setModel(String model) {
    usingModel.value = model;
    if (!supportsVibeTransfer) {
      homeImageController.vibeParseImageBytes.clear();
    }
    if (!supportsCharacterReference) {
      directorToolController.reset();
    }
  }
}
