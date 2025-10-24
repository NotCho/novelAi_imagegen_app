import 'package:flutter/cupertino.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:get/get.dart';
import 'dart:typed_data';

import 'package:naiapp/view/core/util/design_system.dart';

import '../home/image_cache_manager.dart';

class ImagePageController extends SkeletonController {
  HomePageController homePageController = Get.find<HomePageController>();

  RxInt currentIndex = 0.obs;

  RxBool keepScrollPosition = true.obs; // 스크롤 위치 유지 여부

  // 기존 GetX 방식은 상단 UI에서만 사용
  RxBool selectMode = false.obs;
  RxBool searchMode = false.obs;
  RxList<int> selectedIndexes = <int>[].obs;
  double previousOffset = 0.0;

  // ValueNotifier로 개별 상태 관리
  late ValueNotifier<bool> selectModeNotifier;
  List<ValueNotifier<bool>> itemSelectionNotifiers = [];

  // 전역 캐시 매니저 사용
  ImageCacheManager get cacheManager => ImageCacheManager.instance;

  // 현재까지 캐싱된 인덱스 추적
  int cachedUpToIndex = -1;

  // 이전 이미지 개수 추적 (새 이미지 감지용)
  int previousImageCount = 0;

  // GridView 스크롤 컨트롤러
  final ScrollController scrollController = ScrollController();

  final searchController = TextEditingController();

  Future<void> saveMultipleImages() async {
    List<Uint8List> imageBytes = [];
    for (int index in selectedIndexes) {
      // 캐시에서 가져오기
      final imageData = homePageController
          .homeImageController.generationHistory[index].imagePath;
      Uint8List imageByte = cacheManager.getImageBytes(imageData);
      imageBytes.add(imageByte);
    }
    await global.saveMultipleImages(imageBytes);
  }

  // ValueNotifier 배열 크기 조정 (새 이미지 추가 시 안전하게 처리)
  void _ensureNotifierArraySize(int requiredSize) {
    while (itemSelectionNotifiers.length < requiredSize) {
      itemSelectionNotifiers.add(ValueNotifier<bool>(false));
    }
  }

  // 기존 이미지들 미리 캐싱
  Future<void> _preloadExistingImages() async {
    final history = homePageController.homeImageController.generationHistory;

    // ValueNotifier 배열 크기 먼저 조정
    _ensureNotifierArraySize(history.length);

    // base64 데이터 리스트 만들기
    List<String> base64DataList =
        history.map((item) => item.imagePath).toList();

    // 전역 캐시 매니저로 미리 로딩
    await cacheManager.preloadImages(base64DataList);
    cachedUpToIndex = history.length - 1;
  }

  // 새로운 이미지가 추가됐는지 체크하고 필요시 캐싱
  void checkAndCacheNewImages() {
    final history = homePageController.homeImageController.generationHistory;
    final currentImageCount = history.length;

    // 먼저 ValueNotifier 배열 크기 조정 (중요!)
    _ensureNotifierArraySize(currentImageCount);

    // 새 이미지가 추가되었는지 감지
    if (currentImageCount > previousImageCount) {
      previousImageCount = currentImageCount;
    }

    if (currentImageCount > cachedUpToIndex + 1) {
      // 새로운 이미지들만 캐싱
      List<String> newImages = [];
      for (int i = cachedUpToIndex + 1; i < currentImageCount; i++) {
        newImages.add(history[i].imagePath);
      }

      // 새 이미지들 캐싱 (비동기로)
      cacheManager.preloadImages(newImages);
      cachedUpToIndex = currentImageCount - 1;
    }
  }

  void toggleSelectMode() {
    selectMode.value = !selectMode.value;

    if (selectMode.value) {
      if (homePageController
          .autoGenerationController.autoGenerateEnabled.value) {
        homePageController.autoGenerationController.autoGenerateEnabled.value =
            false; // 선택 모드 해제 시 자동 생성 비활성화
        Get.snackbar("선택모드 활성", "성능을 위해 이미지 자동 생성이 비활성화됩니다.",
            backgroundColor: SkeletonColorScheme.newGreenColor,
            colorText: SkeletonColorScheme.textColor,
            snackPosition: SnackPosition.BOTTOM);
      }
    }
    if (!selectMode.value) {
      clearSelection();
    }
  }

