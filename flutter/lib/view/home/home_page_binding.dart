import 'package:get/get.dart';
import 'package:naiapp/application/home/home_image_controller.dart';

import '../../application/home/auto_generation_controller.dart';
import '../../application/home/director_tool_controller.dart';
import '../../application/home/image_load_controller.dart';
import '../../application/home/home_page_controller.dart';
import '../../application/home/home_setting_controller.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeImageController>(() => HomeImageController());
    Get.lazyPut<HomeSettingController>(() => HomeSettingController());
    Get.lazyPut<AutoGenerationController>(() => AutoGenerationController());
    Get.lazyPut<ImageLoadController>(() => ImageLoadController());
    Get.lazyPut<DirectorToolController>(() => DirectorToolController());
    Get.put(HomePageController());
  }
}
