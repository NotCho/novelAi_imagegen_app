import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/domain/gen/tag_suggestion_model.dart';
import 'package:naiapp/view/core/page.dart';
import 'package:naiapp/view/core/util/app_snackbar.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:reorderables/reorderables.dart';

import '../../application/parser/parser_page_controller.dart';

class ParserPage extends GetView<ParserPageController> {
  const ParserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SkeletonPage(
        isLoading: controller.isInitLoading,
        page: PopScope(
          canPop: false,
          child: SkeletonScaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: SkeletonColorScheme.backgroundColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 헤더 정보 카드
                Expanded(
                  child: Column(
                    children: [
                      _buildHeaderCard(),
                      _buildPromptSearchSection(),
                      // 태그 결과 섹션
                      const SizedBox(height: SkeletonSpacing.spacing),

                      Expanded(child: _buildTagSection()),
                    ],
                  ),
                ),

                // 범례 및 버튼 섹션
                _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Column(
      children: [
        // 슬림한 계측기 느낌의 그라데이션 스케일 바
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: SkeletonColorScheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SkeletonColorScheme.surfaceColor,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("-10.0 (부정)",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: SkeletonColorScheme.negativeColor,
                      )),
                  Text("1.0 (기본)",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: SkeletonColorScheme.textSecondaryColor,
                      )),
                  Text("10.0 (긍정)",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      )),
                ],
              ),
              const SizedBox(height: 8),
              // 아주 슬림한 그라데이션 라인
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SkeletonColorScheme.negativeColor,
                        SkeletonColorScheme.textSecondaryColor,
                        Colors.blueAccent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 프롬프트 변환 안내 카드
        Container(
          margin: const EdgeInsets.symmetric(vertical: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: SkeletonColorScheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SkeletonColorScheme.surfaceColor,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: SkeletonColorScheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "프롬프트 변환",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: SkeletonColorScheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${controller.parsedData.length}개의 태그가 감지되었습니다",
                      style: const TextStyle(
                        fontSize: 11,
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromptSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SkeletonSpacing.spacing),
      decoration: BoxDecoration(
        color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
      ),
      child: Obx(
        () => TextField(
          controller: controller.searchController,
          style: const TextStyle(color: SkeletonColorScheme.textColor),
          maxLines: 1,
          decoration: InputDecoration(
            hintText: "검색할 태그를 입력하세요",
            hintStyle:
                const TextStyle(color: SkeletonColorScheme.textSecondaryColor),
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search,
              color: SkeletonColorScheme.textSecondaryColor,
            ),
            suffixIcon: (controller.searchQuery.value.isNotEmpty)
                ? IconButton(
                    onPressed: () {
                      controller.searchController.clear();
                      controller.searchQuery.value = '';
                    },
                    icon: const Icon(Icons.clear))
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 12), // 추가!
          ),
        ),
      ),
    );
  }

  Widget _buildTagSection() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        child: Obx(
          () => ClipRRect(
            borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
            child: ReorderableWrap(
              alignment: WrapAlignment.center,
              spacing: SkeletonSpacing.smallSpacing,
              runSpacing: SkeletonSpacing.smallSpacing,
              onReorder: (oldI, newI) {
                controller.reorderTags(oldI, newI);
              },
              children: List.generate(controller.parsedData.length, (index) {
                final tagData = controller.parsedData[index];
                return AnimatedContainer(
                  key: ValueKey('${tagData.text}_${tagData.weight}'),
                  // 고유한 Key 추가!
                  duration: Duration(milliseconds: 200 + (index * 50)),
                  child: _buildTagChip(tagData),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget chipDialog(TagData tagData) {
    return AlertDialog(
      backgroundColor: SkeletonColorScheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
      ),
      title: Container(
        padding: const EdgeInsets.only(bottom: SkeletonSpacing.smallSpacing),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: SkeletonColorScheme.surfaceColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: controller
                    .getWeightColor(tagData.weight)
                    .withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.tune,
                color: controller.getWeightColor(tagData.weight),
                size: 20,
              ),
            ),
            const SizedBox(width: SkeletonSpacing.spacing),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "태그 이름을 수정하세요",
                  hintStyle: TextStyle(
                    color: SkeletonColorScheme.textSecondaryColor,
                  ),
                  border: InputBorder.none,
                ),
                controller: controller.currentTagController,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SkeletonColorScheme.textColor,
                ),
              ),
            ),
            const SizedBox(width: SkeletonSpacing.smallSpacing),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () {
                controller.deleteTag(tagData);
                Get.back();
              },
            ),
          ],
        ),
      ),
      content: Obx(() {
        final currentIndex =
            controller.parsedData.indexWhere((tag) => tag.text == tagData.text);
        final currentTag =
            currentIndex >= 0 ? controller.parsedData[currentIndex] : tagData;

        return Container(
          width: 300,
          padding:
              const EdgeInsets.symmetric(vertical: SkeletonSpacing.spacing),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 가중치 표시 카드
                Container(
                  padding: const EdgeInsets.all(SkeletonSpacing.spacing),
                  decoration: BoxDecoration(
                    color: controller
                        .getWeightColor(currentTag.weight)
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                    border: Border.all(
                      color: controller
                          .getWeightColor(currentTag.weight)
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "현재 가중치",
                        style: TextStyle(
                          fontSize: 14,
                          color: SkeletonColorScheme.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: controller.getWeightColor(currentTag.weight),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "×${currentTag.weight.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: SkeletonSpacing.spacing),

                // 슬라이더 섹션
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "가중치 조정",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SkeletonColorScheme.textColor,
                      ),
                    ),
                    const SizedBox(height: SkeletonSpacing.smallSpacing),

                    // 슬라이더
                    SliderTheme(
                      data: SliderTheme.of(Get.context!).copyWith(
                        activeTrackColor:
                            controller.getWeightColor(currentTag.weight),
                        inactiveTrackColor: SkeletonColorScheme.surfaceColor,
                        thumbColor:
                            controller.getWeightColor(currentTag.weight),
                        overlayColor: controller
                            .getWeightColor(currentTag.weight)
                            .withValues(alpha: 0.2),
                        valueIndicatorColor:
                            controller.getWeightColor(currentTag.weight),
                        trackHeight: 4,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Stack(
                        children: [
                          Slider(
                            value: currentTag.weight,
                            onChanged: (value) {
                              controller.onSliderChanged(currentIndex, value);
                            },
                            min: -10,
                            max: 10.0,
                            divisions: 100,
                            label: currentTag.weight.toStringAsFixed(2),
                          ),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "-10",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: SkeletonColorScheme.textSecondaryColor,
                                ),
                              ),
                              Text(
                                "10",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: SkeletonColorScheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          const Positioned.fill(
                            child: Align(
                              alignment: Alignment((1.0 + 10) / 20 * 2 - 1, -1),
                              child: Text(
                                "1.0",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: SkeletonColorScheme.textSecondaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
// 범위 표시
                  ],
                ),

                const SizedBox(height: SkeletonSpacing.spacing),

                // 빠른 설정 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickButton("-1", -1, currentIndex),
                    _buildQuickButton("-0.1", -0.1, currentIndex),
                    _buildQuickButton("기본", 1.0, currentIndex),
                    _buildQuickButton("+0.1", 0.1, currentIndex),
                    _buildQuickButton("+1", 1, currentIndex),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  foregroundColor: SkeletonColorScheme.textSecondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "취소",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: SkeletonSpacing.smallSpacing),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (tagData.text !=
                      controller.currentTagController.text.trim()) {
                    int index = controller.parsedData
                        .indexWhere((tag) => tag.text == tagData.text);
                    controller.updateTagText(index);
                  }
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SkeletonColorScheme.primaryColor,
                  foregroundColor: SkeletonColorScheme.textColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                  ),
                ),
                child: const Text(
                  "확인",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

// 빠른 설정 버튼 위젯
  Widget _buildQuickButton(String label, double value, int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: () {
            if (label == "기본") {
              controller.onSliderChanged(index, 0);
            }
            controller.addWeightByButton(index, value);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                SkeletonColorScheme.surfaceColor.withValues(alpha: 0.5),
            foregroundColor: SkeletonColorScheme.textColor,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip(dynamic tagData) {
    return Obx(() {
      final isHighlighted = controller.isTagHighlighted(tagData);
      final weightColor = controller.getWeightColor(tagData.weight);
      final isNeutral = tagData.weight == 1.0;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        child: GestureDetector(
          onTap: () {
            controller.currentTagController.text = tagData.text;
            Get.dialog(chipDialog(tagData));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: SkeletonColorScheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHighlighted
                    ? Colors.yellowAccent.withValues(alpha: 0.9)
                    : weightColor.withValues(alpha: 0.45),
                width: isHighlighted ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHighlighted
                      ? Colors.yellowAccent.withValues(alpha: 0.35)
                      : (!isNeutral
                          ? weightColor.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.1)),
                  blurRadius: isHighlighted ? 8 : 4,
                  spreadRadius: isHighlighted ? 1 : 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  tagData.text,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                    color: SkeletonColorScheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isNeutral
                        ? SkeletonColorScheme.surfaceColor
                        : weightColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isNeutral
                          ? SkeletonColorScheme.surfaceColor
                          : weightColor.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    "×${tagData.weight.toStringAsFixed(1)}",
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: isNeutral
                          ? SkeletonColorScheme.textSecondaryColor
                          : weightColor.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: SkeletonColorScheme.backgroundColor,
        border: const Border(
          top: BorderSide(
            color: SkeletonColorScheme.surfaceColor,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // 새 태그 추가 버튼
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Get.dialog(_buildAddTagDialog());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SkeletonColorScheme.surfaceColor,
                  foregroundColor: SkeletonColorScheme.textColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: SkeletonColorScheme.textColor,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "태그 추가",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 파싱 완료 버튼
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  controller.finishParsing();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SkeletonColorScheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: SkeletonColorScheme.primaryColor.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.done_all_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "파싱 완료",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTagDialog() {
    controller.suggestedTags.clear();

    controller.addTagController.text = ''; // 초기화
    final mediaQuery = MediaQuery.of(Get.context!);
    final availableHeight =
        mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    final suggestionHeight = (availableHeight * 0.22).clamp(96.0, 180.0);

    return AlertDialog(
      backgroundColor: SkeletonColorScheme.cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
      ),
      title: const Text(
        "새 태그 추가",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: SkeletonColorScheme.textColor,
        ),
      ),
      content: SizedBox(
        width: mediaQuery.size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (_) {
                  controller.suggestTag();
                },
                style: const TextStyle(
                  fontSize: 14,
                  color: SkeletonColorScheme.textColor,
                ),
                controller: controller.addTagController,
                decoration: InputDecoration(
                  hintText: "태그를 입력하세요",
                  hintStyle: const TextStyle(
                      color: SkeletonColorScheme.textSecondaryColor),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                  ),
                ),
              ),
              const SizedBox(height: SkeletonSpacing.smallSpacing),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color:
                        SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                    border: Border.all(
                      color: SkeletonColorScheme.primaryColor
                          .withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(SkeletonSpacing.spacing),
                  width: mediaQuery.size.width * 0.8,
                  height: suggestionHeight,
                  child: SingleChildScrollView(
                    child: Wrap(
                        clipBehavior: Clip.hardEdge,
                        spacing: SkeletonSpacing.smallSpacing,
                        runSpacing: SkeletonSpacing.smallSpacing,
                        children: List.generate(
                          controller.suggestedTags.length,
                          (index) {
                            TagModel tag = controller.suggestedTags[index];
                            return _buildSuggestedChip(tag.tag, tag.count);
                          },
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("취소"),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.addTagController.text.trim().isEmpty) {
              AppSnackBar.show("오류", "태그를 입력해주세요");
              return;
            }
            controller.addTag();
            Get.back();
          },
          child: const Text("추가"),
        ),
      ],
    );
  }

  Widget _buildSuggestedChip(String tag, int confidence) {
    return GestureDetector(
      onTap: () {
        controller.addTagController.text = tag;
        controller.suggestTag();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SkeletonSpacing.smallSpacing,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: SkeletonColorScheme.primary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        child: Text(
          tag,
          style: const TextStyle(
            fontSize: 12,
            color: SkeletonColorScheme.textColor,
          ),
        ),
      ),
    );
  }
}
