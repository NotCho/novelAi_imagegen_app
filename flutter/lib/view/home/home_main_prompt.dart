import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/view/core/util/components.dart';
import '../core/util/design_system.dart';
import '../core/util/wildcard_highlight_controller.dart';

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
          color: SkeletonColorScheme.cardColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀 헤더 (투명 배경에 세련된 요소 배치)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: SkeletonColorScheme.surfaceColor,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 미니멀한 네온 도트 인디케이터
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, color: color.withValues(alpha: 0.85), size: 15),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: SkeletonColorScheme.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.edit,
                    color: SkeletonColorScheme.textSecondaryColor,
                    size: 14,
                  ),
                ],
              ),
            ),

            // 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: WildcardTextField(
                enabled: false,
                controller: controller,
                highlightColor: color,
                style: const TextStyle(
                  color: SkeletonColorScheme.textColor,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: SkeletonColorScheme.textSecondaryColor,
                    fontSize: 13,
                  ),
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
