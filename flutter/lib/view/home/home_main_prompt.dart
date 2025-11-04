import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/view/core/util/components.dart';
import '../core/util/design_system.dart';

class HomeMainPrompt extends StatelessWidget {
  final TextEditingController positivePromptController;
  final TextEditingController negativePromptController;

  const HomeMainPrompt(
      {super.key,
      required this.positivePromptController,
      required this.negativePromptController});

  @override
  Widget build(BuildContext context) {
    return mainPrompt();
  }

  Widget mainPrompt() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 메인 프롬프트 입력 필드 디자인 개선
          _buildPromptField(
            controller: positivePromptController,
            hintText: 'masterpiece, high quality, 1girl, ...',
            icon: Icons.add_circle_outline,
            color: SkeletonColorScheme.accentColor,
            title: "긍정적 프롬프트 입력",
          ),

          // 네거티브 프롬프트 입력 필드 디자인 개선
          _buildPromptField(
            controller: negativePromptController,
            hintText: 'low quality, bad anatomy, worst quality, ...',
            icon: Icons.remove_circle_outline,
            color: SkeletonColorScheme.negativeColor,
            title: "부정적 프롬프트 입력",
          ),
        ],
      ),
    );
  }

  // 프롬프트 입력 필드 빌더
  Widget _buildPromptField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return GestureDetector(
      onTap: () {
        Get.dialog(
          PromptDialog(textController: controller, title: title, color: color),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: SkeletonSpacing.smallSpacing,
            horizontal: SkeletonSpacing.smallSpacing),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(SkeletonSpacing.borderRadius - 1),
                  topRight: Radius.circular(SkeletonSpacing.borderRadius - 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.edit, color: color, size: 16),
                ],
              ),
            ),

            // 입력 필드
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                enabled: false,
                controller: controller,
                style: const TextStyle(color: SkeletonColorScheme.textColor),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                      color: SkeletonColorScheme.textSecondaryColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
