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

  /// 0: 이메일/비밀번호 로그인, 1: Persistent Token 입력 로그인
  RxInt loginMode = 0.obs;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
    if (loginMode.value == 1) {
      await onLoginWithPersistentToken();
      return;
    }
    await onLoginWithEmail();
  }

  Future<void> onLoginWithEmail() async {
    if (emailController.text.isEmpty) {
      AppSnackBar.show("오류", "이메일을 입력해주세요.",
          backgroundColor: CupertinoColors.systemRed,
          textColor: CupertinoColors.white,
          duration: const Duration(seconds: 2));
      return;
    }
    if (passwordController.text.isEmpty) {
      AppSnackBar.show("오류", "비밀번호를 입력해주세요.",
          backgroundColor: CupertinoColors.systemRed,
          textColor: CupertinoColors.white,
          duration: const Duration(seconds: 2));
      return;
    }

    inProgress.value = true;
    INovelAIRepository userRepository = Get.find<INovelAIRepository>();
    final result = await userRepository.fetchAccessKey(
        emailController.text, passwordController.text);

    result.fold((l) {
      AppSnackBar.show("오류", l,
          backgroundColor: CupertinoColors.systemRed,
          textColor: CupertinoColors.white,
          duration: const Duration(seconds: 2));
    }, (r) {
      getToken();
    });
    inProgress.value = false;
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

  Future<void> getToken() async {
    INovelAIRepository userRepository = Get.find<INovelAIRepository>();
    final result = await userRepository.createPersistentToken();

    result.fold((l) {
      AppSnackBar.show("오류", l,
          backgroundColor: CupertinoColors.systemRed,
          textColor: CupertinoColors.white,
          duration: const Duration(seconds: 2));
    }, (r) {
      Get.offAllNamed("/home");
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
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
        child: Wrap(
          children: [
            guideTile("assets/images/guide_image.png",
                "1. 메인 페이지 좌측 상단의 톱니바퀴를 누른 후 \n Account - Get President API Token 을 탭 합니다"),
            guideTile("assets/images/guide_image2.png",
                "2. Overwrite 를 탭 합니다. \n(기존에 해당 토큰을 사용하던(NAIA등) \n 토큰이 초기화됩니다)"),
            guideTile("assets/images/guide_image3.png",
                "3. 복사 아이콘을 눌러 토큰을 복사하고, 앱에 입력합니다"),
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
