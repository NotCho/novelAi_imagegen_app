import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/image_generation_controller.dart';
import '../../application/home/image_cache_manager.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class HomeHistoryPanel extends StatelessWidget {
  final HomePageController controller;
  final HomeImageController homeImageController;
  final ImageGenerationController imageGenerationController;

  const HomeHistoryPanel({
    super.key,
    required this.controller,
    required this.homeImageController,
    required this.imageGenerationController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLiquid = controller.liquidGlassMode.value;
      return AnimatedContainer(
        height: controller.expandHistory.value ? 170 : 0,
        duration: SkeletonSpacing.animationDuration,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: isLiquid
                ? null
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
          ),
          child: (isLiquid && controller.expandHistory.value)
              ? LiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: controller.liquidGlassThickness.value,
                    blur: controller.liquidGlassBlur.value,
                    glassColor: const Color(0x22FFFFFF),
                    chromaticAberration: controller.liquidGlassAberration.value,
                    refractiveIndex: controller.liquidGlassRefraction.value,
                    lightIntensity: controller.liquidGlassLightIntensity.value,
                    saturation: controller.liquidGlassSaturation.value,
                  ),
                  child: LiquidGlass(
                    shape: const LiquidRoundedRectangle(borderRadius: 22.5),
                    child: CustomPaint(
                      foregroundPainter: GradientBorderPainter(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.18),
                            Colors.white.withValues(alpha: 0.35),
                            Colors.white.withValues(alpha: 0.18),
                            Colors.white.withValues(alpha: 0.45),
                          ],
                          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                        ),
                        strokeWidth: 1.0,
                        borderRadius: BorderRadius.circular(22.5),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: const Alignment(-1.5, -1.0),
                                      end: const Alignment(1.5, 1.0),
                                      colors: [
                                        Colors.white.withValues(alpha: 0.08),
                                        Colors.white.withValues(alpha: 0.0),
                                        Colors.white.withValues(alpha: 0.1),
                                        Colors.white.withValues(alpha: 0.0),
                                        Colors.white.withValues(alpha: 0.08),
                                      ],
                                      stops: const [0.0, 0.22, 0.25, 0.72, 0.75],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox.shrink(),
                          SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                const SizedBox(height: 6.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Switch(
                                              value: imageGenerationController.autoSave.value,
                                              onChanged: (v) {
                                                imageGenerationController.setAutoSave(v);
                                              }),
                                          const SizedBox(width: SkeletonSpacing.smallSpacing),
                                          Text((imageGenerationController.autoSave.value) ? "자동저장 ON" : "자동저장 OFF",
                                              style: const TextStyle(
                                                color: SkeletonColorScheme.textColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              )),
                                        ],
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.grid_view_sharp),
                                        color: SkeletonColorScheme.textSecondaryColor,
                                        onPressed: () {
                                          controller.onGridTap();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  color: SkeletonColorScheme.surfaceColor,
                                  thickness: 1,
                                  height: 1,
                                ),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 110,
                                  ),
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: homeImageController.generationHistory.length,
                                      itemBuilder: (context, index) {
                                        final reversedIndex =
                                            homeImageController.generationHistory.length - 1 - index;

                                        final historyItem =
                                            homeImageController.generationHistory[reversedIndex];
                                        return GestureDetector(
                                          onTap: () {
                                            if (index < 29) {
                                              homeImageController.imageViewPageController
                                                  .animateToPage(index,
                                                      duration: SkeletonSpacing.animationDuration,
                                                      curve: Curves.easeIn);
                                              return;
                                            }
                                            homeImageController.currentImageBytes.value =
                                                ImageCacheManager.instance.getImageBytes(historyItem.imagePath);

                                            homeImageController.imageViewPageController
                                                .animateToPage(30,
                                                    duration: SkeletonSpacing.animationDuration,
                                                    curve: Curves.easeIn);
                                          },
                                          child: Container(
                                            margin:
                                                const EdgeInsets.all(SkeletonSpacing.smallSpacing),
                                            width: 94,
                                            height: 94,
                                            decoration: BoxDecoration(
                                              color: SkeletonColorScheme.cardColor,
                                              borderRadius: BorderRadius.circular(
                                                  SkeletonSpacing.borderRadius),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(
                                                  SkeletonSpacing.borderRadius),
                                              child: Image.memory(
                                                ImageCacheManager.instance.getImageBytes(historyItem.imagePath),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                cacheWidth: 100,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 30,
                      sigmaY: 30,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 6.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Switch(
                                          value: imageGenerationController.autoSave.value,
                                          onChanged: (v) {
                                            imageGenerationController.setAutoSave(v);
                                          }),
                                      const SizedBox(width: SkeletonSpacing.smallSpacing),
                                      Text((imageGenerationController.autoSave.value) ? "자동저장 ON" : "자동저장 OFF",
                                          style: const TextStyle(
                                            color: SkeletonColorScheme.textColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          )),
                                    ],
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.grid_view_sharp),
                                    color: SkeletonColorScheme.textSecondaryColor,
                                    onPressed: () {
                                      controller.onGridTap();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: SkeletonColorScheme.surfaceColor,
                              thickness: 1,
                              height: 1,
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 110,
                              ),
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: homeImageController.generationHistory.length,
                                  itemBuilder: (context, index) {
                                    final reversedIndex =
                                        homeImageController.generationHistory.length - 1 - index;

                                    final historyItem =
                                        homeImageController.generationHistory[reversedIndex];
                                    return GestureDetector(
                                      onTap: () {
                                        if (index < 29) {
                                          homeImageController.imageViewPageController
                                              .animateToPage(index,
                                                  duration: SkeletonSpacing.animationDuration,
                                                  curve: Curves.easeIn);
                                          return;
                                        }
                                        homeImageController.currentImageBytes.value =
                                            ImageCacheManager.instance.getImageBytes(historyItem.imagePath);

                                        homeImageController.imageViewPageController
                                            .animateToPage(30,
                                                duration: SkeletonSpacing.animationDuration,
                                                curve: Curves.easeIn);
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.all(SkeletonSpacing.smallSpacing),
                                        width: 94,
                                        height: 94,
                                        decoration: BoxDecoration(
                                          color: SkeletonColorScheme.cardColor,
                                          borderRadius: BorderRadius.circular(
                                              SkeletonSpacing.borderRadius),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              SkeletonSpacing.borderRadius),
                                          child: Image.memory(
                                            ImageCacheManager.instance.getImageBytes(historyItem.imagePath),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            cacheWidth: 100,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      );
    });
}
}
