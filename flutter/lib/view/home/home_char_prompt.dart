import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/prompt_controller.dart';

import '../../domain/gen/diffusion_model.dart' as df;
import '../core/util/components.dart';
import '../core/util/design_system.dart';
import '../core/util/wildcard_highlight_controller.dart';

class HomeCharPrompt extends GetView<PromptController> {
  const HomeCharPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SkeletonSpacing.smallSpacing,
            top: SkeletonSpacing.smallSpacing,
            bottom: SkeletonSpacing.smallSpacing,
          ),
          child: characterSelect(),
        ),
        selectedCharacter(),
      ],
    );
  }

  Widget characterSelect() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65), // 투명 글래스 위에서 텍스트가 묻히지 않도록 어두운 아크릴 백그라운드 적용
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: SkeletonColorScheme.primaryColor.withOpacity(0.25),
            width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      width: 64,
      child: Column(
        children: [
          // 타이틀 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            decoration: BoxDecoration(
              color: SkeletonColorScheme.primaryColor.withOpacity(0.3), // 대비 강화
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
              border: Border(
                bottom: BorderSide(
                  color: SkeletonColorScheme.primaryColor.withOpacity(0.3),
                  width: 0.8,
                ),
              ),
            ),
            child: const Text(
              '목록',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white, // 흰색으로 100% 가독성 확보
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // 캐릭터 리스트
          Expanded(
            child: Obx(
              () => ListView.builder(
                physics: const ClampingScrollPhysics(),
                controller: controller.characterScrollController,
                itemCount: controller.characterPrompts.length + 1,
                itemBuilder: (context, index) {
                  return Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        color: controller.selectedCharacterIndex.value == index
                            ? SkeletonColorScheme.primaryColor
                                .withOpacity(0.18)
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                            width: 0.5,
                          ),
                          left: BorderSide(
                            color: controller.selectedCharacterIndex.value == index
                                ? Colors.cyanAccent
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: (index == controller.characterPrompts.length)
                          ? Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: controller.onCharaAddButtonTap,
                                child: Container(
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: SkeletonColorScheme.primaryColor
                                          .withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add,
                                        color: Colors.cyanAccent,
                                        size: 14),
                                  ),
                                ),
                              ),
                            )
                          : Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => controller.onCharaTap(index),
                                child: SizedBox(
                                  height: 50,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: controller
                                                      .selectedCharacterIndex
                                                      .value ==
                                                  index
                                              ? SkeletonColorScheme.primaryColor
                                                  .withOpacity(0.25)
                                              : !controller
                                                      .isCharacterEnabled(index)
                                                  ? SkeletonColorScheme
                                                      .negativeColor
                                                      .withOpacity(0.15)
                                                  : Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: controller
                                                        .selectedCharacterIndex
                                                        .value ==
                                                    index
                                                ? Colors.cyanAccent
                                                : Colors.transparent,
                                            width: 0.8,
                                          ),
                                        ),
                                        child:
                                            controller.isCharacterEnabled(index)
                                                ? Text(
                                                    "${index + 1}",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: (controller
                                                                  .selectedCharacterIndex
                                                                  .value ==
                                                              index)
                                                          ? Colors.cyanAccent
                                                          : Colors.white.withOpacity(0.7),
                                                      fontWeight: (controller
                                                                  .selectedCharacterIndex
                                                                  .value ==
                                                              index)
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      fontSize: 10,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.visibility_off,
                                                    color: Colors.redAccent,
                                                    size: 12,
                                                  ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        controller.isCharacterEnabled(index)
                                            ? "캐릭터"
                                            : "OFF",
                                        style: TextStyle(
                                          color: (controller
                                                      .selectedCharacterIndex
                                                      .value ==
                                                  index)
                                              ? Colors.cyanAccent
                                              : Colors.white.withOpacity(0.5),
                                          fontSize: 9,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectedCharacter() {
    return Expanded(
      child: Obx(
        () => (controller.characterPrompts.isEmpty)
            ? Center(
                child: Container(
                  padding: const EdgeInsets.all(SkeletonSpacing.spacing),
                  decoration: BoxDecoration(
                    color:
                        SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                    border: Border.all(
                        color: SkeletonColorScheme.primaryColor
                            .withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_alt_1,
                        color: SkeletonColorScheme.primaryColor
                            .withValues(alpha: 0.5),
                        size: 48,
                      ),
                      const SizedBox(height: SkeletonSpacing.spacing),
                      const Text(
                        "캐릭터를 먼저 추가하세요",
                        style: TextStyle(
                          color: SkeletonColorScheme.textSecondaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: SkeletonSpacing.smallSpacing),
                      ElevatedButton(
                        onPressed: controller.onCharaAddButtonTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SkeletonColorScheme.primaryColor,
                          foregroundColor: SkeletonColorScheme.textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                SkeletonSpacing.borderRadius / 2),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 16),
                            SizedBox(width: 8),
                            Text("캐릭터 추가"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                clipBehavior: Clip.none,
                padding: const EdgeInsets.all(SkeletonSpacing.smallSpacing),
                child: Column(
                  children: [
                    // 캐릭터 헤더
                    _buildCharacterHeader(),
                    const SizedBox(height: SkeletonSpacing.smallSpacing),
                    // 캐릭터 프롬프트 입력 영역
                    Column(
                      children: [
                        characterInputField(true),
                        const SizedBox(height: 12),
                        characterInputField(false),
                        const SizedBox(height: 12),
                        SettingsCard(
                          title: "캐릭터 위치 설정 (가운데는 자동)",
                          icon: Icons.location_on_outlined,
                          child: characterPosition(
                              controller.convertPosition(controller
                                  .characterPositions.value.x
                                  .toDouble()),
                              controller.convertPosition(controller
                                  .characterPositions.value.y
                                  .toDouble())),
                        )
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget characterPosition(double x, double y) {
    return Row(
      children: [
        SizedBox(
            height: 120, child: characterPositionTile(x.toInt(), y.toInt())),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      SkeletonColorScheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(SkeletonSpacing.borderRadius),
                  border: Border.all(
                      color: SkeletonColorScheme.primaryColor
                          .withValues(alpha: 0.3)),
                ),
                child: Text(
                  "X: ${x.toInt()} Y: ${y.toInt()}",
                  style: const TextStyle(
                    color: SkeletonColorScheme.textColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Get.dialog(
                  positionDialog(),
                  barrierDismissible: true,
                );
              },
              icon: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: SkeletonColorScheme.primaryColor
                          .withValues(alpha: 0.2),
                      shape: BoxShape.rectangle,
                      borderRadius:
                          BorderRadius.circular(SkeletonSpacing.borderRadius),
                      border: Border.all(
                        color: SkeletonColorScheme.primaryColor
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: SkeletonColorScheme.primaryColor,
                          size: 30,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "위치 수정",
                          style: TextStyle(
                            color: SkeletonColorScheme.textColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget characterPositionTile(int x, int y) {
    int xIndex = x ~/ 2;
    int yIndex = y ~/ 2;
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
              border: Border.all(
                  color:
                      SkeletonColorScheme.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Row(
                    children: List.generate(5, (innerIndex) {
                      return GestureDetector(
                        onTap: () {
                          // controller.setCharacterPosition(x, y, index, innerIndex);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: (xIndex == innerIndex && yIndex == index)
                                  ? SkeletonColorScheme.primaryColor
                                      .withValues(alpha: 0.5)
                                  : SkeletonColorScheme.primaryColor
                                      .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: SkeletonColorScheme.primaryColor
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }))),
      ],
    );
  }

  Widget positionDialog() {
    return AlertDialog(
      backgroundColor: SkeletonColorScheme.cardColor,
      title: const Text('위치 설정',
          style: TextStyle(
              color: SkeletonColorScheme.textColor,
              fontWeight: FontWeight.bold)),
      content: Container(
        decoration: BoxDecoration(
          color: SkeletonColorScheme.cardColor,
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        child: Obx(() {
          df.Center center = controller.characterPositions.value;
          int x = center.x * 10 ~/ 2;
          int y = center.y * 10 ~/ 2;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (innerIndex) {
                      return GestureDetector(
                        onTap: () {
                          controller.setCharacterPosition(innerIndex, index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: (x == innerIndex && y == index)
                                  ? SkeletonColorScheme.primaryColor
                                      .withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: SkeletonColorScheme.primaryColor
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
              const SizedBox(width: SkeletonSpacing.smallSpacing),
            ],
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
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

  // 캐릭터 헤더 위젯
  Widget _buildCharacterHeader() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65), // 가독성을 위한 단단한 블랙 아크릴 배경
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: SkeletonColorScheme.primaryColor.withOpacity(0.25),
            width: 0.8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SkeletonColorScheme.primaryColor.withOpacity(0.3), // 뱃지 대비 강화
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: SkeletonColorScheme.primaryColor.withOpacity(0.4),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person,
                      color: Colors.white, size: 12), // 아이콘을 흰색으로 고대비화
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      "캐릭터 #${controller.selectedCharacterIndex.value + 1}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white, // 흰색으로 가독성 극대화
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Row(
            children: [
              Obx(() {
                final enabled = controller.isCharacterEnabled(
                    controller.selectedCharacterIndex.value);
                return AnimatedContainer(
                  duration: SkeletonSpacing.animationDuration,
                  width: 44,
                  height: 28,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: enabled
                        ? SkeletonColorScheme.primaryColor.withOpacity(0.25)
                        : Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: enabled
                          ? Colors.cyanAccent
                          : Colors.white.withOpacity(0.15),
                      width: 0.8,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: controller.toggleSelectedCharacterEnabled,
                      borderRadius: BorderRadius.circular(5),
                      child: Center(
                        child: Text(
                          enabled ? "ON" : "OFF",
                          style: TextStyle(
                            color: enabled
                                ? Colors.cyanAccent
                                : Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              Obx(() => AnimatedContainer(
                    duration: SkeletonSpacing.animationDuration,
                    width: controller.confirmRemoveIndex.value ? 80 : 28, // width 80 / 28 복원
                    height: 28, // height 28 복원 및 고정
                    decoration: BoxDecoration(
                      color: controller.confirmRemoveIndex.value
                          ? SkeletonColorScheme.negativeColor
                          : SkeletonColorScheme.negativeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: controller.confirmRemoveIndex.value
                          ? [
                              BoxShadow(
                                color: SkeletonColorScheme.negativeColor.withValues(alpha: 0.2),
                                blurRadius: 4,
                                spreadRadius: 0.5,
                              ),
                            ]
                          : [],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: controller.onCharaRemoveButtonTap,
                        borderRadius: BorderRadius.circular(5),
                        child: Center( // Center 정렬로 패딩 소실 방지
                          child: controller.confirmRemoveIndex.value
                              ? const SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delete_forever,
                                          color: SkeletonColorScheme.textColor,
                                          size: 12),
                                      SizedBox(width: 3),
                                      Text(
                                        "삭제확인",
                                        style: TextStyle(
                                          color: SkeletonColorScheme.textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Icon(Icons.delete,
                                  color: SkeletonColorScheme.negativeColor,
                                  size: 14),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget characterInputField(bool isPositive) {
    final Color color = isPositive
        ? SkeletonColorScheme.accentColor
        : SkeletonColorScheme.negativeColor;
    final String title = isPositive ? "캐릭터 긍정 프롬프트" : "캐릭터 부정 프롬프트";
    final IconData icon = isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline;

    return GestureDetector(
      onTap: () {
        Get.dialog(PromptDialog(
            textController: controller
                    .characterPrompts[controller.selectedCharacterIndex.value]
                [isPositive ? 'positive' : 'negative'],
            title: title,
            color: color));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: SkeletonSpacing.smallSpacing),
        decoration: BoxDecoration(
          color: SkeletonColorScheme.cardColor.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀 헤더 (전역 프롬프트와 동일한 스타일 적용)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 미니멀한 네온 도트 인디케이터
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, color: color.withValues(alpha: 0.85), size: 15),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: SkeletonColorScheme.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.edit,
                    color: SkeletonColorScheme.textSecondaryColor,
                    size: 14,
                  ),
                ],
              ),
            ),

            // 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: WildcardTextField(
                enabled: false,
                controller: controller.characterPrompts[controller
                    .selectedCharacterIndex
                    .value][isPositive ? 'positive' : 'negative'],
                highlightColor: color,
                style: const TextStyle(
                  color: SkeletonColorScheme.textColor,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isPositive ? '캐릭터 긍정 프롬프트' : '캐릭터 부정 프롬프트',
                  hintStyle: const TextStyle(
                    color: SkeletonColorScheme.textSecondaryColor,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
