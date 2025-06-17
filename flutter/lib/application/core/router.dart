import 'package:get/get.dart';

abstract class ISkeletonRouter {
  void toSplashOffAll();

  void toLogin();

  void toHome();

  Future<String> toParser(String prompt);

  void toImage();

  void toSetting();
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
    Get.offAllNamed('/home');
  }

  @override
  Future<String> toParser(String prompt) async {
    final result =
        await Get.toNamed('/home/parse', arguments: {'prompt': prompt});
    print(result);
    return result?.toString() ?? '';
  }

  @override
  void toImage() {
    Get.toNamed('/home/image');
  }

  void toSetting() {
    Get.toNamed('/home/setting');
  }
}