  void clearSelection() {
    selectedIndexes.clear();
    // 모든 아이템의 선택 상태 해제 (안전하게 처리)
    for (int i = 0; i < itemSelectionNotifiers.length; i++) {
      itemSelectionNotifiers[i].value = false;
    }
  }

  // 전체 선택/해제 개선된 버전
  void toggleSelectAll() {
    final historyLength =
        homePageController.homeImageController.generationHistory.length;

    // ValueNotifier 배열 크기 먼저 확인
    _ensureNotifierArraySize(historyLength);

    if (selectedIndexes.length == historyLength) {
      // 전체 해제
      selectedIndexes.clear();
      for (int i = 0; i < itemSelectionNotifiers.length; i++) {
        itemSelectionNotifiers[i].value = false;
      }
    } else {
      // 전체 선택
      selectedIndexes.clear();
      selectedIndexes.addAll(List.generate(historyLength, (index) => index));
      for (int i = 0; i < historyLength; i++) {
        itemSelectionNotifiers[i].value = true;
      }
    }
  }

  // 개별 아이템 선택 상태 변경 (더 안전한 방식)
  void toggleItemSelection(int index, bool isSelected) {
    // ValueNotifier 배열 크기 확인
    _ensureNotifierArraySize(index + 1);

    // 선택 상태 업데이트
    itemSelectionNotifiers[index].value = isSelected;

    if (isSelected) {
      if (!selectedIndexes.contains(index)) {
        selectedIndexes.add(index);
      }
    } else {
      selectedIndexes.remove(index);
    }
  }

  @override
  Future<bool> initLoading() async {
    selectModeNotifier = ValueNotifier<bool>(false);

    // selectMode 변경 시 selectModeNotifier도 동기화
    ever(selectMode, (bool value) {
      selectModeNotifier.value = value;
    });
    scrollController.addListener(
      toggleKeepScrollPosition,
    );

    // 기존 이미지들 미리 캐싱 (전역 캐시 사용!)
    await _preloadExistingImages();

    // 현재 이미지 개수 초기화
    previousImageCount =
        homePageController.homeImageController.generationHistory.length;

    scrollToBottom();
    keepScrollPosition.value = true; // 기본적으로 스크롤 위치 유지
    return true;
  }

  void toggleKeepScrollPosition() {
    if (scrollController.offset < previousOffset) {
      previousOffset = scrollController.offset;
      keepScrollPosition.value = true;
    } else {
      previousOffset = scrollController.offset;
    }
    if (scrollController.offset >= scrollController.position.maxScrollExtent) {
      keepScrollPosition.value = false; // 스크롤이 맨 아래면 위치 유지 안함
    }
  }

  void onScrollIconTap() {
    keepScrollPosition.value = !keepScrollPosition.value;
    scrollCheck();
  }

  void scrollCheck() {
    if (scrollController.hasClients) {
      if (!keepScrollPosition.value) {
        scrollToBottom();
      } else {}
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: SkeletonSpacing.animationDuration, curve: Curves.easeInOut);
    });
  }

  @override
  void onClose() {
    selectModeNotifier.dispose();
    scrollController.dispose(); // 스크롤 컨트롤러 정리
    // ValueNotifier들 안전하게 정리
    for (var notifier in itemSelectionNotifiers) {
      notifier.dispose();
    }
    itemSelectionNotifiers.clear();
    // 전역 캐시는 정리하지 않음! (계속 유지)
    super.onClose();
  }

  void deleteSelectedImages(List<GenerationHistoryItem> items) {
    if (selectedIndexes.isEmpty) {
      Get.snackbar("선택된 이미지 없음", "삭제할 이미지를 선택해주세요.",
          backgroundColor: SkeletonColorScheme.negativeColor,
          colorText: SkeletonColorScheme.textColor,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // 선택된 이미지 삭제
    List<GenerationHistoryItem> selectedItems = [];
    for (int index in selectedIndexes) {
      selectedItems.add(items[index]);
      items.removeAt(index);
    }
    homePageController.homeImageController.deleteImages(selectedItems);

    Get.snackbar("이미지 삭제 완료", "${selectedIndexes.length}개의 이미지가 삭제되었습니다.",
        backgroundColor: SkeletonColorScheme.newGreenColor,
        colorText: SkeletonColorScheme.textColor,
        snackPosition: SnackPosition.BOTTOM);
    // 선택 모드 해제
    toggleSelectMode();
  }
}
