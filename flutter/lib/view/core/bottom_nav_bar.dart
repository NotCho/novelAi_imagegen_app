
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:naiapp/view/core/util/design_system.dart';

import '../../application/core/bottom_nav_bar.dart';

class SkeletonBottomNavigationBar extends GetView<BottomNavBarController> {
  const SkeletonBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      child: Obx(
        () => SafeArea(
          child: SizedBox(
            height: 56.h,
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: SkeletonColorScheme.newG100,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: controller.currentIndex,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 0,
              unselectedFontSize: 0,
              onTap: (s) => {controller.currentIndex = s},
              items: const [
                BottomNavigationBarItem(
                  icon: Column(
                    children: [
                      // const SkeletonPictureAsset(
                      //     type: SkeletonPictureAssetType.diagnosisEmpty),
                      SizedBox(height: 2),
                      Text(
                        '홈',
                      ),
                    ],
                  ),
                  activeIcon: Column(
                    children: [
                      // const SkeletonPictureAsset(
                      //     type: SkeletonPictureAssetType.diagnosisFill),
                      SizedBox(height: 2),
                      // 수정수정황수정
                      Text(
                        '홈',
                      ),
                    ],
                  ),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
