

import 'package:get/get.dart';

import '../../application/image/image_page_controller.dart';

class ImagePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ImagePageController());
  }
}