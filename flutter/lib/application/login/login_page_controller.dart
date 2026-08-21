import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naiapp/domain/gen/i_novelAI_repository.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import '../core/skeleton_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view/core/util/app_snackbar.dart';

class LoginPageController extends SkeletonController
    with GetSingleTickerProviderStateMixin {
  AnimationController? animationController;

  RxBool inProgress = false.obs;
  RxDouble alpha = 1.0.obs;
  RxBool readyToShowMap = false.obs;

  TextEditingController persistentTokenController = TextEditingController();

  final SharedPreferences prefs = Get.find<SharedPreferences>();

  @override
  Future<bool> initLoading() async {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    return true;
  }

  void onMapCreated() {
    alpha.value = 0.0;
  }

  void onGoogleTap() async {}

  Future<void> onLogin() async {
    if (inProgress.value) return;
    await onLoginWithPersistentToken();
  }

  Future<void> onLoginWithPersistentToken() async {
    final token = persistentTokenController.text.trim();
    if (token.isEmpty) {
      AppSnackBar.show("오류", "Persistent Token을 입력해주세요.",
          backgroundColor: CupertinoColors.systemRed,
          textColor: CupertinoColors.white,
          duration: const Duration(seconds: 2));
      return;
    }

    inProgress.value = true;
    // 우선 저장해 Repository(getAnlasRemaining)가 참조할 수 있게 한 뒤, ANLAS 조회로 토큰 유효성 검증
    await prefs.setString("NOVEL_AI_PERSISTENT_TOKEN", token);

    INovelAIRepository userRepository = Get.find<INovelAIRepository>();
    final result = await userRepository.getAnlasRemaining();

    result.fold(
      (l) async {
        // 토큰이 유효하지 않거나 네트워크/인증 오류면 저장된 토큰 제거
        await prefs.remove("NOVEL_AI_PERSISTENT_TOKEN");
        if (l.contains('401')) {
          AppSnackBar.show("토큰 확인 실패", "토큰이 유효하지 않습니다.",
              backgroundColor: CupertinoColors.systemRed,
              textColor: CupertinoColors.white,
              duration: const Duration(seconds: 3));
        } else {
          AppSnackBar.show("토큰 확인 실패", l,
              backgroundColor: CupertinoColors.systemRed,
              textColor: CupertinoColors.white,
              duration: const Duration(seconds: 3));
        }
      },
      (remaining) {
        Get.offAllNamed("/home");
      },
    );

    inProgress.value = false;
  }

  @override
  void onClose() {
    persistentTokenController.dispose();
    animationController?.dispose();
    super.onClose();
  }

  void showTokenDialog() {
    Get.dialog(AlertDialog(
      backgroundColor: SkeletonColorScheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: SkeletonColorScheme.surfaceColor),
      ),
      title: Text(
        "토큰 발급 방법",
        style: SkeletonTextTheme.newBody18Bold
            .copyWith(color: SkeletonColorScheme.primaryColor),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "NAI APP은 NovelAI 계정 비밀번호를 받지 않습니다. "
              "NovelAI 웹에서 직접 발급한 Persistent API Token으로만 로그인할 수 있어요.",
              style: SkeletonTextTheme.timestamp
                  .copyWith(color: SkeletonColorScheme.textSecondaryColor),
            ),
            SkeletonSpacing.vSmall,
            guideTile("assets/images/guide_image.png",
                "1. NovelAI 웹에 로그인한 뒤, 메인 화면 좌측 상단의 톱니바퀴를 누르세요.\n Account에서 Persistent API Token 발급 메뉴를 선택합니다."),
            guideTile("assets/images/guide_image2.png",
                "2. Overwrite를 누르면 새 토큰이 발급됩니다.\n 기존 토큰은 바로 무효화되므로, 다른 앱에서 사용 중이었다면 새 토큰으로 다시 등록해야 해요."),
            guideTile("assets/images/guide_image3.png",
                "3. 복사 아이콘으로 토큰을 복사한 뒤 이 화면에 붙여넣고 로그인하세요.\n 토큰은 계정 비밀번호처럼 안전하게 보관해 주세요."),
          ],
        ),
      ),
    ));
  }

  Widget guideTile(String assetPath, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: SkeletonColorScheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(assetPath, fit: BoxFit.contain),
            SkeletonSpacing.vTiny,
            Text(
              content,
              style: SkeletonTextTheme.timestamp
                  .copyWith(color: SkeletonColorScheme.textSecondaryColor),
            ),
          ]),
    );
  }
}
