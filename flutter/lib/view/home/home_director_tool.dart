import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/director_tool_controller.dart';
import 'package:naiapp/view/core/util/design_system.dart';

class HomeDirectorTool extends GetView<DirectorToolController> {
  const HomeDirectorTool({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SkeletonSpacing.spacing),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: SkeletonColorScheme.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Character Reference Image',
                  style: TextStyle(
                    color: SkeletonColorScheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Obx(() => controller.referenceImage.value != null
                    ? IconButton(
                        icon: const Icon(Icons.delete),
                        color: SkeletonColorScheme.negativeColor,
                        onPressed: controller.removeImage,
                      )
                    : const SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a reference image for a character.',
              style: TextStyle(
                color: SkeletonColorScheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: SkeletonSpacing.spacing),

            // 이미지 영역
            Obx(() => controller.referenceImage.value != null
                ? _buildImagePreview()
                : _buildImagePlaceholder()),

            const SizedBox(height: SkeletonSpacing.spacing),

            // Style Aware 체크박스
            Obx(() => Row(
                  children: [
                    Checkbox(
                      value: controller.styleAware.value,
                      onChanged: (_) => controller.toggleStyleAware(),
                      activeColor: SkeletonColorScheme.primaryColor,
                    ),
                    const Text(
                      'Style Aware',
                      style: TextStyle(
                        color: SkeletonColorScheme.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )),

            const SizedBox(height: SkeletonSpacing.spacing),

            // Fidelity 슬라이더
            const Text(
              'Fidelity',
              style: TextStyle(
                color: SkeletonColorScheme.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Column(
                  children: [
                    Slider(
                      value: controller.fidelity.value,
                      min: 0.0,
                      max: 1.0,
                      divisions: 100,
                      label: controller.fidelity.value.toStringAsFixed(2),
                      activeColor: SkeletonColorScheme.primaryColor,
                      inactiveColor: SkeletonColorScheme.surfaceColor,
                      onChanged: controller.setFidelity,
                    ),
                    Text(
                      controller.fidelity.value.toStringAsFixed(2),
                      style: const TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: SkeletonColorScheme.cardColor,
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        border: Border.all(
          color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        child: Image.memory(
          controller.referenceImage.value!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        border: Border.all(
          color: SkeletonColorScheme.textSecondaryColor.withValues(alpha: 0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload,
            color:
                SkeletonColorScheme.textSecondaryColor.withValues(alpha: 0.6),
            size: 64,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              '상단의 이미지 불러오기 버튼을 사용해\n레퍼런스 이미지를 등록한 뒤\n다이얼로그에서 [레퍼런스] 버튼을 눌러주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SkeletonColorScheme.textSecondaryColor
                    .withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
