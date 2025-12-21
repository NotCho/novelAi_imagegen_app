import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../../application/login/login_page_controller.dart';
import '../core/page.dart';

class LoginPage extends GetView<LoginPageController> {
  const LoginPage({super.key});

  // 홈 페이지와 동일한 디자인 시스템 적용
  static const Color primaryColor = Color(0xFF6C5CE7); // 주요 색상: 보라색 계열
  static const Color accentColor = Color(0xFF00B894); // 액센트 색상: 민트 계열
  static const Color backgroundColor = Color(0xFF121212); // 배경색
  static const Color cardColor = Color(0xFF1E1E1E); // 카드 배경색
  static const Color surfaceColor = Color(0xFF2D2D2D); // 서피스 색상
  static const Color textColor = Color(0xFFF0F0F0); // 기본 텍스트 색상
  static const Color textSecondaryColor = Color(0xFFAAAAAA); // 보조 텍스트 색상

  // 공통 테두리 반경 정의
  static const double borderRadius = 12.0;

  // 공통 간격 정의
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;

  // 애니메이션 지속 시간
  static const Duration animationDuration = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SkeletonPage(
        isLoading: controller.isInitLoading,
        page: (controller.animationController != null)
            ? Stack(
                children: [
                  // 배경색 설정
                  Container(
                    decoration: const BoxDecoration(
                      color: backgroundColor,
                    ),
                  ),
                  SkeletonScaffold(
                    backgroundColor: Colors.transparent,
                    body: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 100,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: primaryColor,
                                    size: 60,
                                  ),
                                ),
                                const SizedBox(height: spacing),
                                const Text(
                                  "NAI APP",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 100),
                            loginField(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
      ),
    );
  }

  Widget loginField() {
    return AutofillGroup(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 디자인
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: smallSpacing, vertical: smallSpacing),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(borderRadius / 2),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login, color: primaryColor, size: 16),
                  SizedBox(width: 8),
                  Text(
                    "로그인",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: spacing),
            // 로그인 방식 선택
            Obx(
              () => Row(
                children: [
                  Container(
                      child: Text("이메일로 로그인",
                          style: TextStyle(color: textSecondaryColor))),
                  const SizedBox(width: smallSpacing),
                  Switch(
                      value: controller.loginMode.value == 1,
                      onChanged: (v) {
                        if (v) {
                          controller.loginMode.value = 1;
                        } else {
                          controller.loginMode.value = 0;
                        }
                      }),
                  const SizedBox(width: smallSpacing),
                  Container(
                      child: Text("토큰으로 로그인",
                          style: TextStyle(color: textSecondaryColor))),
                ],
              ),
            ),
            const SizedBox(height: spacing),

            // 입력 폼
            Obx(() {
              if (controller.loginMode.value == 1) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        controller.showTokenDialog();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: textSecondaryColor),
                            SizedBox(width: smallSpacing),
                            Text(
                              "토큰 발급 방법",
                              style: TextStyle(
                                color: textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: spacing),
                    _buildTextField(
                      controller: controller.persistentTokenController,
                      hintText: "pst-*****....",
                      prefixIcon: Icons.vpn_key_outlined,
                      keyboardType: TextInputType.visiblePassword,
                      onSubmitted: (_) => controller.onLogin(),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  // 이메일 입력 필드
                  _buildTextField(
                    controller: controller.emailController,
                    hintText: "이메일을 입력하세요",
                    prefixIcon: Icons.email_outlined,
                    autofillHints: const [
                      AutofillHints.email,
                      AutofillHints.username
                    ],
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: spacing),
                  // 비밀번호 입력 필드
                  _buildTextField(
                    controller: controller.passwordController,
                    hintText: "비밀번호를 입력하세요",
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => controller.onLogin(),
                  ),
                ],
              );
            }),
            const SizedBox(height: spacing),
            // 비밀번호 찾기 링크
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  controller.onLogin();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (controller.inProgress.value)
                      ? Colors.grey
                      : primaryColor,
                  foregroundColor: textColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.login, size: 18),
                    const SizedBox(width: smallSpacing),
                    Text(
                      (controller.inProgress.value) ? "로그인 중.." : "로그인",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.arrow_forward,
                      color: textColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    IconData? prefixIcon,
    List<String>? autofillHints,
    TextInputType? keyboardType,
    void Function(String)? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: textColor),
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        textInputAction:
            isPassword ? TextInputAction.done : TextInputAction.next,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: textSecondaryColor),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: InputBorder.none,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: primaryColor,
                )
              : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: const Icon(
                    Icons.visibility_outlined,
                    color: textSecondaryColor,
                  ),
                  onPressed: () {
                    // 비밀번호 표시/숨김 기능 구현
                  },
                )
              : null,
        ),
      ),
    );
  }
}
