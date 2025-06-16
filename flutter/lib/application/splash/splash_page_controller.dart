import 'package:shared_preferences/shared_preferences.dart';

import '../core/skeleton_controller.dart';

class SplashPageController extends SkeletonController {
  Future<void> _testLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("NOVEL_AI_ACCESS_KEY") == null) {
      router.toLogin();
      return;
    }
    router.toHome();
  }

  @override
  Future<bool> initLoading() async {
    Future.delayed(const Duration(seconds: 0), _testLoginState);
    return true;
  }
}
