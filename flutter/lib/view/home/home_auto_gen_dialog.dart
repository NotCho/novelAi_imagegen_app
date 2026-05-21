import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:naiapp/application/home/auto_generation_controller.dart';

class HomeAutoGenDialog extends StatelessWidget {
  final AutoGenerationController autoGenerationController;

  const HomeAutoGenDialog({super.key, required this.autoGenerationController});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SkeletonColorScheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
      ),
      title: const Row(
        children: [
          Icon(Icons.timer, color: SkeletonColorScheme.accentColor, size: 20),
          SizedBox(width: 8),
          Text(
            '자동 생성 설정',
            style: TextStyle(
                color: SkeletonColorScheme.textColor,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: SkeletonColorScheme.cardColor,
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Column(
                    children: [
                      Text(
                        '${autoGenerationController.autoGenerateSeconds.value.round()}초 마다 자동 생성',
                        style: const TextStyle(
                          color: SkeletonColorScheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: SkeletonSpacing.smallSpacing),
                      Slider(
                        value: autoGenerationController.autoGenerateSeconds.value,
                        min: 0,
                        max: 30,
                        divisions: 31,
                        label: '${autoGenerationController.autoGenerateSeconds.value.round()}초',
                        activeColor: SkeletonColorScheme.accentColor,
                        inactiveColor: SkeletonColorScheme.surfaceColor,
                        thumbColor: SkeletonColorScheme.primaryColor,
                        onChanged: (value) => autoGenerationController.setAutoGenerateSeconds(value),
                      ),
                    ],
                  )),
              const SizedBox(height: SkeletonSpacing.spacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildValueAdjustButton(
                      icon: const Icon(Icons.remove,
                          color: SkeletonColorScheme.textColor, size: 18),
                      onPressed: () {
                        if (autoGenerationController.autoGenerateSeconds.value > 0) {
                          autoGenerationController.autoGenerateSeconds.value--;
                        }
                      }),
                  const SizedBox(width: SkeletonSpacing.smallSpacing),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(
                        horizontal: SkeletonSpacing.smallSpacing, vertical: 4),
                    decoration: BoxDecoration(
                      color: SkeletonColorScheme.accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
                      border: Border.all(
                        color: SkeletonColorScheme.accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Obx(
                      () => Text(
                        "${autoGenerationController.autoGenerateSeconds.value.round()}초",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: SkeletonColorScheme.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: SkeletonSpacing.smallSpacing),
                  _buildValueAdjustButton(
                      icon: const Icon(Icons.add,
                          color: SkeletonColorScheme.textColor, size: 18),
                      onPressed: () {
                        if (autoGenerationController.autoGenerateSeconds.value < 30) {
                          autoGenerationController.autoGenerateSeconds.value++;
                        }
                      }),
                ],
              ),
              const SizedBox(height: SkeletonSpacing.spacing),
              Obx(
                () => Column(
                  children: [
                    const SizedBox(height: SkeletonSpacing.spacing),
                    Text(
                      '${autoGenerationController.getRandomDelayCalculation()}의 랜덤 딜레이',
                      style: const TextStyle(
                        color: SkeletonColorScheme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: SkeletonSpacing.smallSpacing),
                    Slider(
                      value: autoGenerationController.autoGenerateRandomDelay.value.toDouble(),
                      min: 0.0,
                      max: 0.5,
                      divisions: 20,
                      label: '${(autoGenerationController.autoGenerateRandomDelay.value * 100).toStringAsFixed(2)}%',
                      activeColor: SkeletonColorScheme.accentColor,
                      inactiveColor: SkeletonColorScheme.surfaceColor,
                      thumbColor: SkeletonColorScheme.primaryColor,
                      onChanged: (value) => autoGenerationController.setAutoGenerateRandomDelay(value),
                    ),
                    const SizedBox(height: SkeletonSpacing.spacing),
                    const Text("0을 입력하면 무제한",
                        style: TextStyle(
                          color: SkeletonColorScheme.textSecondaryColor,
                        )),
                    const SizedBox(height: SkeletonSpacing.smallSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: autoGenerationController.autoGenerateCountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(
                                color: SkeletonColorScheme.textSecondaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    SkeletonSpacing.borderRadius / 2),
                                borderSide: BorderSide(
                                  color: SkeletonColorScheme.primaryColor
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              color: SkeletonColorScheme.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: SkeletonSpacing.spacing),
                        const Text(
                          '회 자동 생성',
                          style: TextStyle(
                            color: SkeletonColorScheme.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            autoGenerationController.maxAutoGenerateCount.value =
                int.tryParse(autoGenerationController.autoGenerateCountController.text) ?? 0;
            autoGenerationController.currentAutoGenerateCount.value = 0;
          },
          style: TextButton.styleFrom(
            foregroundColor: SkeletonColorScheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: SkeletonSpacing.spacing,
                vertical: SkeletonSpacing.smallSpacing),
          ),
          child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildValueAdjustButton({required Widget icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
        child: Container(
          padding: const EdgeInsets.all(SkeletonSpacing.smallSpacing),
          decoration: BoxDecoration(
            color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
            border: Border.all(
              color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: icon,
        ),
      ),
    );
  }
}
