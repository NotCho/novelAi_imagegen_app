import 'package:get/get.dart';
import 'package:naiapp/application/home/home_auto_generation_controller.dart';
import 'package:naiapp/application/home/home_character_controller.dart';
import 'package:naiapp/application/home/home_generation_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeImageController>(() => HomeImageController(), fenix: true);
    Get.lazyPut<HomeSettingController>(() => HomeSettingController(), fenix: true);
    Get.lazyPut<HomeCharacterController>(() => HomeCharacterController(), fenix: true);
    Get.lazyPut<HomeGenerationController>(() => HomeGenerationController(), fenix: true);
    Get.lazyPut<HomeAutoGenerationController>(() => HomeAutoGenerationController(), fenix: true);
    Get.lazyPut<HomePageController>(() => HomePageController(), fenix: true);
  }
}
