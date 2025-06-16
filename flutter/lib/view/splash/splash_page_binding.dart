import 'package:get/get.dart';

import '../../application/splash/splash_page_controller.dart';

class SplashPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SplashPageController());
  }
}
