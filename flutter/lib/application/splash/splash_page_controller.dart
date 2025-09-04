import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naiapp/domain/gen/i_novelAI_repository.dart';

import '../core/skeleton_controller.dart';

class SplashPageController extends SkeletonController {
  final INovelAIRepository _novelAIRepository = Get.find<INovelAIRepository>();
  Future<void> _testLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("NOVEL_AI_ACCESS_KEY") == null) {
      router.toLogin();
      return;
    }
    final tokenResult = await _novelAIRepository.createPersistentToken();
    tokenResult.fold(
      (l) => print('토큰 생성 중 오류가 발생했습니다: $l'),
      (r) => print('토큰 생성 성공: $r'),
    );
    router.toHome();
  }

  @override
  Future<bool> initLoading() async {
    Future.delayed(const Duration(seconds: 0), _testLoginState);
    return true;
  }
}
