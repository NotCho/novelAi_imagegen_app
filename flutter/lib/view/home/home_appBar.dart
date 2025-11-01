import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/view/core/util/design_system.dart';

import '../../application/home/home_page_controller.dart';

class HomeAppBar extends GetView<HomePageController> {
  HomeAppBar({super.key});

  // 모델 선택 드롭다운 위젯
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          IconButton(
            onPressed: controller.router.toSetting,
            icon: const Icon(Icons.dehaze),
            color: SkeletonColorScheme.textSecondaryColor,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.7),
                borderRadius:
                    BorderRadius.circular(SkeletonSpacing.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: '모델',
                  labelStyle: const TextStyle(
                    color: SkeletonColorScheme.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  prefixIcon: const Icon(Icons.auto_awesome,
                      color: SkeletonColorScheme.primaryColor, size: 18),
                ),
                dropdownColor: SkeletonColorScheme.surfaceColor,
                style: const TextStyle(color: SkeletonColorScheme.textColor),
                icon: const Icon(Icons.arrow_drop_down,
                    color: SkeletonColorScheme.primaryColor),
                value: controller.usingModel.value,
                items: controller.modelNames.keys.toList().map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: SizedBox(
                      child: AutoSizeText(
                        controller.modelNames[value] ?? value,
                        maxLines: 1,
                        style: const TextStyle(
                            color: SkeletonColorScheme.textColor, fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.usingModel.value = value;
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: SkeletonSpacing.spacing),
          IconButton(
            onPressed: () {
              controller.imageLoadController.clearImageDialog();
              Get.dialog(LoadImageDialog(), barrierDismissible: false);
            },
            icon: const Icon(Icons.add_a_photo),
            color: SkeletonColorScheme.textSecondaryColor,
          ),
          IconButton(
            onPressed: () {
              controller.expandHistory.value = !controller.expandHistory.value;
            },
            icon: const Icon(Icons.photo_library),
            color: (controller.expandHistory.value)
                ? SkeletonColorScheme.primaryColor
                : (controller.autoSave.value)
                    ? Colors.greenAccent
                    : SkeletonColorScheme.textSecondaryColor,
          ),
          Obx(
            () => IconButton(
              onPressed: () {
                if (controller.homeImageController.generationHistory.isEmpty) {
                  Get.snackbar(
                    '알림',
                    '생성된 이미지가 없습니다.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                  return;
                }
                controller.homeImageController.saveImage();
              },
              icon: const Icon(Icons.download_rounded),
              color: controller.homeImageController.generationHistory.isEmpty
                  ? Colors.redAccent
                  : Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget LoadImageDialog() {
    return AlertDialog(
      backgroundColor: SkeletonColorScheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
      ),
      // 다이얼로그 크기 제한 추가! ㅋㅋㅋ
      contentPadding: EdgeInsets.all(16),
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      // 화면 여백

      title: Container(
        width: 320, // 고정 너비 설정
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '이미지 불러오기',
              style: TextStyle(
                  color: SkeletonColorScheme.textColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 18),
            ),
            SizedBox(
              width: 35,
              height: 35,
              child: IconButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SkeletonColorScheme.negativeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(SkeletonSpacing.borderRadius),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  ),
                  onPressed: () async {
                    controller.imageLoadController.cancelImageLoad();
                  },
                  icon: Icon(
                    Icons.close,
                    color: SkeletonColorScheme.textColor,
                    size: 25,
                  )),
            ),
          ],
        ),
      ),

      content: Container(
        width: 320, // 고정 너비 설정
        constraints: BoxConstraints(
          maxWidth: 320, // 최대 너비 제한
          maxHeight: 400, // 최대 높이도 제한 (선택사항)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: Obx(
                    () => Center(
                      child: (controller.imageLoadController.loadedImageBytes
                              .value.isNotEmpty)
                          ? Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: SkeletonColorScheme.primaryColor,
                                  width: 2,
                                ),
                                color:
                                    SkeletonColorScheme.surfaceColor.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(
                                    SkeletonSpacing.borderRadius),
                              ),
                              child: Image.memory(
                                  fit: BoxFit.contain,
                                  controller.imageLoadController
                                      .loadedImageBytes.value),
                            )
                          : GestureDetector(
                              onTap: () {
                                controller.imageLoadController
                                    .getImageFromGallery();
                              },
                              child: Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        SkeletonColorScheme.textSecondaryColor,
                                    width: 2,
                                  ),
                                  color: SkeletonColorScheme.surfaceColor
                                      .withValues(
                                    alpha: 0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      SkeletonSpacing.borderRadius),
                                ),
                                child: const Center(
                                  child: Icon(Icons.upload,
                                      size: 50,
                                      color: SkeletonColorScheme
                                          .textSecondaryColor),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: SkeletonSpacing.spacing),
                Expanded(
                  // 남은 공간 차지하도록
                  child: _buildLoadOptions(),
                ),
              ],
            ),
            const SizedBox(height: SkeletonSpacing.spacing),

            // 버튼들과 상태 텍스트 영역
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch, // 전체 너비 사용
              children: [
                Row(
                  children: [
                    Expanded(
                      child: buildDialogButton(
                        '불러오기',
                        color: SkeletonColorScheme.primaryColor,
                        onPressed: () {
                          controller.imageLoadController.loadFromImage();
                        },
                      ),
                    ),
                    const SizedBox(width: SkeletonSpacing.spacing),
                    Expanded(
                      child: buildDialogButton(
                        'Vibe',
                        color: SkeletonColorScheme.primaryColor,
                        onPressed: () {
                          controller.addVibeImage(
                            controller
                                .imageLoadController.loadedImageBytes.value,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: SkeletonSpacing.spacing),
                    Expanded(
                      child: buildDialogButton(
                        '레퍼런스',
                        color: SkeletonColorScheme.primaryColor,
                        onPressed: () {
                          controller.addDirectorReferenceImage(
                            controller
                                .imageLoadController.loadedImageBytes.value,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 상태 텍스트 영역 - 크기 제한!
                Container(
                  width: double.infinity, // 부모 너비에 맞춤
                  constraints: BoxConstraints(
                    maxHeight: 60, // 최대 높이 제한
                  ),
                  child: _loadImageStatusBuilder(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadImageStatusBuilder() {
    Color statusColor = SkeletonColorScheme.textSecondaryColor;
    if (controller.imageLoadController.loadImageStatus.value.contains("실패")) {
      statusColor = SkeletonColorScheme.negativeColor;
    }
    return Obx(
      () => Container(
        width: double.infinity, // 부모 너비에 맞춤
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: SkeletonColorScheme.surfaceColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: SkeletonColorScheme.textSecondaryColor.withOpacity(0.2),
          ),
        ),
        child: Text(
          controller.imageLoadController.loadImageStatus.value,
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          style: TextStyle(
            color: statusColor,
            fontSize: 10,
            height: 1.2, // 줄 간격 조정
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

// 버튼도 수정 (Expanded 대응)
  Widget buildDialogButton(String title,
      {required Color color,
      required void Function() onPressed,
      EdgeInsets? padding}) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
          onTap: onPressed,
          child: Padding(
            padding: padding ??
                EdgeInsets.symmetric(
                    horizontal: SkeletonSpacing.spacing,
                    vertical: SkeletonSpacing.smallSpacing),
            child: Center(
              // 중앙 정렬 추가
              child: Text(
                title,
                style: TextStyle(
                  color: SkeletonColorScheme.textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadOptions() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.imageLoadController.loadImageOptions.keys
            .map((String key) {
          return _buildCheckBox(
              key, controller.imageLoadController.loadImageOptions[key]!);
        }).toList(),
      ),
    );
  }

  Widget _buildCheckBox(String title, bool value) {
    bool hasImage =
        controller.imageLoadController.loadedImageBytes.value.isEmpty;
    return Row(
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: Visibility(
            visible: controller.imageLoadController.isExifChecked.value,
            child: Checkbox(
              activeColor: (hasImage)
                  ? SkeletonColorScheme.textSecondaryColor
                  : SkeletonColorScheme.primaryColor,
              value: value,
              onChanged: (bool? newValue) {
                if (hasImage) return;

                controller.imageLoadController.loadImageOptions[title] =
                    newValue!;
                controller.update();
              },
            ),
          ),
        ),
        Text(title,
            style: TextStyle(
              color: (controller.imageLoadController.isExifChecked.value)
                  ? SkeletonColorScheme.textSecondaryColor
                  : Colors.transparent,
              fontSize: 10,
            )),
      ],
    );
  }
}
