import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/core/global_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/view/core/page.dart';
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
                                        Get.snackbar(
                                          '다운로드 완료',
                                          '${controller.selectedIndexes.length}개 이미지가 저장되었습니다',
                                          backgroundColor: SkeletonColorScheme
                                              .primaryColor
                                              .withValues(alpha: 0.1),
                                          colorText:
                                              SkeletonColorScheme.textColor,
                                          snackPosition: SnackPosition.BOTTOM,
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

          return Stack(
            children: [
              PhotoView(
                imageProvider: MemoryImage(
                  base64Decode(
                      currentItems[controller.currentIndex.value].imagePath),
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
              // 상단 컨트롤 바
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(SkeletonSpacing.borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius:
                            BorderRadius.circular(SkeletonSpacing.borderRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${controller.currentIndex.value + 1} / ${currentItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    controller.global.saveImageWithMetadata(
                                        base64Decode(currentItems[
                                                controller.currentIndex.value]
                                            .imagePath));
                                  },
                                  borderRadius: BorderRadius.circular(
                                      SkeletonSpacing.borderRadius / 2),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.download,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  borderRadius: BorderRadius.circular(
                                      SkeletonSpacing.borderRadius / 2),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
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
              // 왼쪽 네비게이션 버튼 (전체 높이)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    if (controller.currentIndex.value > 0) {
                      controller.currentIndex.value--;
                    }
                  },
                  child: Container(
                    width: 80,
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(
                              SkeletonSpacing.borderRadius / 2),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: controller.currentIndex.value > 0
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 오른쪽 네비게이션 버튼 (전체 높이)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    if (controller.currentIndex.value <
                        currentItems.length - 1) {
                      controller.currentIndex.value++;
                    }
                  },
                  child: Container(
                    width: 80,
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(
                              SkeletonSpacing.borderRadius / 2),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: controller.currentIndex.value <
                                  currentItems.length - 1
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              )
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

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(ImageGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 이미지 데이터가 바뀌면 새로 로드
    if (oldWidget.imageData != widget.imageData) {
      _isDecoded = false;
      _decodedImage = null;
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

  void _loadImage() {
    try {
      _decodedImage =
          ImageCacheManager.instance.getImageBytes(widget.imageData);

      // _decodedImage = base64Decode(widget.imageData);
      _isDecoded = true;
      if (mounted) setState(() {});
    } catch (e) {
      print('이미지 로딩 실패: $e');
    }
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
                      border: Border.all(
                        color: isSelected
                            ? SkeletonColorScheme.primaryColor
                            : SkeletonColorScheme.textSecondaryColor
                                .withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: SkeletonColorScheme.primaryColor
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
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
                          // 메인 이미지와 GestureDetector
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
                              child: Image.memory(
                                _decodedImage!,
                                fit: BoxFit.cover,
                                // 이미지 늘어남 방지, 더 짧은 쪽에 맞춤
                                width: double.infinity,
                                height: double.infinity,
                                cacheWidth: 200,
                                cacheHeight: 200,
                                gaplessPlayback: true,
                                filterQuality: FilterQuality.low,
                              ),
                            ),
                          ),
                          // 선택된 상태일 때 오버레이 (터치 이벤트 무시)
                          if (isSelected)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: SkeletonColorScheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                        SkeletonSpacing.borderRadius),
                                  ),
                                ),
                              ),
                            ),
                          // 선택모드일 때 체크박스 표시 (터치 이벤트 무시)
                          if (isSelectMode)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IgnorePointer(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(
                                        SkeletonSpacing.borderRadius / 2),
                                  ),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? SkeletonColorScheme.primaryColor
                                        : Colors.white.withValues(alpha: 0.8),
                                    size: 20,
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
