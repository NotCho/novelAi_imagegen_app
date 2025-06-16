import 'package:get/get.dart';
import 'package:naiapp/application/home/home_image_controller.dart';

import '../../application/home/home_page_controller.dart';
import '../../application/home/home_setting_controller.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeImageController>(() => HomeImageController());
    Get.lazyPut<HomeSettingController>(() => HomeSettingController());
    Get.put(HomePageController());
  }
}
