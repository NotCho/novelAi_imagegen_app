import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/image_generation_controller.dart';
import '../../application/home/image_cache_manager.dart';

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
    return Obx(() => AnimatedContainer(
      height: controller.expandHistory.value ? 170 : 0,
      decoration: BoxDecoration(
        color: SkeletonColorScheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      duration: SkeletonSpacing.animationDuration,
      child: SingleChildScrollView(
        child: Column(
          children: [
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
                        width: 100,
                        height: 30,
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
    ));
  }
}
