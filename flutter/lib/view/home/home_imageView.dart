import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../../application/home/home_image_controller.dart';
import '../core/util/design_system.dart';

class HomeImageView extends GetView<HomeImageController> {
  final int historyMax = 30; // 최대 히스토리 개수
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: SkeletonColorScheme.cardColor,
      child: Obx(() {
        if (controller.generatedImageBytes.value.isEmpty) {
          // 이미지가 없을 때 플레이스홀더 디자인 개선
          return _buildEmptyImagePlaceholder();
        }
        // 이미지 표시 부분에 그림자 효과와 애니메이션 추가
        return Stack(
          children: [
            PageView.builder(
              onPageChanged: controller.onPageChanged,
              controller: controller.imageViewPageController,
              itemCount:
                  math.min(historyMax + 1, controller.generationHistory.length),

              // 히스토리 최대 30개 + currentImage 1개
              itemBuilder: (context, index) {
                final reversedIndex =
                    controller.generationHistory.length - index - 1;
                // 마지막 페이지 = currentImageBytes
                if (index == historyMax) {
                  return Container(
                    padding: const EdgeInsets.all(SkeletonSpacing.spacing),
                    decoration: BoxDecoration(
                      color: SkeletonColorScheme.primaryColor
                          .withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(SkeletonSpacing.borderRadius),
                      border: Border.all(
                        color: SkeletonColorScheme.primaryColor
                            .withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(SkeletonSpacing.borderRadius),
                      child: Obx(
                        () => Image.memory(
                          controller.currentImageBytes.value,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                }

                // 0~29번 페이지 = generationHistory[0]부터 순서대로
                else {
                  if (index < controller.generationHistory.length) {
                    return Container(
                      padding: const EdgeInsets.all(SkeletonSpacing.spacing),
                      decoration: BoxDecoration(
                        color: SkeletonColorScheme.surfaceColor
                            .withValues(alpha: 0.3),
                      ),
                      child: Image.memory(
                        base64Decode(controller
                            .generationHistory[reversedIndex].imagePath),
                        fit: BoxFit.contain,
                      ),
                    );
                  }

                  // 히스토리가 없으면 빈 컨테이너
                  else {
                    return Container(
                      padding: const EdgeInsets.all(SkeletonSpacing.spacing),
                      child: Center(
                        child: Text(
                          '더 이상 이미지가 없습니다',
                          style: TextStyle(
                            color: SkeletonColorScheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            Obx(
              () => Positioned(
                  child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        controller.imageViewPageController.animateToPage(0,
                            duration: SkeletonSpacing.animationDuration,
                            curve: Curves.easeIn);
                      },
                      icon: Icon(
                        Icons.keyboard_double_arrow_left,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 32,
                      )),
                  Text(
                    '${(controller.currentImageViewIndex.value < historyMax) ? controller.currentImageViewIndex.value + 1 : "$historyMax+"} / ${(controller.generationHistory.length > historyMax) ? "$historyMax+" : controller.generationHistory.length}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                  )
                ],
              )),
            ),
          ],
        );
      }),
    );
  }

  // 빈 이미지 플레이스홀더 위젯
  Widget _buildEmptyImagePlaceholder() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: SkeletonSpacing.spacing * 5),
          Container(
            padding: const EdgeInsets.all(SkeletonSpacing.spacing),
            decoration: BoxDecoration(
              color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_outlined,
              color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.6),
              size: 64,
            ),
          ),
          SizedBox(height: SkeletonSpacing.spacing),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SkeletonSpacing.spacing,
                vertical: SkeletonSpacing.smallSpacing),
            decoration: BoxDecoration(
              color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
            ),
            child: const Text(
              '이미지를 생성하세요',
              style: TextStyle(
                color: SkeletonColorScheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: SkeletonSpacing.spacing),
          const Text(
            '아래 패널에서 프롬프트를 입력하고 생성 버튼을 눌러보세요',
            style: TextStyle(
              color: SkeletonColorScheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
