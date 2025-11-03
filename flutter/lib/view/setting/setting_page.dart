import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:naiapp/view/core/page.dart';
import 'package:naiapp/view/core/util/design_system.dart';

import '../../application/setting/setting_page_controller.dart';

class SettingPage extends GetView<SettingPageController> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonScaffold(
      appBar: SkeletonAppBar(
        backgroundColor: SkeletonColorScheme.backgroundColor,
        titleText: "설정",
      ),
      backgroundColor: SkeletonColorScheme.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildListTile(
              onTap: controller.togglePngMode,
              title: '저장타입',
              icon: Icons.save,
              trailing: Obx(() => AnimatedContainer(
                    duration: SkeletonSpacing.animationDuration,
                    child: Text(
                        "${(controller.pngMode.value) ? "PNG" : "WEBP"}로 저장 중",
                        style: SkeletonTextTheme.body2Long
                            .copyWith(color: SkeletonColorScheme.newG600)),
                  ))),
          _buildListTile(
              title: "앱 정보",
              icon: Icons.info,
              onTap: () {
                // controller.showAppInfo();
              },
              trailing: Text(
                controller.global.currentClientVersion.value,
                style: SkeletonTextTheme.body2Long
                    .copyWith(color: SkeletonColorScheme.newG600),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              color: SkeletonColorScheme.textSecondaryColor,
            ),
          ),
          _buildListTile(
              title: '로그아웃',
              icon: Icons.logout,
              onTap: () {
                logoutDialog();
              }),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title, style: SkeletonTextTheme.body2Long),
      leading: Icon(icon, color: SkeletonColorScheme.textColor),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void logoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: SkeletonColorScheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        title: const Text(
          '로그아웃 하시겠습니까?',
          style: TextStyle(
              color: SkeletonColorScheme.textColor,
              fontWeight: FontWeight.normal,
              fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              controller.logout();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
