import 'package:get/get.dart';

import '../../application/wildcard/wildcard_controller.dart';

class WildcardPageBinding extends Bindings {
  @override
  void dependencies() {
    // WildcardController는 이미 permanent로 등록되어 있으므로 바인딩만 확인
    if (!Get.isRegistered<WildcardController>()) {
      Get.put<WildcardController>(WildcardController());
    }
  }
}
