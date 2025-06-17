import 'package:get/get.dart';

import '../../application/setting/setting_page_controller.dart';

class SettingPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingPageController>(() => SettingPageController());
  }
}
