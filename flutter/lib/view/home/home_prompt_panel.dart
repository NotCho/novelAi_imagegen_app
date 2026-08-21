import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';
import 'package:naiapp/application/home/director_tool_controller.dart';
import 'package:naiapp/view/home/home_main_prompt.dart';
import 'package:naiapp/view/home/home_char_prompt.dart';
import 'package:naiapp/view/home/home_director_tool.dart';
import 'package:naiapp/view/home/home_setting.dart';
import 'package:naiapp/view/home/home_load_image.dart';

class HomePromptPanel extends StatelessWidget {
  final HomePageController controller;

  const HomePromptPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.promptController.confirmRemoveIndex.value == true) {
          controller.promptController.confirmRemoveIndex.value = false;
        }
      },
      child: Obx(() {
        final isLiquid = controller.liquidGlassMode.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, -10),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: isLiquid
                  ? LiquidGlassLayer(
                      settings: LiquidGlassSettings(
                        thickness: controller.liquidGlassThickness.value,
                        blur: controller.liquidGlassBlur.value,
                        glassColor: const Color(0x22FFFFFF),
                        chromaticAberration:
                            controller.liquidGlassAberration.value,
                        refractiveIndex: controller.liquidGlassRefraction.value,
                        lightIntensity:
                            controller.liquidGlassLightIntensity.value,
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
                                            Colors.white
                                                .withValues(alpha: 0.08),
                                            Colors.white.withValues(alpha: 0.0),
                                            Colors.white.withValues(alpha: 0.1),
                                            Colors.white.withValues(alpha: 0.0),
                                            Colors.white
                                                .withValues(alpha: 0.08),
                                          ],
                                          stops: const [
                                            0.0,
                                            0.22,
                                            0.25,
                                            0.72,
                                            0.75
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildPanelControlBar(),
                                    if (controller.isPanelExpanded.value)
                                      _expandedContent(context),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : BackdropFilter(
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPanelControlBar(),
                            if (controller.isPanelExpanded.value)
                              _expandedContent(context),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPanelControlBar() {
    return Container(
      padding: const EdgeInsets.only(
        left: SkeletonSpacing.spacing,
        right: SkeletonSpacing.spacing,
        top: 4.0,
        bottom: 6.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Color(0x1EFFFFFF),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnlasWarningWidget(
            homeSettingController: controller.homeSettingController,
            directorToolController: controller.directorToolController,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildExpandButton(),
              _anlasRemaining(),
              GenerateButtonWidget(controller: controller),
            ],
          ),
        ],
      ),
    );
  }

  Widget _anlasRemaining() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.generating_tokens_outlined,
            color: SkeletonColorScheme.primaryColor,
            size: 14,
          ),
          const SizedBox(width: 6),
          Obx(() {
            final imageGenerationController =
                controller.imageGenerationController;
            final usage = imageGenerationController.v5Usage.value;
            final refillRate = usage?.refillGenerationsPerMinute ?? 0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (imageGenerationController.anlasLeft.value > 0)
                      ? '${imageGenerationController.anlasLeft.value} Anlas'
                      : 'Anlas..',
                  style: const TextStyle(
                    color: SkeletonColorScheme.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
                if (usage != null && refillRate > 0)
                  Text(
                    '${_formatRefillRate(refillRate)}장/분 '
                    '(${usage.minutesUntilFull}분 후 100%)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SkeletonColorScheme.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 9,
                      height: 1.15,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _formatRefillRate(double rate) {
    final digits = rate >= 10
        ? 0
        : rate >= 1
            ? 1
            : rate >= 0.1
                ? 2
                : 3;
    return rate
        .toStringAsFixed(digits)
        .replaceFirst(RegExp(r'\.0+$'), '')
        .replaceFirst(RegExp(r'(\.\d*?)0+$'), r'$1');
  }

  Widget _buildExpandButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.isPanelExpanded.toggle(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: SkeletonColorScheme.surfaceColor,
              width: 1.2,
            ),
          ),
          child: Obx(
            () => Row(
              children: [
                Icon(
                  controller.isPanelExpanded.value
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  color: SkeletonColorScheme.textSecondaryColor,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  controller.isPanelExpanded.value ? "접기" : "펼치기",
                  style: const TextStyle(
                    color: SkeletonColorScheme.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _expandedContent(BuildContext context) {
    return Expanded(
      child: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(SkeletonSpacing.borderRadius),
                  topRight: Radius.circular(SkeletonSpacing.borderRadius),
                ),
                color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.5),
              ),
              margin: const EdgeInsets.all(SkeletonSpacing.smallSpacing),
              child: TabBar(
                tabAlignment: TabAlignment.center,
                isScrollable: true,
                tabs: [
                  _buildTab(
                      icon: Icons.text_fields,
                      iconColor: SkeletonColorScheme.accentColor,
                      label: '프롬프트'),
                  _buildTab(
                      icon: Icons.person,
                      iconColor: SkeletonColorScheme.negativeColor,
                      label: '캐릭터'),
                  _buildTab(
                      icon: Icons.photo_camera,
                      iconColor: SkeletonColorScheme.newGreenColor,
                      label: '디렉터'),
                  _buildTab(
                      icon: Icons.settings,
                      iconColor: SkeletonColorScheme.primaryColor,
                      label: '설정'),
                  _buildTab(
                      icon: Icons.image,
                      iconColor: SkeletonColorScheme.textSecondaryColor,
                      label: "이미지")
                ],
                indicatorColor: SkeletonColorScheme.primaryColor,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: SkeletonColorScheme.textColor,
                unselectedLabelColor: SkeletonColorScheme.textSecondaryColor,
                dividerColor: Colors.transparent,
              ),
            ),
            Flexible(
              flex: 3,
              child: TabBarView(
                children: [
                  HomeMainPrompt(
                      positivePromptController:
                          controller.promptController.positivePromptController,
                      negativePromptController:
                          controller.promptController.negativePromptController),
                  const HomeCharPrompt(),
                  const HomeDirectorTool(),
                  HomeSetting(),
                  HomeLoadImage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
      {required IconData icon,
      required Color iconColor,
      required String label}) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: SkeletonColorScheme.textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnlasWarningWidget extends StatelessWidget {
  final HomeSettingController homeSettingController;
  final DirectorToolController directorToolController;

  const AnlasWarningWidget({
    super.key,
    required this.homeSettingController,
    required this.directorToolController,
  });

  @override
  Widget build(BuildContext context) {
    if (homeSettingController.xSizeController.text.isEmpty) {
      homeSettingController.xSizeController.text = "832";
    }
    if (homeSettingController.ySizeController.text.isEmpty) {
      homeSettingController.ySizeController.text = "1216";
    }

    return Obx(() {
      int pixels = (double.parse(homeSettingController.xSizeController.text))
              .toInt() *
          (double.parse(homeSettingController.ySizeController.text)).toInt();
      bool tooBig = pixels > 1024 * 1024;
      bool tooManySteps = homeSettingController.samplingSteps > 28;
      bool directorEnabled =
          directorToolController.referenceImage.value != null;

      if (!tooBig && !tooManySteps && !directorEnabled) {
        return const SizedBox.shrink();
      }
      return Container(
          margin: const EdgeInsets.only(top: 4, bottom: 4),
          padding: const EdgeInsets.symmetric(
            horizontal: SkeletonSpacing.smallSpacing,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: SkeletonColorScheme.negativeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
            border: Border.all(
              color: SkeletonColorScheme.negativeColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: SkeletonColorScheme.negativeColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Anlas 차감 주의!",
                    style: TextStyle(
                      color: SkeletonColorScheme.negativeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tooBig) ...[
                        Text(
                          "크기: ${homeSettingController.xSizeController.text}x${homeSettingController.ySizeController.text} ",
                          style: const TextStyle(
                            color: SkeletonColorScheme.negativeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (tooManySteps)
                        Text(
                          "스텝: ${homeSettingController.samplingSteps} ",
                          style: const TextStyle(
                            color: SkeletonColorScheme.negativeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (directorEnabled)
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            "캐릭터 레퍼런스 ON",
                            style: TextStyle(
                              color: SkeletonColorScheme.negativeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ));
    });
  }
}

class GenerateButtonWidget extends StatelessWidget {
  final HomePageController controller;

  const GenerateButtonWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ElevatedButton(
          onPressed: controller.imageGenerationController.isGenerating.value
              ? null
              : controller.imageGenerationController.generateImage,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            backgroundColor:
                controller.imageGenerationController.isGenerating.value
                    ? Colors.grey[850]
                    : SkeletonColorScheme.primaryColor,
            disabledBackgroundColor: Colors.grey[900],
            disabledForegroundColor: Colors.grey[600],
            elevation: 3,
            shadowColor:
                SkeletonColorScheme.primaryColor.withValues(alpha: 0.35),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                controller.imageGenerationController.isGenerating.value
                    ? Icons.hourglass_top_rounded
                    : Icons.auto_awesome_rounded,
                color: SkeletonColorScheme.textColor,
                size: 15,
              ),
              const SizedBox(width: 6),
              !controller.imageGenerationController.isGenerating.value
                  ? const Text(
                      '생성',
                      style: TextStyle(
                        color: SkeletonColorScheme.textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    )
                  : const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: SkeletonColorScheme.textColor,
                        strokeWidth: 2,
                      ),
                    ),
            ],
          ),
        ));
  }
}
