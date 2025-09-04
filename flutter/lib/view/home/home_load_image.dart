import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/view/core/util/components.dart';
import 'package:naiapp/view/core/util/design_system.dart';

class HomeLoadImage extends StatelessWidget {
  HomeLoadImage({super.key});

  final HomeImageController homeImageController =
      Get.find<HomeImageController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        child: Column(
            children: [_buildVibeTransferCard(), _buildImagetoImageCard()]),
      ),
    );
  }

  Widget _buildVibeTransferCard() {
    return SettingsCard(
        title: "Vibe Transfer",
        icon: Icons.image_search_outlined,
        child: Column(
          children: [
            Obx(() {
              if (homeImageController.vibeParseImageBytes.isEmpty) {
                return Row(
                  children: [
                    Icon(Icons.image_search_outlined,
                        size: 40, color: Colors.grey),
                    SizedBox(width: SkeletonSpacing.smallSpacing),
                    Text(
                      "아직 Vibe Transfer 이미지가 없습니다.\n우측 상단에서 이미지를 불러와 보세요.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                );
              }

              return Column(
                  children: List.generate(
                      homeImageController.vibeParseImageBytes.length, (index) {
                double? prevExtractionStrength = homeImageController
                    .vibeParseImageBytes[index].prevExtractionStrength?.value;
                double? extractionStrength = homeImageController
                    .vibeParseImageBytes[index].extractionStrength?.value;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: SkeletonSpacing.smallSpacing),
                          (prevExtractionStrength == null ||
                                  extractionStrength == null)
                              ? Container(
                                  padding: const EdgeInsets.all(
                                      SkeletonSpacing.smallSpacing),
                                  decoration: BoxDecoration(
                                    color: SkeletonColorScheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                        SkeletonSpacing.borderRadius),
                                    border: Border.all(
                                      color: SkeletonColorScheme.primaryColor
                                          .withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  height: 100,
                                  width: 100,
                                  child: Icon(
                                    Icons.auto_awesome_outlined,
                                    size: 50,
                                    color: Colors.grey.withValues(alpha: 0.6),
                                  ))
                              : Container(
                                  padding: const EdgeInsets.all(
                                      SkeletonSpacing.smallSpacing),
                                  decoration: BoxDecoration(
                                    color: SkeletonColorScheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                        SkeletonSpacing.borderRadius),
                                    border: Border.all(
                                      color: (prevExtractionStrength ==
                                              extractionStrength)
                                          ? SkeletonColorScheme.primaryColor
                                              .withValues(alpha: 0.3)
                                          : SkeletonColorScheme.negativeColor
                                              .withValues(alpha: 0.6),
                                      width: 2,
                                    ),
                                  ),
                                  height: 100,
                                  width: 100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        SkeletonSpacing.borderRadius),
                                    child: Image.memory(
                                      homeImageController
                                              .vibeParseImageBytes[index]
                                              .image ??
                                          Uint8List(0),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      Expanded(
                        child: VibeSliders(
                          homeImageController: homeImageController,
                          index: index,
                        ),
                      ),
                      const SizedBox(width: SkeletonSpacing.smallSpacing),
                      Column(
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            SkeletonSpacing.borderRadius))),
                                backgroundColor: WidgetStateProperty.all(
                                    Colors.red.withValues(alpha: 0.3))),
                            child: const SizedBox(
                                height: 60,
                                child: Icon(Icons.delete, color: Colors.red)),
                            onPressed: () {
                              homeImageController.onRemoveVibeImage(index);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }));
            }),
          ],
        ));
  }

  Widget _buildImagetoImageCard() {
    return SettingsCard(
        title: "Image to Image",
        icon: Icons.imagesearch_roller_outlined,
        child: Container(
            child: Row(
          children: [
            Icon(Icons.close, size: 20, color: Colors.grey),
            Text(
              "개발 예정 기능입니다.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        )));
  }
}

class VibeSliders extends StatelessWidget {
  final HomeImageController homeImageController;
  final int index;

  const VibeSliders(
      {super.key, required this.homeImageController, required this.index});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildSlider(
            "가중치",
            homeImageController.vibeParseImageBytes[index].weight.value,
            (value) {
              homeImageController.vibeWeightSliderChanged(index, value);
            },
          ),
          if (homeImageController.vibeParseImageBytes[index].image != null &&
              homeImageController
                      .vibeParseImageBytes[index].extractionStrength !=
                  null)
            _buildSlider(
              "추출강도",
              homeImageController
                  .vibeParseImageBytes[index].extractionStrength!.value,
              (value) {
                homeImageController.vibeStrengthSliderChanged(index, value);
              },
            )
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("$label: $value",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ),
          Slider(
            padding: const EdgeInsets.symmetric(
              horizontal: SkeletonSpacing.smallSpacing,
            ),
            min: 0,
            max: 1,
            divisions: 100,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
