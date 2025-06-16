import 'package:get/get.dart';

import '../../application/login/login_page_controller.dart';

class LoginPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(LoginPageController());
  }
}
