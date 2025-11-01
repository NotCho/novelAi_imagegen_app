import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:naiapp/application/home/director_tool_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';
import 'package:naiapp/view/core/page.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:naiapp/view/home/home_appBar.dart';
import 'package:naiapp/view/home/home_char_prompt.dart';
import 'package:naiapp/view/home/home_director_tool.dart';
import 'package:naiapp/view/home/home_imageView.dart';
import 'package:naiapp/view/home/home_main_prompt.dart';
import 'package:naiapp/view/home/home_setting.dart';
import '../../application/home/home_page_controller.dart';
import 'home_load_image.dart';

class HomePage extends GetView<HomePageController> {
  HomePage({super.key});

  final HomeImageController homeImageController =
      Get.find<HomeImageController>();
  final HomeSettingController homeSettingController =
      Get.find<HomeSettingController>();

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
                  floatingActionButton: _buildAutoGenerationButton(),
                  appBar: SkeletonAppBar(
                    isLeftTitle: true,
                    titleText: "AI 이미지 생성기",
                    isLeftIconDisplayed: false,
                    customAction: Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(
                              SkeletonSpacing.smallSpacing),
                          child: HomeAppBar()),
                    ),
                  ),
                  resizeToAvoidBottomInset: true,
                  bodyPadding: EdgeInsets.zero,
                  withNavBar: true,
                  navBar: SafeArea(
                    child: AnimatedNavBarWidget(
                      controller: controller,
                      child: promptPanel(context),
                    ),
                  ),
                  backgroundColor: SkeletonColorScheme.backgroundColor,
                  body: Column(
                    children: [
                      Obx(() => history()),
                      Expanded(child: HomeImageView()),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom > 0
                  ? MediaQuery.of(context).viewInsets.bottom
                  : 0,
              child: const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget history() {
    return AnimatedContainer(
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
                          value: controller.autoSave.value,
                          onChanged: (v) {
                            controller.setAutoSave(v);
                          }),
                      const SizedBox(width: SkeletonSpacing.smallSpacing),
                      Text((controller.autoSave.value) ? "자동저장 ON" : "자동저장 OFF",
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
              constraints: BoxConstraints(
                maxHeight: 110,
              ),
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: homeImageController.generationHistory.length,
                  itemBuilder: (context, index) {
                    // 인덱스 역순으로 변경 (최신 항목이 먼저 표시되도록)
                    final reversedIndex =
                        homeImageController.generationHistory.length -
                            1 -
                            index;

                    final historyItem =
                        homeImageController.generationHistory[reversedIndex];
                    return GestureDetector(
                      onTap: () {
                        if (index < 29) {
                          print("인덱스로 이동: $index");
                          homeImageController.imageViewPageController
                              .animateToPage(index,
                                  duration: SkeletonSpacing.animationDuration,
                                  curve: Curves.easeIn);
                          return; // 30개 초과시 클릭 무시
                        }
                        print("끝으로 이동: $index");
                        print(reversedIndex);
                        homeImageController.currentImageBytes.value =
                            base64Decode(historyItem.imagePath);

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
                            base64Decode(historyItem.imagePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget promptPanel(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.confirmRemoveIndex.value == true) {
          controller.confirmRemoveIndex.value = false;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: SkeletonColorScheme.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildPanelControlBar(),

            // 확장된 패널 콘텐츠
            _expandedContent(context),
          ],
        ),
      ),
    );
  }

  // 패널 상단 컨트롤 바 위젯
  Widget _buildPanelControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SkeletonSpacing.spacing,
          vertical: SkeletonSpacing.smallSpacing),
      decoration: BoxDecoration(
        color: SkeletonColorScheme.backgroundColor,
        border: const Border(
          bottom: BorderSide(
            color: SkeletonColorScheme.surfaceColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAnlasPanel(),
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

  Widget _buildAnlasPanel() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnlasWarningWidget(
            homeSettingController: controller.homeSettingController,
            directorToolController: controller.directorToolController,
          ),
        ],
      ),
    );
  }

  Widget _anlasRemaining() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(
          horizontal: SkeletonSpacing.spacing,
          vertical: SkeletonSpacing.smallSpacing),
      // decoration: BoxDecoration(
      //   color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
      //   borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
      //   border: Border.all(
      //     color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.3),
      //     width: 1,
      //   ),
      // ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: SkeletonColorScheme.primaryColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Obx(
            () => Text(
              (controller.anlasLeft.value > 0)
                  ? "Anlas: ${controller.anlasLeft.value}"
                  : "Anlas: Loading..",
              style: const TextStyle(
                color: SkeletonColorScheme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 패널 확장 버튼
  Widget _buildExpandButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.isPanelExpanded.toggle(),
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SkeletonSpacing.spacing,
              vertical: SkeletonSpacing.smallSpacing),
          decoration: BoxDecoration(
            color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
            border: Border.all(
              color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                controller.isPanelExpanded.value
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
                color: SkeletonColorScheme.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                controller.isPanelExpanded.value ? "접기" : "펼치기",
                style: const TextStyle(
                  color: SkeletonColorScheme.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
            // 탭 바 디자인 개선
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
                tabAlignment:  TabAlignment.center,
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

            // 탭 컨텐츠
            Flexible(
              flex: 3,
              child: TabBarView(
                children: [
                  HomeMainPrompt(
                      positivePromptController:
                          controller.positivePromptController,
                      negativePromptController:
                          controller.negativePromptController),
                  HomeCharPrompt(),
                  HomeDirectorTool(),
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

  // 탭 위젯 빌더
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

  Widget _buildAutoGenerationButton() {
    return AutoGenerateWarningWidget(controller: controller);
  }
}

class AnlasWarningWidget extends StatelessWidget {
  final HomeSettingController homeSettingController;
  final DirectorToolController directorToolController;

  AnlasWarningWidget({
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

      // 경고사항이 없으면 빈 컨테이너 반환
      if (!tooBig && !tooManySteps && !directorEnabled) {
        return const SizedBox.shrink();
      }
      return Container(
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
              Icon(
                Icons.warning_amber_rounded,
                color: SkeletonColorScheme.negativeColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                          style: TextStyle(
                            color: SkeletonColorScheme.negativeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (tooManySteps)
                        Text(
                          "스텝: ${homeSettingController.samplingSteps} ",
                          style: TextStyle(
                            color: SkeletonColorScheme.negativeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (directorEnabled)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
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

class AutoGenerateWarningWidget extends StatelessWidget {
  final HomePageController controller;

  AutoGenerateWarningWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedContainer(
          width: controller.floatingButtonExpanded.value ? Get.width * 0.8 : 50,
          duration: SkeletonSpacing.animationDuration,
          child: SizedBox(
              height: 50,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 4, horizontal: SkeletonSpacing.smallSpacing),
                decoration: BoxDecoration(
                  color: SkeletonColorScheme.surfaceColor,
                  borderRadius:
                      BorderRadius.circular(SkeletonSpacing.borderRadius),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            controller.floatingButtonExpanded.value =
                                !controller.floatingButtonExpanded.value;
                          },
                          icon: (controller.floatingButtonExpanded.value
                              ? const Icon(Icons.arrow_forward_ios,
                                  color: SkeletonColorScheme.textSecondaryColor)
                              : const Icon(Icons.arrow_back_ios,
                                  color:
                                      SkeletonColorScheme.textSecondaryColor))),
                      Row(
                        children: [
                          SizedBox(
                            width: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(() => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // 스위치 디자인 개선
                                        SizedBox(
                                          height: 25,
                                          child: Switch(
                                            value: controller
                                                .autoGenerationController
                                                .autoGenerateEnabled
                                                .value,
                                            onChanged: (value) => controller
                                                .autoGenerationController
                                                .toggleAutoGenerate(),
                                            activeColor:
                                                SkeletonColorScheme.accentColor,
                                            activeTrackColor:
                                                SkeletonColorScheme.accentColor
                                                    .withValues(alpha: 0.3),
                                            inactiveThumbColor:
                                                SkeletonColorScheme
                                                    .textSecondaryColor,
                                            inactiveTrackColor:
                                                SkeletonColorScheme
                                                    .surfaceColor,
                                          ),
                                        ),
                                      ],
                                    )),
                                const SizedBox(
                                    width: SkeletonSpacing.smallSpacing),
                                // 설정 버튼 디자인 개선
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: Get.context!,
                                        builder: (context) =>
                                            _autoGenerationDialog(),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(
                                        SkeletonSpacing.borderRadius / 2),
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                          SkeletonSpacing.smallSpacing),
                                      decoration: BoxDecoration(
                                        color: SkeletonColorScheme.surfaceColor
                                            .withValues(alpha: 0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.settings,
                                        color: SkeletonColorScheme.textColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    width: SkeletonSpacing.smallSpacing),
                                Obx(() {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        width: 30,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        decoration: BoxDecoration(
                                          color: controller
                                                  .autoGenerationController
                                                  .autoGenerateEnabled
                                                  .value
                                              ? SkeletonColorScheme.accentColor
                                                  .withValues(alpha: 0.2)
                                              : SkeletonColorScheme.surfaceColor
                                                  .withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(
                                              SkeletonSpacing.borderRadius / 2),
                                        ),
                                        child: Text(
                                          (controller.autoGenerationController
                                                  .autoGenerateEnabled.value)
                                              ? '${controller.autoGenerationController.remainingSeconds.value.round()}초'
                                              : '${controller.autoGenerationController.autoGenerateSeconds.value.round()}초',
                                          style: TextStyle(
                                            color: (controller
                                                    .autoGenerationController
                                                    .autoGenerateEnabled
                                                    .value)
                                                ? SkeletonColorScheme
                                                    .accentColor
                                                : SkeletonColorScheme.textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(width: SkeletonSpacing.smallSpacing),
                          if (controller.autoGenerationController
                                  .maxAutoGenerateCount.value !=
                              0)
                            Text(
                              '횟수 제한\n${controller.autoGenerationController.currentAutoGenerateCount}/${controller.autoGenerationController.maxAutoGenerateCount}회',
                              style: TextStyle(
                                color: SkeletonColorScheme.textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ))),
    );
  }

  final List<int> autoAddButtons = [-100, -10, -1, 1, 10, 100];

  Widget _autoGenerationDialog() {
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
                        '${controller.autoGenerationController.autoGenerateSeconds.value.round()}초 마다 자동 생성',
                        style: const TextStyle(
                          color: SkeletonColorScheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: SkeletonSpacing.smallSpacing),
                      Slider(
                        value: controller
                            .autoGenerationController.autoGenerateSeconds.value,
                        min: 0,
                        max: 30,
                        divisions: 31,
                        label:
                            '${controller.autoGenerationController.autoGenerateSeconds.value.round()}초',
                        activeColor: SkeletonColorScheme.accentColor,
                        inactiveColor: SkeletonColorScheme.surfaceColor,
                        thumbColor: SkeletonColorScheme.primaryColor,
                        onChanged: (value) => controller
                            .autoGenerationController
                            .setAutoGenerateSeconds(value),
                      ),
                    ],
                  )),
              const SizedBox(height: SkeletonSpacing.spacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 조절 버튼 디자인 개선
                  _buildValueAdjustButton(
                      icon: Icon(Icons.remove,
                          color: SkeletonColorScheme.textColor, size: 18),
                      onPressed: () {
                        if (controller.autoGenerationController
                                .autoGenerateSeconds.value >
                            0) {
                          controller.autoGenerationController
                              .autoGenerateSeconds.value--;
                        }
                      }),
                  const SizedBox(width: SkeletonSpacing.smallSpacing),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(
                        horizontal: SkeletonSpacing.smallSpacing, vertical: 4),
                    decoration: BoxDecoration(
                      color: SkeletonColorScheme.accentColor
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                          SkeletonSpacing.borderRadius / 2),
                      border: Border.all(
                        color: SkeletonColorScheme.accentColor
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Obx(
                      () => Text(
                        "${controller.autoGenerationController.autoGenerateSeconds.value.round()}초",
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
                      icon: Icon(Icons.add,
                          color: SkeletonColorScheme.textColor, size: 18),
                      onPressed: () {
                        if (controller.autoGenerationController
                                .autoGenerateSeconds.value <
                            30) {
                          controller.autoGenerationController
                              .autoGenerateSeconds.value++;
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
                      '${controller.autoGenerationController.getRandomDelayCalculation()}의 랜덤 딜레이',
                      style: const TextStyle(
                        color: SkeletonColorScheme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: SkeletonSpacing.smallSpacing),
                    Slider(
                      value: controller.autoGenerationController
                          .autoGenerateRandomDelay.value
                          .toDouble(),
                      min: 0.0,
                      max: 0.5,
                      divisions: 20,
                      label:
                          '${(controller.autoGenerationController.autoGenerateRandomDelay.value * 100).toStringAsFixed(2)}%',
                      activeColor: SkeletonColorScheme.accentColor,
                      inactiveColor: SkeletonColorScheme.surfaceColor,
                      thumbColor: SkeletonColorScheme.primaryColor,
                      onChanged: (value) => controller.autoGenerationController
                          .setAutoGenerateRandomDelay(value),
                    ),
                    const SizedBox(height: SkeletonSpacing.spacing),
                    Text("0을 입력하면 무제한",
                        style: const TextStyle(
                          color: SkeletonColorScheme.textSecondaryColor,
                        )),
                    const SizedBox(height: SkeletonSpacing.smallSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: controller.autoGenerationController
                                .autoGenerateCountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
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
            controller.autoGenerationController.maxAutoGenerateCount.value =
                int.tryParse(controller.autoGenerationController
                        .autoGenerateCountController.text) ??
                    0;
            controller.autoGenerationController.currentAutoGenerateCount.value =
                0;
          },
          style: TextButton.styleFrom(
            foregroundColor: SkeletonColorScheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: SkeletonSpacing.spacing,
                vertical: SkeletonSpacing.smallSpacing),
          ),
          child:
              const Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildValueAdjustButton(
      {required Widget icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
        child: Container(
          padding: const EdgeInsets.all(SkeletonSpacing.smallSpacing),
          decoration: BoxDecoration(
            color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.2),
            borderRadius:
                BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
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

class GenerateButtonWidget extends StatelessWidget {
  final HomePageController controller;

  const GenerateButtonWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ElevatedButton(
          onPressed:
              controller.isGenerating.value ? null : controller.generateImage,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            backgroundColor: controller.isGenerating.value
                ? Colors.grey[700]
                : SkeletonColorScheme.primaryColor,
            disabledBackgroundColor: Colors.grey[800],
            disabledForegroundColor: Colors.grey[500],
            elevation: 4,
          ),
          child: SizedBox(
            width: 50,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  controller.isGenerating.value
                      ? Icons.hourglass_top
                      : Icons.auto_awesome,
                  color: SkeletonColorScheme.textColor,
                  size: 16,
                ),
                const SizedBox(width: SkeletonSpacing.smallSpacing),
                !controller.isGenerating.value
                    ? const Text(
                        '생성',
                        style: TextStyle(
                          color: SkeletonColorScheme.textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      )
                    : const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: SkeletonColorScheme.textColor,
                          strokeWidth: 2,
                        ),
                      ),
              ],
            ),
          ),
        ));
  }
}
