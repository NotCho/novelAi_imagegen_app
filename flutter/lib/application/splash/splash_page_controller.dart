import 'package:shared_preferences/shared_preferences.dart';

import '../core/skeleton_controller.dart';

class SplashPageController extends SkeletonController {
  Future<void> _testLoginState() async {
    print('[SplashController] Testing login state...');
    final prefs = await SharedPreferences.getInstance();
    final persistentToken = prefs.getString("NOVEL_AI_PERSISTENT_TOKEN");
    print('[SplashController] persistentToken: $persistentToken');
    if (persistentToken != null && persistentToken.isNotEmpty) {
      print('[SplashController] Routing to Home...');
      router.toHome();
      return;
    }

    print('[SplashController] No persistent token found. Routing to Login...');
    router.toLogin();
  }

  @override
  Future<bool> initLoading() async {
    print('[SplashController] initLoading started...');
    Future.delayed(const Duration(seconds: 0), _testLoginState);
    return true;
  }
}
