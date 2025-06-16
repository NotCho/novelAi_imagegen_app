import 'package:get/get.dart';

import '../../application/parser/parser_page_controller.dart';

class ParserPageBinding extends Bindings {
  @override
  void dependencies() {
    Map<String, dynamic> arguments = Get.arguments;
    String prompt = arguments['prompt'] ?? '';
    Get.put(ParserPageController(prompt: prompt));
  }
}
