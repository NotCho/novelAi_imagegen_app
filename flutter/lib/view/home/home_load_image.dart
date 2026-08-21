import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/view/core/util/components.dart';
import 'package:naiapp/view/core/util/design_system.dart';

class HomeLoadImage extends StatelessWidget {
  final HomePageController homePageController = Get.find<HomePageController>();

  HomeLoadImage({super.key});

  final HomeImageController homeImageController =
      Get.find<HomeImageController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        child: Column(children: [
          _buildVibeTransferCard(),
          //_buildImagetoImageCard(),
        ]),
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
              if (!homePageController.modelConfigController.supportsVibeTransfer) {
                return const Row(
                  children: [
                    Icon(Icons.block, size: 40, color: Colors.grey),
                    SizedBox(width: SkeletonSpacing.smallSpacing),
                    Text(
                      "Vibe Transfer는 V3 이상 모델에서 사용할 수 있습니다.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                );
              }

              if (homeImageController.vibeParseImageBytes.isEmpty) {
                return const Row(
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
                    .vibeParseImageBytes[index].prevExtractionStrength.value;
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
                          extractionStrength == null
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                label,
                softWrap: false,
                style: const TextStyle(
                  color: SkeletonColorScheme.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: -0.3,
                ),
              ),
              // 수치 값 뱃지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
                  border: Border.all(
                    color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(
                    color: SkeletonColorScheme.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 조작 버튼 (-, +)
              Container(
                height: 26,
                decoration: BoxDecoration(
                  color: SkeletonColorScheme.surfaceColor,
                  borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
                  border: Border.all(
                    color: SkeletonColorScheme.textColor.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 마이너스 버튼
                    GestureDetector(
                      onTap: () {
                        final newValue = (value - 0.05).clamp(0.0, 1.0);
                        onChanged(num.parse(newValue.toStringAsFixed(2)).toDouble());
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.remove,
                          color: SkeletonColorScheme.textSecondaryColor,
                          size: 13,
                        ),
                      ),
                    ),
                    // 중앙 버티컬 구분선
                    Container(
                      width: 0.8,
                      height: 14,
                      color: SkeletonColorScheme.textColor.withValues(alpha: 0.08),
                    ),
                    // 플러스 버튼
                    GestureDetector(
                      onTap: () {
                        final newValue = (value + 0.05).clamp(0.0, 1.0);
                        onChanged(num.parse(newValue.toStringAsFixed(2)).toDouble());
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.add,
                          color: SkeletonColorScheme.textSecondaryColor,
                          size: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: SkeletonColorScheme.primaryColor,
              inactiveTrackColor: SkeletonColorScheme.surfaceColor,
              thumbColor: SkeletonColorScheme.primaryColor,
              overlayColor: SkeletonColorScheme.primaryColor.withValues(alpha: 0.15),
              valueIndicatorColor: SkeletonColorScheme.primaryColor,
              valueIndicatorTextStyle: const TextStyle(color: SkeletonColorScheme.textColor),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 1,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
