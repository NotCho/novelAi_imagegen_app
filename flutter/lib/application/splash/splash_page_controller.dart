import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../core/skeleton_controller.dart';
import '../../domain/gen/i_novelAI_repository.dart';

class SplashPageController extends SkeletonController {
  Future<void> _testLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    final persistentToken = prefs.getString("NOVEL_AI_PERSISTENT_TOKEN");
    if (persistentToken != null && persistentToken.isNotEmpty) {
      router.toHome();
      return;
    }

    // 기존 사용자(AccessKey는 있으나 PersistentToken이 없는 경우) 마이그레이션 시도
    final accessKey = prefs.getString("NOVEL_AI_ACCESS_KEY");
    if (accessKey != null && accessKey.isNotEmpty) {
      final repo = Get.find<INovelAIRepository>();
      final result = await repo.createPersistentToken();
      result.fold(
        (_) => router.toLogin(),
        (_) => router.toHome(),
      );
      return;
    }

    router.toLogin();
  }

  @override
  Future<bool> initLoading() async {
    Future.delayed(const Duration(seconds: 0), _testLoginState);
    return true;
  }
}
