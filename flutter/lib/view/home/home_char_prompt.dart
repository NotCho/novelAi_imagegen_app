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
        color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12), // 16 -> 12로 더 정교하고 슬림하게
        border: Border.all(
            color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.15),
            width: 0.8), // border 두께를 얇게 조절
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      width: 64, // 70 -> 64로 슬림화
      child: Column(
        children: [
          // 타이틀 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            decoration: BoxDecoration(
              color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
              border: Border(
                bottom: BorderSide(
                  color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.15),
                  width: 0.8,
                ),
              ),
            ),
            child: const Text(
              '목록',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SkeletonColorScheme.primaryColor,
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
                                .withValues(alpha: 0.1) // 0.2 -> 0.1로 소프트하게
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                          // 선택되었을 때 왼쪽에 얇고 우아한 세로 인디케이터 선 추가
                          left: BorderSide(
                            color: controller.selectedCharacterIndex.value == index
                                ? SkeletonColorScheme.primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: (index == controller.characterPrompts.length)
                          ? Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: controller.onCharaAddButtonTap,
                                child: Container(
                                  height: 44, // 50 -> 44로 단축
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.all(5), // 6 -> 5
                                    decoration: BoxDecoration(
                                      color: SkeletonColorScheme.primaryColor
                                          .withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add,
                                        color: SkeletonColorScheme.primaryColor,
                                        size: 14), // 16 -> 14
                                  ),
                                ),
                              ),
                            )
                          : Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => controller.onCharaTap(index),
                                child: SizedBox(
                                  height: 50, // 60 -> 50으로 컴팩트하게
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 24, // 30 -> 24
                                        height: 24, // 30 -> 24
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: controller
                                                      .selectedCharacterIndex
                                                      .value ==
                                                  index
                                              ? SkeletonColorScheme.primaryColor
                                                  .withValues(alpha: 0.2) // 0.3 -> 0.2
                                              : !controller
                                                      .isCharacterEnabled(index)
                                                  ? SkeletonColorScheme
                                                      .negativeColor
                                                      .withValues(alpha: 0.12)
                                                  : SkeletonColorScheme
                                                      .surfaceColor
                                                      .withValues(alpha: 0.25),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: controller
                                                        .selectedCharacterIndex
                                                        .value ==
                                                    index
                                                ? SkeletonColorScheme
                                                    .primaryColor
                                                : Colors.transparent,
                                            width: 0.8, // 1 -> 0.8
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
                                                          ? SkeletonColorScheme
                                                              .primaryColor
                                                          : SkeletonColorScheme
                                                              .textSecondaryColor,
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
                                                    color: SkeletonColorScheme
                                                        .negativeColor,
                                                    size: 12, // 16 -> 12
                                                  ),
                                      ),
                                      const SizedBox(height: 2), // 4 -> 2
                                      Text(
                                        controller.isCharacterEnabled(index)
                                            ? "캐릭터"
                                            : "OFF",
                                        style: TextStyle(
                                          color: (controller
                                                      .selectedCharacterIndex
                                                      .value ==
                                                  index)
                                              ? SkeletonColorScheme.primaryColor
                                              : SkeletonColorScheme
                                                  .textSecondaryColor,
                                          fontSize: 9, // 10 -> 9
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
      height: 44, // 46 -> 44로 더 얇게 조율하여 목록 헤더 감각과 완벽 매칭
      decoration: BoxDecoration(
        color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8), // 10 -> 8로 모서리를 샤프하게 조율
        border: Border.all(
            color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.15),
            width: 0.8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8), // 10 -> 8
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              height: 28, // 높이 28로 극상의 슬림함 연출
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5), // 6 -> 5
                border: Border.all(
                  color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person,
                      color: SkeletonColorScheme.primaryColor, size: 12), // 13 -> 12
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      "캐릭터 #${controller.selectedCharacterIndex.value + 1}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SkeletonColorScheme.primaryColor,
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
                  width: 44, // width 44로 슬림화
                  height: 28, // height 28로 복원 및 고정
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: enabled
                        ? SkeletonColorScheme.primaryColor.withValues(alpha: 0.15)
                        : SkeletonColorScheme.surfaceColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: enabled
                          ? SkeletonColorScheme.primaryColor.withValues(alpha: 0.3)
                          : SkeletonColorScheme.textSecondaryColor.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: controller.toggleSelectedCharacterEnabled,
                      borderRadius: BorderRadius.circular(5),
                      child: Center( // padding 대신 Center 정렬로 높이 유지
                        child: Text(
                          enabled ? "ON" : "OFF",
                          style: TextStyle(
                            color: enabled
                                ? SkeletonColorScheme.primaryColor
                                : SkeletonColorScheme.textSecondaryColor,
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
    final Color promptColor = isPositive
        ? SkeletonColorScheme.accentColor
        : SkeletonColorScheme.negativeColor;
    final String title = isPositive ? "캐릭터 긍정 프롬프트" : "캐릭터 부정 프롬프트";

    return GestureDetector(
      onTap: () {
        Get.dialog(PromptDialog(
            textController: controller
                    .characterPrompts[controller.selectedCharacterIndex.value]
                [isPositive ? 'positive' : 'negative'],
            title: title,
            color: promptColor));
      },
      child: Container(
        margin:
            const EdgeInsets.symmetric(vertical: SkeletonSpacing.smallSpacing),
        decoration: BoxDecoration(
          color: promptColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
          border: Border.all(color: promptColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: promptColor.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(SkeletonSpacing.borderRadius - 1),
                  topRight: Radius.circular(SkeletonSpacing.borderRadius - 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                      isPositive
                          ? Icons.add_circle_outline
                          : Icons.remove_circle_outline,
                      color: promptColor,
                      size: 16),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: promptColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.edit, color: promptColor, size: 16),
                ],
              ),
            ),

            // 입력 필드
            Container(
              padding: const EdgeInsets.all(12.0),
              child: WildcardTextField(
                enabled: false,
                controller: controller.characterPrompts[controller
                    .selectedCharacterIndex
                    .value][isPositive ? 'positive' : 'negative'],
                highlightColor: promptColor,
                style: const TextStyle(color: SkeletonColorScheme.textColor),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isPositive ? '캐릭터 긍정 프롬프트' : '캐릭터 부정 프롬프트',
                  hintStyle: const TextStyle(
                      color: SkeletonColorScheme.textSecondaryColor),
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
