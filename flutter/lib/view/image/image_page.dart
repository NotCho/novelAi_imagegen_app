import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/core/global_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/view/core/page.dart';
import 'package:naiapp/view/core/util/app_snackbar.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:photo_view/photo_view.dart';
import '../../application/home/image_cache_manager.dart';
import '../../application/image/image_page_controller.dart';

class ImagePage extends GetView<ImagePageController> {
  ImagePage({super.key});

  final HomeImageController homeImageController =
      Get.find<HomeImageController>();

  @override
  Widget build(BuildContext context) {
    // 새로운 이미지들 체크해서 캐싱
    controller.checkAndCacheNewImages();

    return Obx(() {
      List<GenerationHistoryItem> items = (controller.searchMode.value)
          ? homeImageController.filteredGenerationHistory
          : homeImageController.generationHistory;

      return SkeletonPage(
        isLoading: controller.isInitLoading,
        page: SkeletonScaffold(
          bodyPadding: const EdgeInsets.all(0),
          backgroundColor: SkeletonColorScheme.backgroundColor,
          appBar: SkeletonAppBar(
            backgroundColor: SkeletonColorScheme.backgroundColor,
            isLeftIconDisplayed: true,
            customAction: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 선택모드일 때 전체선택/해제 버튼
                  if (controller.selectMode.value)
                    Obx(() => Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (controller.selectedIndexes.length ==
                                    items.length) {
                                  controller.selectedIndexes.clear();
                                  for (var notifier
                                      in controller.itemSelectionNotifiers) {
                                    notifier.value = false;
                                  }
                                } else {
                                  controller.selectedIndexes.clear();
                                  // 실제 인덱스로 추가 (뒤집지 않은 상태)
                                  controller.selectedIndexes.addAll(
                                      List.generate(
                                          items.length, (index) => index));
                                  for (var notifier
                                      in controller.itemSelectionNotifiers) {
                                    notifier.value = true;
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(
                                  SkeletonSpacing.borderRadius / 2),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: SkeletonColorScheme.primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      SkeletonSpacing.borderRadius / 2),
                                  border: Border.all(
                                    color: SkeletonColorScheme.primaryColor
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  controller.selectedIndexes.length ==
                                          items.length
                                      ? Icons.deselect
                                      : Icons.select_all,
                                  color: SkeletonColorScheme.primaryColor,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        )),
                  // 선택모드 토글 버튼
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        controller.toggleSelectMode();
                      },
                      borderRadius: BorderRadius.circular(
                          SkeletonSpacing.borderRadius / 2),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: controller.selectMode.value
                              ? SkeletonColorScheme.primaryColor
                                  .withValues(alpha: 0.2)
                              : SkeletonColorScheme.surfaceColor
                                  .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                              SkeletonSpacing.borderRadius / 2),
                          border: Border.all(
                            color: controller.selectMode.value
                                ? SkeletonColorScheme.primaryColor
                                    .withValues(alpha: 0.5)
                                : SkeletonColorScheme.textSecondaryColor
                                    .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          controller.selectMode.value
                              ? Icons.check_box
                              : Icons.check_box_outlined,
                          color: controller.selectMode.value
                              ? SkeletonColorScheme.primaryColor
                              : SkeletonColorScheme.textSecondaryColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              // 선택모드일 때 액션 버튼들
              if (controller.selectMode.value)
                Obx(() => AnimatedContainer(
                      duration: SkeletonSpacing.animationDuration,
                      width: double.infinity,
                      height: controller.selectedIndexes.isNotEmpty ? 93 : 0,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SkeletonColorScheme.cardColor,
                        borderRadius:
                            BorderRadius.circular(SkeletonSpacing.borderRadius),
                        border: Border.all(
                          color: SkeletonColorScheme.primaryColor
                              .withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeInOut,
                        opacity: controller.selectedIndexes.isNotEmpty ? 1 : 0,
                        child: SingleChildScrollView(
                          child: Row(
                            children: [
                              // 선택 정보
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: SkeletonColorScheme.primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      SkeletonSpacing.borderRadius / 3),
                                ),
                                child: const Icon(
                                  Icons.photo_library,
                                  color: SkeletonColorScheme.primaryColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${controller.selectedIndexes.length}개 이미지 선택됨',
                                      style: const TextStyle(
                                        color: SkeletonColorScheme.textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      '선택된 이미지들을 \n다운로드할 수 있습니다',
                                      style: TextStyle(
                                        color: SkeletonColorScheme
                                            .textSecondaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // 다운로드 버튼
                              Column(
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        controller.saveMultipleImages();
                                        AppSnackBar.show(
                                          '다운로드 완료',
                                          '${controller.selectedIndexes.length}개 이미지가 저장되었습니다',
                                          backgroundColor: SkeletonColorScheme
                                              .primaryColor
                                              .withValues(alpha: 0.1),
                                          textColor:
                                              SkeletonColorScheme.textColor,
                                          margin: const EdgeInsets.all(16),
                                          borderRadius:
                                              SkeletonSpacing.borderRadius,
                                          duration: const Duration(seconds: 2),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(
                                          SkeletonSpacing.borderRadius / 2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              SkeletonColorScheme.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                              SkeletonSpacing.borderRadius / 2),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.download,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              '다운로드',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        controller.deleteSelectedImages(items);
                                      },
                                      borderRadius: BorderRadius.circular(
                                          SkeletonSpacing.borderRadius / 2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              SkeletonColorScheme.negativeColor,
                                          borderRadius: BorderRadius.circular(
                                              SkeletonSpacing.borderRadius / 2),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              '삭제',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // 삭제 버튼
                            ],
                          ),
                        ),
                      ),
                    )),
              // 이미지 그리드
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          TextField(
                            style: const TextStyle(
                              color: SkeletonColorScheme.textColor,
                              fontSize: 14,
                            ),
                            onSubmitted: (v) {
                              if (v.isEmpty) {
                                controller.searchMode.value = false;
                              } else {
                                controller.searchMode.value = true;
                                homeImageController.searchImageByPrompt(v);
                              }
                            },
                            controller: controller.searchController,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  controller.searchMode.value = false;
                                  controller.searchController.clear();
                                },
                              ),
                              hintText: '이미지 검색',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: SkeletonColorScheme.black,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    SkeletonSpacing.borderRadius),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              controller: controller.scrollController,
                              // 스크롤 컨트롤러 연결!
                              padding: const EdgeInsets.only(bottom: 16),
                              cacheExtent: 1000,
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                // 실제 데이터 인덱스 (최신 이미지가 위에 오도록)

                                // ValueNotifier 배열 크기 조정
                                while (
                                    controller.itemSelectionNotifiers.length <=
                                        index) {
                                  controller.itemSelectionNotifiers
                                      .add(ValueNotifier<bool>(false));
                                }

                                return ImageGridItem(
                                  index: index,
                                  // 실제 데이터 인덱스 전달
                                  imageData: items[index].imagePath,
                                  isSelectModeNotifier:
                                      controller.selectModeNotifier,
                                  selectionNotifier:
                                      controller.itemSelectionNotifiers[index],
                                  controller: controller,
                                  onTap: () => Get.dialog(imageDialog(index)),
                                  onSelectionChanged: (bool isSelected) {
                                    if (isSelected) {
                                      controller.selectedIndexes.add(index);
                                    } else {
                                      controller.selectedIndexes.remove(index);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor:
                                (controller.keepScrollPosition.value)
                                    ? SkeletonColorScheme.negativeColor
                                        .withValues(alpha: 0.8)
                                    : SkeletonColorScheme.newGreenColor
                                        .withValues(alpha: 0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  SkeletonSpacing.borderRadius / 2),
                            ),
                          ),
                          color: SkeletonColorScheme.textColor,
                          onPressed: controller.onScrollIconTap,
                          icon: const Icon(Icons.arrow_downward_sharp)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget imageDialog(int index) {
    controller.currentIndex.value = index;
    return SkeletonScaffold(
      bodyPadding: EdgeInsets.zero,
      body: Obx(
        () {
          // searchMode일 때와 일반 모드일 때 다른 리스트 사용
          List<GenerationHistoryItem> currentItems =
              (controller.searchMode.value)
                  ? homeImageController.filteredGenerationHistory
                  : homeImageController.generationHistory;

          if (currentItems.isEmpty) {
            return const SizedBox.shrink();
          }

          final currentItem = currentItems[controller.currentIndex.value];

          return Stack(
            children: [
              // 1. 메인 뷰어 (PhotoView)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0C0C0E), // 아크릴 질감을 뒷받침하는 깊이있는 다크 메탈 톤 배경
                  child: Hero(
                    tag: 'thumbnail_${controller.currentIndex.value}',
                    child: PhotoView(
                      imageProvider: MemoryImage(
                        ImageCacheManager.instance.getImageBytes(currentItem.imagePath),
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2.5,
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),

              // 2. 상단 글래스모피즘 아크릴 스마트 플로팅 바
              Positioned(
                top: 44,
                left: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 0.6,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${controller.currentIndex.value + 1}  /  ${currentItems.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 다운로드 캡슐 버튼
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    controller.global.saveImageWithMetadata(
                                        ImageCacheManager.instance.getImageBytes(currentItem.imagePath));
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.download_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 닫기 캡슐 버튼
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => Get.back(),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. 왼쪽 아크릴 유리 플로팅 원형 버튼
              if (controller.currentIndex.value > 0)
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (controller.currentIndex.value > 0) {
                                controller.currentIndex.value--;
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 0.6,
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // 4. 오른쪽 아크릴 유리 플로팅 원형 버튼
              if (controller.currentIndex.value < currentItems.length - 1)
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (controller.currentIndex.value < currentItems.length - 1) {
                                controller.currentIndex.value++;
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 0.6,
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // 5. 하단 스마트 정보 / 퀵 액션 아크릴 플로팅 스마트 바
              Positioned(
                bottom: 28,
                left: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 0.6,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상단 프롬프트 슬림 요약
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentItem.prompt.isEmpty 
                                      ? '프롬프트 정보 없음' 
                                      : currentItem.prompt,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          const SizedBox(height: 8),
                          // 하단 시드 칩 & 복사 퀵 액션 행
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 1) Seed 정보 캡슐 (원터치 복사 연동)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text: currentItem.seed.toString()));
                                    AppSnackBar.show(
                                      'Seed 복사 완료',
                                      'Seed: ${currentItem.seed}',
                                      backgroundColor: SkeletonColorScheme.primaryColor.withValues(alpha: 0.95),
                                      textColor: Colors.white,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: SkeletonSpacing.borderRadius,
                                      duration: const Duration(seconds: 2),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.tag_rounded,
                                          color: Colors.white.withValues(alpha: 0.7),
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Seed: ${currentItem.seed}',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.copy_rounded,
                                          color: Colors.white.withValues(alpha: 0.5),
                                          size: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // 2) 프롬프트 복사 버튼
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: currentItem.prompt));
                                    AppSnackBar.show(
                                      '프롬프트 복사 완료',
                                      '프롬프트가 클립보드에 복사되었습니다.',
                                      backgroundColor: SkeletonColorScheme.primaryColor.withValues(alpha: 0.95),
                                      textColor: Colors.white,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: SkeletonSpacing.borderRadius,
                                      duration: const Duration(seconds: 2),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.25),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.text_fields_rounded,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '프롬프트 복사',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// 개별 이미지 그리드 아이템 위젯
class ImageGridItem extends StatefulWidget {
  final int index;
  final String imageData;
  final ValueNotifier<bool> isSelectModeNotifier;
  final ValueNotifier<bool> selectionNotifier;
  final VoidCallback onTap;
  final Function(bool) onSelectionChanged;
  final ImagePageController controller;

  const ImageGridItem({
    super.key,
    required this.index,
    required this.imageData,
    required this.isSelectModeNotifier,
    required this.selectionNotifier,
    required this.onTap,
    required this.onSelectionChanged,
    required this.controller,
  });

  @override
  State<ImageGridItem> createState() => _ImageGridItemState();
}

class _ImageGridItemState extends State<ImageGridItem>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  Uint8List? _decodedImage;
  bool _isDecoded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int? _imageWidth;
  int? _imageHeight;

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(ImageGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 이미지 데이터가 바뀌면 새로 로드
    if (oldWidget.imageData != widget.imageData) {
      _isDecoded = false;
      _decodedImage = null;
      _imageWidth = null;
      _imageHeight = null;
      _loadImage();
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadImage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadImage() async {
    try {
      final bytes = ImageCacheManager.instance.getImageBytes(widget.imageData);
      _decodedImage = bytes;
      _isDecoded = true;
      if (mounted) setState(() {});

      // 비동기 이미지 디코딩으로 이미지 해상도 정보 획득
      final image = await decodeImageFromList(bytes);
      if (mounted) {
        setState(() {
          _imageWidth = image.width;
          _imageHeight = image.height;
        });
      }
    } catch (e) {}
  }

  String _getAspectString(int width, int height) {
    if (width == height) return '1:1';
    final double ratio = width / height;
    if ((ratio - 1.5).abs() < 0.15) return '3:2';
    if ((ratio - 0.66).abs() < 0.1) return '2:3';
    if ((ratio - 1.77).abs() < 0.15) return '16:9';
    if ((ratio - 0.56).abs() < 0.1) return '9:16';
    if ((ratio - 1.33).abs() < 0.1) return '4:3';
    if ((ratio - 0.75).abs() < 0.1) return '3:4';
    return '$width:$height';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_isDecoded || _decodedImage == null) {
      return Container(
        decoration: BoxDecoration(
          color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
          border: Border.all(
            color:
                SkeletonColorScheme.textSecondaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                SkeletonColorScheme.primaryColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: widget.isSelectModeNotifier,
      builder: (context, isSelectMode, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.selectionNotifier,
          builder: (context, isSelected, child) {
            return AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: SkeletonColorScheme.cardColor,
                      borderRadius:
                          BorderRadius.circular(SkeletonSpacing.borderRadius),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: SkeletonColorScheme.primaryColor
                                .withValues(alpha: 0.35),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(SkeletonSpacing.borderRadius),
                      child: Stack(
                        children: [
                          // 1. 아크릴 블러 배경 (가로세로 비율이 다를 때 여백을 채우는 몽환적 블러)
                          Positioned.fill(
                            child: Image.memory(
                              _decodedImage!,
                              fit: BoxFit.cover,
                              cacheWidth: 80, // 배경용이므로 최소 해상도로 설정해 메모리 절약
                              cacheHeight: 80,
                              gaplessPlayback: true,
                              filterQuality: FilterQuality.low,
                            ),
                          ),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.4), // 차분한 다크 오버레이
                              ),
                            ),
                          ),
                          
                          // 2. 가로세로 컷 원본 이미지 (찌그러짐 없이 contain 배치)
                          Positioned.fill(
                            child: GestureDetector(
                              onTapDown: (_) => _animationController.forward(),
                              onTapUp: (_) => _animationController.reverse(),
                              onTapCancel: () => _animationController.reverse(),
                              onTap: () {
                                if (isSelectMode) {
                                  final newValue = !isSelected;
                                  widget.selectionNotifier.value = newValue;
                                  widget.onSelectionChanged(newValue);
                                } else {
                                  widget.onTap();
                                }
                              },
                              child: Hero(
                                tag: 'thumbnail_${widget.index}', // 크게보기 화면과의 연동을 위한 Hero 태그 추가
                                child: Image.memory(
                                  _decodedImage!,
                                  fit: BoxFit.contain, // 찌그러짐 없이 원본 비율 고수!
                                  width: double.infinity,
                                  height: double.infinity,
                                  cacheWidth: 200,
                                  cacheHeight: 200,
                                  gaplessPlayback: true,
                                  filterQuality: FilterQuality.medium,
                                ),
                              ),
                            ),
                          ),

                          // 3. 은은한 하단 비네팅 (캡슐 칩의 가독성을 위한 점진적 그라디언트)
                          if (_imageWidth != null && _imageHeight != null)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 32,
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.45),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // 4. 가로세로 컷 비율 정보 캡슐 칩 (우하단에 초슬림 캡슐로 표시)
                          if (_imageWidth != null && _imageHeight != null)
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: IgnorePointer(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      width: 0.6,
                                    ),
                                  ),
                                  child: Text(
                                    _getAspectString(_imageWidth!, _imageHeight!),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // 5. 선택된 상태일 때 전체 투명 보라/블루 틴트 오버레이
                          if (isSelected)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: SkeletonColorScheme.primaryColor
                                        .withValues(alpha: 0.12),
                                  ),
                                ),
                              ),
                            ),

                          // 6. 안티앨리어싱 Border 피침 왜곡을 없애기 위한 스택 최상단 보더 오버레이
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SkeletonSpacing.borderRadius),
                                  border: Border.all(
                                    color: isSelected
                                        ? SkeletonColorScheme.primaryColor
                                        : SkeletonColorScheme.textSecondaryColor
                                            .withValues(alpha: 0.08),
                                    width: isSelected ? 2.2 : 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 7. 선택모드일 때 체크박스 표시 (터치 이벤트 무시)
                          if (isSelectMode)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: IgnorePointer(
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? SkeletonColorScheme.primaryColor
                                        : Colors.white.withValues(alpha: 0.8),
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
              },
            );
          },
        );
      },
    );
  }
}
