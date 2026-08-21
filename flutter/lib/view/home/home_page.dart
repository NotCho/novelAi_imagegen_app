import 'dart:ui';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:naiapp/view/core/page.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:naiapp/view/home/home_appBar.dart';
import 'package:naiapp/view/home/home_imageView.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/view/home/home_history_panel.dart';
import 'package:naiapp/view/home/home_prompt_panel.dart';
import 'package:naiapp/view/home/home_auto_gen_dialog.dart';

class HomePage extends GetView<HomePageController> {
  HomePage({super.key});

  late final HomeImageController homeImageController = Get.find<HomeImageController>();

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: Scaffold(
        backgroundColor: SkeletonColorScheme.backgroundColor,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              // 0. Sleek Dark Abstract Background (provides contrast/texture for blurs & shaders)
              const Positioned.fill(
                child: SleekDarkAbstractBackground(),
              ),

              // 1. Background Edge-to-Edge Gallery
              const Positioned.fill(
                child: HomeImageView(),
              ),

              // 2. Floating History Panel (if expanded)
              Positioned(
                top: 96,
                left: 16,
                right: 16,
                child: SafeArea(
                  bottom: false,
                  child: HomeHistoryPanel(
                    controller: controller,
                    homeImageController: homeImageController,
                    imageGenerationController: controller.imageGenerationController,
                  ),
                ),
              ),

              // 3. Floating Glass AppBar
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: SafeArea(
                  bottom: false,
                  child: Obx(() {
                    final isLiquid = controller.liquidGlassMode.value;
                    return Container(
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
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.24),
                            width: 0.8,
                          ),
                        ),
                        child: isLiquid
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
                                        color: Colors.white.withValues(alpha: 0.07),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.11),
                                            Colors.white.withValues(alpha: 0.03),
                                            Colors.white.withValues(alpha: 0.07),
                                            Colors.white.withValues(alpha: 0.02),
                                          ],
                                          stops: const [0.0, 0.35, 0.65, 1.0],
                                        ),
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
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                            child: HomeAppBar(),
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
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      child: HomeAppBar(),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    );
                  }),
                ),
              ),

              // 4. Floating Prompt Bottom Bar
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: SafeArea(
                  top: false,
                  child: AnimatedNavBarWidget(
                    controller: controller,
                    child: HomePromptPanel(controller: controller),
                  ),
                ),
              ),

              // 5. Auto Generate Warning Widget
              Obx(() => AnimatedPositioned(
                duration: SkeletonSpacing.animationDuration,
                curve: Curves.easeInOut,
                bottom: controller.isPanelExpanded.value
                    ? (Get.height * 0.465 + 28 + 16 + 16)
                    : 145,
                right: 16,
                child: AutoGenerateWarningWidget(controller: controller),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
class AnimatedNavBarWidget extends StatelessWidget {
  final HomePageController controller;
  final Widget child;

  const AnimatedNavBarWidget({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedSize(
        duration: SkeletonSpacing.animationDuration,
        curve: Curves.easeInOut,
        alignment: Alignment.bottomCenter,
        child: Obx(() => Container(
              height: controller.isPanelExpanded.value
                  ? Get.height * 0.465 + 28
                  : null,
              child: child,
            )),
      ),
    );
  }
}

class AutoGenerateWarningWidget extends StatelessWidget {
  final HomePageController controller;

  const AutoGenerateWarningWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.floatingButtonExpanded.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: isExpanded ? Get.width * 0.88 : 54,
        height: 54,
        decoration: BoxDecoration(
          color: isExpanded
              ? SkeletonColorScheme.cardColor.withValues(alpha: 0.95)
              : SkeletonColorScheme.primaryColor.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(27),
          border: Border.all(
            color: isExpanded
                ? SkeletonColorScheme.primaryColor.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            if (isExpanded)
              BoxShadow(
                color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.15),
                blurRadius: 6,
                spreadRadius: 1,
              ),
          ],
        ),
        child: isExpanded
            ? _buildExpandedContent()
            : _buildCollapsedContent(),
      );
    });
  }

  Widget _buildCollapsedContent() {
    return GestureDetector(
      onTap: () {
        controller.floatingButtonExpanded.value = true;
      },
      behavior: HitTestBehavior.opaque,
      child: const Center(
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
        IconButton(
          onPressed: () {
            controller.floatingButtonExpanded.value = false;
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: SkeletonColorScheme.textSecondaryColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() => SizedBox(
                      height: 25,
                      child: Switch(
                        value: controller.autoGenerationController.autoGenerateEnabled.value,
                        onChanged: (value) => controller.autoGenerationController.toggleAutoGenerate(),
                        activeThumbColor: SkeletonColorScheme.accentColor,
                        activeTrackColor: SkeletonColorScheme.accentColor.withValues(alpha: 0.3),
                        inactiveThumbColor: SkeletonColorScheme.textSecondaryColor,
                        inactiveTrackColor: SkeletonColorScheme.surfaceColor,
                      ),
                    )),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: Get.context!,
                        builder: (context) => HomeAutoGenDialog(
                          autoGenerationController: controller.autoGenerationController,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: SkeletonColorScheme.textColor,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final isEnabled = controller.autoGenerationController.autoGenerateEnabled.value;
                  final timeText = isEnabled
                      ? '${controller.autoGenerationController.remainingSeconds.value.round()}초'
                      : '${controller.autoGenerationController.autoGenerateSeconds.value.round()}초';
                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? SkeletonColorScheme.accentColor.withValues(alpha: 0.15)
                          : SkeletonColorScheme.surfaceColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isEnabled
                            ? SkeletonColorScheme.accentColor.withValues(alpha: 0.25)
                            : Colors.transparent,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      timeText,
                      style: TextStyle(
                        color: isEnabled
                            ? SkeletonColorScheme.accentColor
                            : SkeletonColorScheme.textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        height: 1.1,
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Obx(() {
                  if (controller.autoGenerationController.maxAutoGenerateCount.value == 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '제한: ${controller.autoGenerationController.currentAutoGenerateCount}/${controller.autoGenerationController.maxAutoGenerateCount}회',
                    style: const TextStyle(
                      color: SkeletonColorScheme.textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 18,
                  color: SkeletonColorScheme.textSecondaryColor.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 8),
                Obx(() => Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          controller.setHideSeed(!controller.hideSeed.value);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: controller.hideSeed.value
                                ? SkeletonColorScheme.negativeColor.withValues(alpha: 0.12)
                                : SkeletonColorScheme.primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: controller.hideSeed.value
                                  ? SkeletonColorScheme.negativeColor.withValues(alpha: 0.25)
                                  : SkeletonColorScheme.primaryColor.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                controller.hideSeed.value
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: controller.hideSeed.value
                                    ? SkeletonColorScheme.negativeColor
                                    : SkeletonColorScheme.primaryColor,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                controller.hideSeed.value ? '시드 숨김' : '시드 표시',
                                style: TextStyle(
                                  color: controller.hideSeed.value
                                      ? SkeletonColorScheme.negativeColor
                                      : SkeletonColorScheme.primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    ),
    );
  }
}

class SleekDarkAbstractBackground extends StatelessWidget {
  const SleekDarkAbstractBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F11),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF16161A),
            Color(0xFF0C0C0E),
            Color(0xFF121215),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: Get.height * 0.4,
            left: Get.width * 0.3,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: CustomPaint(
                painter: AbstractLinesPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AbstractLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width; i += 60) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
