import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';

import '../../application/home/home_page_controller.dart';
import '../core/util/components.dart';
import '../core/util/design_system.dart';

class HomeSetting extends GetView<HomePageController> {
  HomeSetting({super.key});

  final HomeSettingController homeSettingController =
      Get.find<HomeSettingController>();

  @override
  Widget build(BuildContext context) {
    return settings();
  }

  Widget settings() {
    final sliderConfigs = [
      SliderConfig(
        label: '스텝 수',
        value: homeSettingController.samplingSteps,
        min: 1,
        max: 51,
        divisions: 50,
        step: 1,
        formatter: (value) => value.toInt().toString(),
        isWarning: (value) => value > 28,
      ),
      SliderConfig(
        label: '프롬프트 가이던스',
        value: homeSettingController.promptGuidance,
        min: 0,
        max: 10,
        divisions: 100,
        step: 0.1,
        formatter: (value) => value.toStringAsFixed(2),
      ),
      SliderConfig(
        label: 'CFG Scale',
        value: homeSettingController.cfgReScale,
        min: 0,
        max: 1,
        divisions: 100,
        step: 0.01,
        formatter: (value) => value.toStringAsFixed(2),
      ),
    ];
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 설정 타이틀
          Obx(
            () => SettingsCard(
              title:
                  '최근 프리셋: ${(controller.homeSettingController.selectedPreset.value.isNotEmpty) ? controller.homeSettingController.selectedPreset.value : "없음"}',
              icon: Icons.save,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프리셋 버튼들 표시
                  Obx(() => Wrap(
                        spacing: SkeletonSpacing.smallSpacing,
                        runSpacing: SkeletonSpacing.smallSpacing,
                        children: [
                          // 저장된 프리셋 버튼들
                          for (final presetName in controller
                              .homeSettingController.presetMap.keys)
                            GestureDetector(
                              onLongPress: () {
                                // 프리셋 삭제 다이얼로그 표시
                                Get.closeAllSnackbars();

                                Get.dialog(
                                  AlertDialog(
                                    backgroundColor:
                                        SkeletonColorScheme.cardColor,
                                    title: const Text('프리셋 삭제',
                                        style: TextStyle(
                                            color:
                                                SkeletonColorScheme.textColor)),
                                    content: RichText(
                                      text: TextSpan(
                                        text: presetName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: SkeletonColorScheme.textColor,
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: ' 프리셋을 삭제할까요?',
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                              color: SkeletonColorScheme
                                                  .textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          controller.homeSettingController
                                              .deletePreset(presetName);
                                        },
                                        child: const Text('삭제'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onTap: () {
                                Get.closeAllSnackbars();
                                Get.dialog(
                                  AlertDialog(
                                    backgroundColor:
                                        SkeletonColorScheme.cardColor,
                                    title: const Text('프리셋 로드',
                                        style: TextStyle(
                                            color:
                                                SkeletonColorScheme.textColor)),
                                    content: RichText(
                                      text: TextSpan(
                                        text: presetName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: SkeletonColorScheme.textColor,
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: ' 프리셋을 불러올까요?',
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                              color: SkeletonColorScheme
                                                  .textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          controller.loadPreset(presetName);
                                        },
                                        child: const Text('불러오기'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: (controller.homeSettingController
                                              .selectedPreset.value ==
                                          presetName)
                                      ? SkeletonColorScheme.primaryColor
                                          .withValues(alpha: 0.5)
                                      : SkeletonColorScheme.primaryColor
                                          .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                      SkeletonSpacing.borderRadius / 2),
                                  border: Border.all(
                                    color: SkeletonColorScheme.primaryColor
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(presetName,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: SkeletonColorScheme.textColor)),
                              ),
                            ),

                          // 새 프리셋 추가 버튼
                          GestureDetector(
                            onTap: () {
                              Get.closeAllSnackbars();

                              // 텍스트 컨트롤러 생성
                              final TextEditingController nameController =
                                  TextEditingController();

                              // 새 프리셋 이름을 입력받는 다이얼로그 표시
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('새 프리셋 이름'),
                                  content: TextField(
                                    controller: nameController,
                                    // 여기서 직접 컨트롤러 사용
                                    decoration: const InputDecoration(
                                      hintText: '프리셋 이름을 입력하세요',
                                    ),
                                    autofocus: true,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final name = nameController.text.trim();
                                        if (name.isNotEmpty) {
                                          controller.savePreset(name);
                                        }
                                      },
                                      child: const Text('저장'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: SkeletonColorScheme.primaryColor
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(
                                      SkeletonSpacing.borderRadius / 2),
                                ),
                                child: const Icon(
                                  size: 16,
                                  Icons.add,
                                  color: SkeletonColorScheme.textColor,
                                )),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
          InkWell(
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Text(
                "와일드카드 설정",
                style: SkeletonTextTheme.listTitle,
              ),
            ),
            onTap: () {
              controller.router.toWildcard();
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Row(
              children: [
                Icon(Icons.tune,
                    color: SkeletonColorScheme.primaryColor, size: 18),
                SizedBox(width: 8),
                Text(
                  '이미지 생성 설정',
                  style: TextStyle(
                    color: SkeletonColorScheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SkeletonSpacing.smallSpacing),

          // 설정 카드들
          Obx(
            () => SettingsCard(
              title: '샘플러 설정',
              icon: Icons.blur_circular,
              child: DropDownBuild(
                value: homeSettingController.selectedSampler.value,
                labelText: '샘플러',
                items: homeSettingController.samplers.keys.toList(),
                onChanged: (value) {
                  if (value != null) {
                    homeSettingController.selectedSampler.value = value;
                  }
                },
              ),
            ),
          ),

          SettingsCard(
            title: '크기 설정',
            icon: Icons.aspect_ratio,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // 해상도 설정 (기본 + 커스텀 통합)
              _buildResolutionSection(),

              const SizedBox(height: SkeletonSpacing.spacing),

              // 순차 변경 설정
              _buildAutoChangeSizeSection(),
            ]),
          ),

          SettingsCard(
            title: '품질 설정',
            icon: Icons.auto_awesome_mosaic,
            child: Column(
              children: sliderConfigs
                  .map((config) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OptimizedSlider(config: config),
                      ))
                  .toList(),
            ),
          ),

          SettingsCard(
            title: '시드 설정',
            icon: Icons.casino,
            child: Row(
              children: [
                Obx(
                  () => Expanded(
                    child: TextField(
                      enabled:
                          !controller.homeSettingController.randomSeed.value,
                      keyboardType: TextInputType.number,
                      style:
                          const TextStyle(color: SkeletonColorScheme.textColor),
                      decoration: InputDecoration(
                        labelText: '시드 값',
                        labelStyle: const TextStyle(
                            color: SkeletonColorScheme.textSecondaryColor),
                        filled: true,
                        fillColor: SkeletonColorScheme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              SkeletonSpacing.borderRadius / 2),
                          borderSide: const BorderSide(
                              color: SkeletonColorScheme.surfaceColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        suffixIcon: IconButton(
                          onPressed: () {
                            controller
                                .homeSettingController.seedController.text = "";
                          },
                          icon: const Icon(Icons.refresh,
                              color: SkeletonColorScheme.primaryColor),
                        ),
                      ),
                      controller:
                          controller.homeSettingController.seedController,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: SkeletonColorScheme.primaryColor
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                          SkeletonSpacing.borderRadius / 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '랜덤',
                          style: TextStyle(
                            color: SkeletonColorScheme.textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Switch(
                          value:
                              controller.homeSettingController.randomSeed.value,
                          onChanged: (value) {
                            controller.homeSettingController.randomSeed.value =
                                value;
                            controller
                                .homeSettingController.seedController.text = '';
                          },
                          activeThumbColor: SkeletonColorScheme.primaryColor,
                          activeTrackColor: SkeletonColorScheme.primaryColor
                              .withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SettingsCard(
              title: "노이즈 스케줄러",
              icon: Icons.blur_circular,
              child: DropDownBuild(
                value: controller.selectedNoiseSchedule.value,
                labelText: '노이즈 스케줄러',
                items: controller.noiseScheduleOptions.toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedNoiseSchedule.value = value;
                  }
                },
              ))
        ],
      ),
    );
  }

  Widget customResolution(
      String labelText, TextEditingController textController) {
    final bool isWidth = labelText == "가로";

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Get.width / 4,
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        style: const TextStyle(color: SkeletonColorScheme.textColor),
        controller: textController,
        // 포커스가 벗어날 때 검증 및 자동 조정
        onEditingComplete: () {
          controller.homeSettingController
              .validateAndUpdateResolution(textController.text, isWidth);
          FocusScope.of(Get.context!).unfocus(); // 키보드 닫기
        },

        // 포커스가 벗어날 때도 검증
        onTapOutside: (event) {
          // controller.validateAndUpdateResolution(textController.text, isWidth);
          FocusScope.of(Get.context!).unfocus();
        },

        decoration: InputDecoration(
          labelText: '$labelText (64의 배수)',
          labelStyle: const TextStyle(
            color: SkeletonColorScheme.textSecondaryColor,
            fontSize: 12,
          ),
          hintText: isWidth ? '832' : '1216',
          hintStyle: const TextStyle(
            color: SkeletonColorScheme.textSecondaryColor,
            fontSize: 12,
          ),
          filled: true,
          fillColor: SkeletonColorScheme.cardColor,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
            borderSide:
                const BorderSide(color: SkeletonColorScheme.surfaceColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
            borderSide: BorderSide(
              color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
            borderSide: const BorderSide(
              color: SkeletonColorScheme.primaryColor,
              width: 2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),

        // 입력 필터 추가 (숫자만 입력 가능)
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4), // 최대 4자리
        ],
      ),
    );
  }

  Widget popUpSize() {
    return PopupMenuButton(
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
        color: SkeletonColorScheme.cardColor,
        itemBuilder: (context) {
          return controller.homeSettingController.sizeOptions.entries
              .map((entry) => PopupMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      '${entry.value[0]} x ${entry.value[1]}',
                      style:
                          const TextStyle(color: SkeletonColorScheme.textColor),
                    ),
                  ))
              .toList();
        },
        onSelected: (value) {
          if (controller.homeSettingController.sizeOptions.containsKey(value)) {
            final size = controller.homeSettingController.sizeOptions[value]!;
            controller.homeSettingController.xSizeController.text =
                size[0].toString();
            controller.homeSettingController.ySizeController.text =
                size[1].toString();
          }
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: SkeletonColorScheme.cardColor,
            borderRadius:
                BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  '기본 해상도',
                  style: TextStyle(
                      color: SkeletonColorScheme.textColor, fontSize: 14),
                ),
              ),
              Icon(Icons.arrow_drop_down,
                  color: SkeletonColorScheme.textSecondaryColor),
            ],
          ),
        ));
  }

  Widget _buildResolutionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 기본 해상도 선택 버튼
        SizedBox(
          width: double.infinity,
          child: popUpSize(),
        ),

        const SizedBox(height: SkeletonSpacing.spacing),

        // 커스텀 해상도 입력 필드들
        Row(
          children: [
            Expanded(
              child: customResolution(
                  "가로", controller.homeSettingController.xSizeController),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GestureDetector(
                onTap: () {
                  // 가로세로 값 교환 로직
                  final temp =
                      controller.homeSettingController.xSizeController.text;
                  controller.homeSettingController.xSizeController.text =
                      controller.homeSettingController.ySizeController.text;
                  controller.homeSettingController.ySizeController.text = temp;
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        SkeletonColorScheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SkeletonColorScheme.primaryColor
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.swap_horiz,
                    color: SkeletonColorScheme.primaryColor,
                    size: 18,
                  ),
                ),
              ),
            ),
            Expanded(
              child: customResolution(
                  "세로", controller.homeSettingController.ySizeController),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAutoChangeSizeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SkeletonColorScheme.cardColor,
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
        border: Border.all(
          color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Obx(() => Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: controller.homeSettingController.autoChangeSize.value
                      ? (controller.autoGenerationController.autoGenerateEnabled
                              .value)
                          ? SkeletonColorScheme.accentColor
                              .withValues(alpha: 0.2)
                          : SkeletonColorScheme.negativeColor
                              .withValues(alpha: 0.2)
                      : SkeletonColorScheme.surfaceColor.withValues(alpha: 0.5),
                  borderRadius:
                      BorderRadius.circular(SkeletonSpacing.borderRadius / 3),
                ),
                child: Icon(
                  Icons.recycling,
                  color: controller.homeSettingController.autoChangeSize.value
                      ? (controller.autoGenerationController.autoGenerateEnabled
                              .value)
                          ? SkeletonColorScheme.accentColor
                          : SkeletonColorScheme.negativeColor
                      : SkeletonColorScheme.textSecondaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '순차 크기 변경',
                      style: TextStyle(
                        color: SkeletonColorScheme.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (controller.autoGenerationController.autoGenerateEnabled
                              .value)
                          ? '매번 다른 크기로 자동 생성'
                          : "자동 생성시에 활성 가능",
                      style: const TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value:
                        controller.homeSettingController.autoChangeSize.value,
                    onChanged: (value) {
                      controller.homeSettingController.autoChangeSize.value =
                          value;
                    },
                    activeThumbColor: (controller
                            .autoGenerationController.autoGenerateEnabled.value)
                        ? SkeletonColorScheme.accentColor
                        : SkeletonColorScheme.negativeColor,
                    activeTrackColor: (controller
                            .autoGenerationController.autoGenerateEnabled.value)
                        ? SkeletonColorScheme.accentColor.withValues(alpha: 0.3)
                        : SkeletonColorScheme.negativeColor
                            .withValues(alpha: 0.5),
                    inactiveThumbColor: SkeletonColorScheme.textSecondaryColor,
                    inactiveTrackColor: SkeletonColorScheme.surfaceColor,
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.dialog(autoSizeChangeDialog());
                      },
                      borderRadius: BorderRadius.circular(
                          SkeletonSpacing.borderRadius / 2),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: SkeletonColorScheme.surfaceColor
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                              SkeletonSpacing.borderRadius / 2),
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: SkeletonColorScheme.textSecondaryColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget autoSizeChangeDialog() {
    // AnimatedList 컨트롤러
    final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

    return AlertDialog(
      backgroundColor: SkeletonColorScheme.cardColor,
      title: const Text('순차 크기 변경 설정',
          style: TextStyle(color: SkeletonColorScheme.textColor)),
      content: SizedBox(
        width: Get.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '자동 생성 선택시 아래 설정에 따라\n매번 다른 크기로 이미지를 생성합니다.',
              style: TextStyle(color: SkeletonColorScheme.textColor),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedList(
                key: listKey,
                initialItemCount: controller
                    .homeSettingController.sizeOptionsWithCustom.length,
                itemBuilder: (context, index, animation) {
                  return _buildAnimatedListItem(
                      context, index, animation, listKey);
                },
              ),
            ),
            const SizedBox(height: 16),
            // 현재 크기 추가 버튼
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller:
                      controller.homeSettingController.autoSizeXController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: SkeletonColorScheme.textColor),
                  decoration: InputDecoration(
                    labelText: '가로',
                    labelStyle: const TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 12),
                    hintText: '832',
                    hintStyle: const TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 12),
                    filled: true,
                    fillColor: SkeletonColorScheme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          SkeletonSpacing.borderRadius / 2),
                      borderSide: const BorderSide(
                          color: SkeletonColorScheme.surfaceColor),
                    ),
                  ),
                )),
                const SizedBox(width: 8),
                Expanded(
                    child: TextField(
                  controller:
                      controller.homeSettingController.autoSizeYController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: SkeletonColorScheme.textColor),
                  decoration: InputDecoration(
                    labelText: '세로',
                    labelStyle: const TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 12),
                    hintText: '1216',
                    hintStyle: const TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 12),
                    filled: true,
                    fillColor: SkeletonColorScheme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          SkeletonSpacing.borderRadius / 2),
                      borderSide: const BorderSide(
                          color: SkeletonColorScheme.surfaceColor),
                    ),
                  ),
                )),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    bool result =
                        controller.homeSettingController.addSizeOption();
                    if (result) {
                      listKey.currentState?.insertItem(controller
                              .homeSettingController
                              .sizeOptionsWithCustom
                              .length -
                          1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        SkeletonColorScheme.primaryColor.withValues(alpha: 0.2),
                    foregroundColor: SkeletonColorScheme.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          SkeletonSpacing.borderRadius / 2),
                    ),
                  ),
                  child: const SizedBox(
                      height: 56, child: Icon(Icons.add, size: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('닫기'),
        ),
      ],
    );
  }

// AnimatedList 아이템 빌더
  Widget _buildAnimatedListItem(BuildContext context, int index,
      Animation<double> animation, GlobalKey<AnimatedListState> listKey) {
    // 인덱스 체크 (안전성)
    if (index >=
        controller.homeSettingController.sizeOptionsWithCustom.length) {
      return const SizedBox.shrink();
    }

    Size size = controller.homeSettingController.sizeOptionsWithCustom[index];

    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(0.0, 1.0), // 아래에서 올라옴
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
            borderRadius:
                BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
            border: Border.all(
              color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: SkeletonColorScheme.primaryColor
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                          SkeletonSpacing.borderRadius / 3),
                    ),
                    child: const Icon(
                      Icons.photo_size_select_large,
                      color: SkeletonColorScheme.primaryColor,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${size.width.toInt()} x ${size.height.toInt()}',
                    style: const TextStyle(
                      color: SkeletonColorScheme.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // 삭제 애니메이션과 함께 아이템 제거
                    Size removedSize = controller
                        .homeSettingController.sizeOptionsWithCustom[index];

                    listKey.currentState?.removeItem(
                      index,
                      (context, animation) => SizeTransition(
                        sizeFactor: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset.zero,
                            end: const Offset(0.0, -1.0),
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: FadeTransition(
                            opacity: animation,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    SkeletonSpacing.borderRadius / 2),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                              SkeletonSpacing.borderRadius / 3),
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${removedSize.width.toInt()} x ${removedSize.height.toInt()}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.close,
                                      color: Colors.red, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      duration: const Duration(milliseconds: 350),
                    );
                    // 컨트롤러에서 실제 데이터 제거
                    controller.homeSettingController.removeSizeOption(index);
                  },
                  borderRadius:
                      BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                          SkeletonSpacing.borderRadius / 2),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
