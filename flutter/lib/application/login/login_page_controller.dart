import 'package:flutter/cupertino.dart';
import 'package:naiapp/domain/gen/i_novelAI_repository.dart';
import '../core/skeleton_controller.dart';
import 'package:get/get.dart';

class LoginPageController extends SkeletonController
    with GetSingleTickerProviderStateMixin {
  AnimationController? animationController;

  RxBool inProgress = false.obs;
  RxDouble alpha = 1.0.obs;
  RxBool readyToShowMap = false.obs;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
    if (emailController.text.isEmpty) {
      Get.showSnackbar(
        const GetSnackBar(
          message: "이메일을 입력해주세요.",
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (passwordController.text.isEmpty) {
      Get.showSnackbar(
        const GetSnackBar(
          message: "비밀번호를 입력해주세요.",
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    inProgress.value = true;
    INovelAIRepository userRepository = Get.find<INovelAIRepository>();
    final result = await userRepository.fetchAccessKey(
        emailController.text, passwordController.text);

    result.fold((l) {
      Get.showSnackbar(
        GetSnackBar(
          message: l,
          duration: const Duration(seconds: 2),
        ),
      );
    }, (r) {
      getToken();
    });
    inProgress.value = false;
  }

  Future<void> getToken() async {
    INovelAIRepository userRepository = Get.find<INovelAIRepository>();
    final result = await userRepository.createPersistentToken();

    result.fold((l) {
      Get.showSnackbar(
        GetSnackBar(
          message: l,
          duration: const Duration(seconds: 2),
        ),
      );
    }, (r) {
      Get.offAllNamed("/home");
    });
  }
}
