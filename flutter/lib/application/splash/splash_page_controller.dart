import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../core/skeleton_controller.dart';
import '../../domain/gen/i_novelAI_repository.dart';

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

    // 기존 사용자(AccessKey는 있으나 PersistentToken이 없는 경우) 마이그레이션 시도
    final accessKey = prefs.getString("NOVEL_AI_ACCESS_KEY");
    print('[SplashController] accessKey: $accessKey');
    if (accessKey != null && accessKey.isNotEmpty) {
      print('[SplashController] AccessKey found. Migration starting...');
      final repo = Get.find<INovelAIRepository>();
      final result = await repo.createPersistentToken();
      result.fold(
        (l) {
          print('[SplashController] Migration failed: $l. Routing to Login...');
          router.toLogin();
        },
        (r) {
          print('[SplashController] Migration success! Routing to Home...');
          router.toHome();
        },
      );
      return;
    }

    print('[SplashController] No keys found. Routing to Login...');
    router.toLogin();
  }

  @override
  Future<bool> initLoading() async {
    print('[SplashController] initLoading started...');
    Future.delayed(const Duration(seconds: 0), _testLoginState);
    return true;
  }
}
