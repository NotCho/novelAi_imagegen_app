import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
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
      child: SkeletonPage(
        isLoading: false,
        page: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SkeletonScaffold(
                  floatingActionButton: AutoGenerateWarningWidget(controller: controller),
                  appBar: const SkeletonAppBar(
                    isLeftTitle: true,
                    titleText: "AI 이미지 생성기",
                    isLeftIconDisplayed: false,
                    customAction: Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(SkeletonSpacing.smallSpacing),
                          child: HomeAppBar()),
                    ),
                  ),
                  resizeToAvoidBottomInset: false,
                  bodyPadding: EdgeInsets.zero,
                  withNavBar: true,
                  navBar: SafeArea(
                    child: AnimatedNavBarWidget(
                      controller: controller,
                      child: HomePromptPanel(controller: controller),
                    ),
                  ),
                  backgroundColor: SkeletonColorScheme.backgroundColor,
                  body: Column(
                    children: [
                      HomeHistoryPanel(
                        controller: controller,
                        homeImageController: homeImageController,
                        imageGenerationController: controller.imageGenerationController,
                      ),
                      const Expanded(child: HomeImageView()),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
      child: Obx(() => AnimatedContainer(
            duration: SkeletonSpacing.animationDuration,
            curve: Curves.easeInOut,
            height: controller.isPanelExpanded.value
                ? Get.height * 0.465 + 28
                : 105,
            child: child,
          )),
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
        width: isExpanded ? Get.width * 0.88 : 50,
        height: 50,
        decoration: BoxDecoration(
          color: isExpanded
              ? SkeletonColorScheme.cardColor.withValues(alpha: 0.95)
              : SkeletonColorScheme.primaryColor.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(25),
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
    return Row(
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }
}
