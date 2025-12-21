import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../../application/home/home_image_controller.dart';
import '../../infra/service/webp_image_parser.dart';
import '../core/util/app_snackbar.dart';
import '../core/util/design_system.dart';

class HomeImageView extends GetView<HomeImageController> {
  final int historyMax = 30;

  const HomeImageView({super.key}); // 최대 히스토리 개수
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: SkeletonColorScheme.cardColor,
      child: Obx(() {
        if (controller.generatedImageBytes.value.isEmpty) {
          // 이미지가 없을 때 플레이스홀더 디자인 개선
          return _buildEmptyImagePlaceholder();
        }
        // 이미지 표시 부분에 그림자 효과와 애니메이션 추가
        return Stack(
          children: [
            PageView.builder(
              onPageChanged: controller.onPageChanged,
              controller: controller.imageViewPageController,
              itemCount:
                  math.min(historyMax + 1, controller.generationHistory.length),

              // 히스토리 최대 30개 + currentImage 1개
              itemBuilder: (context, index) {
                final reversedIndex =
                    controller.generationHistory.length - index - 1;
                // 마지막 페이지 = currentImageBytes
                if (index == historyMax) {
                  return Container(
                    decoration: BoxDecoration(
                      color: SkeletonColorScheme.primaryColor
                          .withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(SkeletonSpacing.borderRadius),
                      border: Border.all(
                        color: SkeletonColorScheme.primaryColor
                            .withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Obx(
                      () => Image.memory(
                        controller.currentImageBytes.value,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }

                // 0~29번 페이지 = generationHistory[0]부터 순서대로
                else {
                  if (index < controller.generationHistory.length) {
                    final historyItem =
                        controller.generationHistory[reversedIndex];
                    return Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        InkWell(
                          onLongPress: () {
                            Get.dialog(longTapDialog());
                          },
                          child: Container(
                            padding:
                                const EdgeInsets.all(SkeletonSpacing.spacing),
                            decoration: BoxDecoration(
                              color: SkeletonColorScheme.surfaceColor
                                  .withValues(alpha: 0.3),
                            ),
                            child: Image.memory(
                              base64Decode(historyItem.imagePath),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  AppSnackBar.show(
                                    'Seed 복사됨',
                                    'Seed: ${historyItem.seed}',
                                    backgroundColor: SkeletonColorScheme
                                        .primaryColor
                                        .withValues(alpha: 0.9),
                                    textColor: Colors.white,
                                    margin: const EdgeInsets.all(16),
                                    borderRadius: SkeletonSpacing.borderRadius,
                                    duration: const Duration(seconds: 2),
                                  );
                                  // 클립보드에 복사
                                  Clipboard.setData(ClipboardData(
                                      text: historyItem.seed.toString()));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(
                                        SkeletonSpacing.borderRadius),
                                    border: Border.all(
                                      color: SkeletonColorScheme.primaryColor
                                          .withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.tag,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Seed: ${historyItem.seed}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.copy,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // 히스토리가 없으면 빈 컨테이너
                  else {
                    return Container(
                      padding: const EdgeInsets.all(SkeletonSpacing.spacing),
                      child: const Center(
                        child: Text(
                          '더 이상 이미지가 없습니다',
                          style: TextStyle(
                            color: SkeletonColorScheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            Obx(
              () => Positioned(
                  child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        controller.imageViewPageController.animateToPage(0,
                            duration: SkeletonSpacing.animationDuration,
                            curve: Curves.easeIn);
                      },
                      icon: Icon(
                        Icons.keyboard_double_arrow_left,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 32,
                      )),
                  Text(
                    '${(controller.currentImageViewIndex.value < historyMax) ? controller.currentImageViewIndex.value + 1 : "$historyMax+"} / ${(controller.generationHistory.length > historyMax) ? "$historyMax+" : controller.generationHistory.length}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                  )
                ],
              )),
            ),
          ],
        );
      }),
    );
  }

  // 빈 이미지 플레이스홀더 위젯
  Widget _buildEmptyImagePlaceholder() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: SkeletonSpacing.spacing * 5),
          Container(
            padding: const EdgeInsets.all(SkeletonSpacing.spacing),
            decoration: BoxDecoration(
              color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_outlined,
              color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.6),
              size: 64,
            ),
          ),
          const SizedBox(height: SkeletonSpacing.spacing),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SkeletonSpacing.spacing,
                vertical: SkeletonSpacing.smallSpacing),
            decoration: BoxDecoration(
              color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
            ),
            child: const Text(
              '이미지를 생성하세요',
              style: TextStyle(
                color: SkeletonColorScheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: SkeletonSpacing.spacing),
          const Text(
            '아래 패널에서 프롬프트를 입력하고 생성 버튼을 눌러보세요',
            style: TextStyle(
              color: SkeletonColorScheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget longTapDialog() {
    return AlertDialog(
      backgroundColor: SkeletonColorScheme.cardColor,
      title: Text("클립보드에 복사",
          style: SkeletonTextTheme.newBody18Bold.copyWith(color: Colors.white)),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
              ),
              child: Image.memory(
                controller.currentImageBytes.value,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: SkeletonColorScheme.surfaceColor,
                      borderRadius: BorderRadius.circular(
                        SkeletonSpacing.borderRadius,
                      )),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text("프롬프트",
                        style: SkeletonTextTheme.newBody14
                            .copyWith(color: Colors.white)),
                    Row(
                      children: [
                        Expanded(child: _buildCopyButton("긍정", "positive")),
                        SkeletonSpacing.hTiny,
                        Expanded(child: _buildCopyButton("부정", "negative")),
                      ],
                    ),
                  ]),
                ),
                SkeletonSpacing.vTiny,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  child: _buildCopyButton("시드", "seed"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyButton(String label, String type) {
    return InkWell(
      onTap: () => _copyToClipboard(type),
      child: Container(
        padding: const EdgeInsets.all(SkeletonSpacing.smallSpacing),
        decoration: BoxDecoration(
            color: SkeletonColorScheme.primaryColor,
            borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(label,
              style: SkeletonTextTheme.newBody12.copyWith(color: Colors.white)),
        ),
      ),
    );
  }

  void _copyToClipboard(String type) {
    try {
      // 현재 이미지에서 메타데이터 추출
      final textChunks = WebPMetadataParser.extractMetadata(
          controller.currentImageBytes.value);

      if (textChunks == null || textChunks.isEmpty) {
        AppSnackBar.show(
          '오류',
          '메타데이터를 찾을 수 없습니다',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // 메타데이터에서 정보 추출
      final jsonStr = textChunks['Comment'] ?? '';
      if (jsonStr.isEmpty) {
        AppSnackBar.show(
          '오류',
          '메타데이터가 비어있습니다',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      final Map<String, dynamic> exifData = jsonDecode(jsonStr);
      String textToCopy = '';

      if (type == "positive") {
        // 긍정 프롬프트 추출
        final v4Prompt = exifData['v4_prompt'] ?? {};
        final caption = v4Prompt['caption'] ?? {};
        textToCopy = caption['base_caption'] ?? '';
      } else if (type == "negative") {
        // 부정 프롬프트 추출
        final v4NegativePrompt = exifData['v4_negative_prompt'] ?? {};
        final caption = v4NegativePrompt['caption'] ?? {};
        textToCopy = caption['base_caption'] ?? '';
      } else if (type == "seed") {
        // 시드 추출
        final int seed = exifData['seed'] ?? 999999999;
        textToCopy = seed.toString();
      }

      if (textToCopy.isEmpty && type != "seed") {
        AppSnackBar.show(
          '오류',
          '${type == "positive" ? "긍정" : "부정"} 프롬프트를 찾을 수 없습니다',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // 클립보드에 복사
      Clipboard.setData(ClipboardData(text: textToCopy));
      AppSnackBar.show(
        '복사 완료',
        type == "positive"
            ? '긍정 프롬프트가 클립보드에 복사되었습니다'
            : type == "negative"
                ? '부정 프롬프트가 클립보드에 복사되었습니다'
                : '시드가 클립보드에 복사되었습니다',
        backgroundColor:
            SkeletonColorScheme.primaryColor.withValues(alpha: 0.9),
        textColor: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: SkeletonSpacing.borderRadius,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      AppSnackBar.show(
        '오류',
        '복사 중 오류가 발생했습니다: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
