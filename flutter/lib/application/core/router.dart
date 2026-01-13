import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

abstract class ISkeletonRouter {
  void toSplashOffAll();

  void toLogin();

  void toHome();

  Future<String> toParser(String prompt);

  void toImage();

  void toSetting();

  void toWildcard();
}

class SkeletonRouter implements ISkeletonRouter {
  @override
  void toSplashOffAll() {
    Get.offAllNamed('/');
  }

  @override
  void toLogin() {
    Get.offAllNamed('/login');
  }

  @override
  void toHome() {
    Get.offAllNamed('/home', );
  }

  @override
  Future<String> toParser(String prompt) async {
    final result =
        await Get.toNamed('/home/parse', arguments: {'prompt': prompt});
    if (kDebugMode) {
      print(result);
    }
    return result?.toString() ?? '';
  }

  @override
  void toImage() {
    Get.toNamed('/home/image');
  }

  @override
  void toSetting() {
    Get.toNamed('/home/setting');
  }

  @override
  void toWildcard() {
    Get.toNamed('/home/wildcard');
  }
}
