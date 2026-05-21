import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/director_tool_controller.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/view/core/util/design_system.dart';

class HomeDirectorTool extends GetView<DirectorToolController> {
  const HomeDirectorTool({super.key});

  @override
  Widget build(BuildContext context) {
    final homePageController = Get.find<HomePageController>();
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
            Obx(() {
              if (!homePageController.modelConfigController.supportsCharacterReference) {
                return _buildUnsupportedPlaceholder();
              }
              return controller.referenceImage.value != null
                  ? _buildImagePreview()
                  : _buildImagePlaceholder();
            }),

            Obx(() {
              if (!homePageController.modelConfigController.supportsCharacterReference) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: SkeletonSpacing.spacing),
                  Row(
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
                  ),
                  const SizedBox(height: SkeletonSpacing.spacing),
                  const Text(
                    'Fidelity',
                    style: TextStyle(
                      color: SkeletonColorScheme.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
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
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: controller.pickReferenceImage,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: SkeletonColorScheme.cardColor,
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
          border: Border.all(
            color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.08),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius - 2),
                child: Image.memory(
                  controller.referenceImage.value!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // 이미지 변경 오버레이 가이드
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cached_rounded,
                      color: SkeletonColorScheme.primaryColor,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '이미지 변경',
                      style: TextStyle(
                        color: SkeletonColorScheme.textColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildImagePlaceholder() {
    return GestureDetector(
      onTap: controller.pickReferenceImage,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: SkeletonColorScheme.cardColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
          border: Border.all(
            color: SkeletonColorScheme.textSecondaryColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: SkeletonColorScheme.primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '터치하여 캐릭터 레퍼런스 이미지 등록',
              style: TextStyle(
                color: SkeletonColorScheme.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '상단 [사진 추가] 버튼을 통해서도 등록할 수 있습니다.',
              style: TextStyle(
                color: SkeletonColorScheme.textSecondaryColor.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnsupportedPlaceholder() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: SkeletonColorScheme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        border: Border.all(
          color: SkeletonColorScheme.negativeColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Character Reference 기능은 V4.5 이상 모델에서만 지원됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SkeletonColorScheme.textSecondaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
