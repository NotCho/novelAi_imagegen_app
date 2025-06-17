import 'package:naiapp/application/core/skeleton_controller.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPageController extends SkeletonController {
  final RxBool pngMode = true.obs; // PNG 모드 여부
  final SharedPreferences prefs = Get.find<SharedPreferences>();

  void togglePngMode() {
    pngMode.value = !pngMode.value;
    prefs.setBool('pngMode', pngMode.value);
  }

  void loadPngMode() {
    pngMode.value = prefs.getBool('pngMode') ?? true;
  }

  @override
  Future<bool> initLoading() async {
    return true;
  }

  void logout() {
    Get.find<HomePageController>().logout();
  }
}
