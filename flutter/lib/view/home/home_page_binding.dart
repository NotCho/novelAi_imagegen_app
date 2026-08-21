import 'package:get/get.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/auto_generation_controller.dart';
import 'package:naiapp/application/home/director_tool_controller.dart';
import 'package:naiapp/application/home/image_load_controller.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';
import 'package:naiapp/application/home/prompt_controller.dart';
import 'package:naiapp/application/home/preset_controller.dart';
import 'package:naiapp/application/home/model_config_controller.dart';
import 'package:naiapp/application/home/diffusion_model_builder.dart';
import 'package:naiapp/application/home/image_generation_controller.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeImageController>(() => HomeImageController());
    Get.lazyPut<HomeSettingController>(() => HomeSettingController());
    Get.lazyPut<AutoGenerationController>(() => AutoGenerationController());
    Get.lazyPut<ImageLoadController>(() => ImageLoadController());
    Get.lazyPut<DirectorToolController>(() => DirectorToolController());
    Get.lazyPut<PromptController>(() => PromptController());
    Get.lazyPut<PresetController>(() => PresetController());
    
    Get.lazyPut<ModelConfigController>(() => ModelConfigController());
    Get.lazyPut<DiffusionModelBuilder>(() => DiffusionModelBuilder());
    Get.lazyPut<ImageGenerationController>(() => ImageGenerationController());
    
    Get.put(HomePageController());
  }
}
