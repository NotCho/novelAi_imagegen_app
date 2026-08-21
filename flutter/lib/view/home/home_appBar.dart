import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:naiapp/view/core/util/app_snackbar.dart';

import '../../application/home/home_page_controller.dart';

class HomeAppBar extends GetView<HomePageController> {
  const HomeAppBar({super.key});

  // 모델 선택 드롭다운 위젯
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedModel = controller.modelConfigController.usingModel.value;
      final usage = controller.imageGenerationController.v5Usage.value;
      final showsV5Quota =
          selectedModel.startsWith('nai-diffusion-5') && usage != null;
      final quotaRemaining =
          ((usage?.remainingPercent ?? 0) / 100).clamp(0.0, 1.0).toDouble();

      return Row(
        children: [
          IconButton(
            onPressed: controller.router.toSetting,
            icon: const Icon(Icons.dehaze),
            color: SkeletonColorScheme.textSecondaryColor,
          ),
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
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
              child: Stack(
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      '$selectedModel:${usage?.remainingPercent}:${usage?.isNegative}',
                    ),
                    isExpanded: true,
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                    dropdownColor: SkeletonColorScheme.surfaceColor,
                    style:
                        const TextStyle(color: SkeletonColorScheme.textColor),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: SkeletonColorScheme.primaryColor),
                    initialValue: selectedModel,
                    selectedItemBuilder: (context) => controller
                        .modelConfigController.modelNames.keys
                        .map(_selectedModelItem)
                        .toList(),
                    items: controller.modelConfigController.modelNames.keys
                        .toList()
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(
                          child: AutoSizeText(
                            controller
                                    .modelConfigController.modelNames[value] ??
                                value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: SkeletonColorScheme.textColor,
                                fontSize: 12),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.modelConfigController.setModel(value);
                      }
                    },
                  ),
                  if (showsV5Quota)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 3,
                      child: IgnorePointer(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ColoredBox(
                                color: SkeletonColorScheme.textColor
                                    .withValues(alpha: 0.08),
                              ),
                            ),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: quotaRemaining,
                              heightFactor: 1,
                              child: ColoredBox(
                                color: _quotaGaugeColor(
                                  usage.remainingPercent,
                                  usage.isNegative,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: SkeletonSpacing.spacing),
          IconButton(
            onPressed: () {
              controller.imageLoadController.clearImageDialog();
              Get.dialog(loadImageDialog(), barrierDismissible: false);
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
                : (controller.imageGenerationController.autoSave.value)
                    ? Colors.greenAccent
                    : SkeletonColorScheme.textSecondaryColor,
          ),
          Obx(
            () => IconButton(
              onPressed: () {
                if (controller.homeImageController.generationHistory.isEmpty) {
                  AppSnackBar.show(
                    '알림',
                    '생성된 이미지가 없습니다.',
                    backgroundColor: Colors.redAccent,
                    textColor: Colors.white,
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
      );
    });
  }

  Widget _selectedModelItem(String model) {
    final name = controller.modelConfigController.modelNames[model] ?? model;
    final usage = controller.imageGenerationController.v5Usage.value;

    if (!model.startsWith('nai-diffusion-5') || usage == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: AutoSizeText(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: SkeletonColorScheme.textColor,
            fontSize: 12,
          ),
        ),
      );
    }

    final label = '$name (${usage.remainingPercent.toStringAsFixed(1)}%)';

    return Align(
      alignment: Alignment.centerLeft,
      child: AutoSizeText(
        label,
        maxLines: 1,
        minFontSize: 9,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: SkeletonColorScheme.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _quotaGaugeColor(double remainingPercent, bool isNegative) {
    if (isNegative || remainingPercent < 30) {
      return Colors.redAccent;
    }
    if (remainingPercent < 60) {
      return Colors.amberAccent;
    }
    return Colors.greenAccent;
  }

  Widget loadImageDialog() {
    return AlertDialog(
      backgroundColor: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        side: BorderSide(
          color: SkeletonColorScheme.textColor.withValues(alpha: 0.08),
          width: 0.8,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: Builder(builder: (context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double dialogWidth = screenWidth > 360 ? 320 : screenWidth * 0.85;
        return SizedBox(
          width: dialogWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '이미지 불러오기',
                style: TextStyle(
                  color: SkeletonColorScheme.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  controller.imageLoadController.cancelImageLoad();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        SkeletonColorScheme.textColor.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          SkeletonColorScheme.textColor.withValues(alpha: 0.08),
                      width: 0.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: SkeletonColorScheme.textSecondaryColor,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      content: Builder(builder: (context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        // Z폴드 커버 화면 등 초소형 가로폭 디바이스 대응
        final bool isNarrow = screenWidth < 340;
        final double dialogWidth = screenWidth > 360 ? 320 : screenWidth * 0.85;

        return Container(
          width: dialogWidth,
          constraints: BoxConstraints(
            maxWidth: 320,
            maxHeight: isNarrow ? 500 : 420,
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isNarrow
                    ? Column(
                        children: [
                          SizedBox(
                            height: 130,
                            width: 130,
                            child: Obx(
                              () => Center(
                                child: (controller.imageLoadController
                                        .loadedImageBytes.value.isNotEmpty)
                                    ? Container(
                                        height: 130,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: SkeletonColorScheme
                                                .primaryColor
                                                .withValues(alpha: 0.3),
                                            width: 1.5,
                                          ),
                                          color: SkeletonColorScheme.cardColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.memory(
                                            fit: BoxFit.cover,
                                            controller.imageLoadController
                                                .loadedImageBytes.value,
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          controller.imageLoadController
                                              .getImageFromGallery();
                                        },
                                        child: Container(
                                          height: 130,
                                          width: 130,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: SkeletonColorScheme
                                                  .textColor
                                                  .withValues(alpha: 0.12),
                                              width: 1,
                                            ),
                                            color: SkeletonColorScheme.textColor
                                                .withValues(alpha: 0.03),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cloud_upload_outlined,
                                                size: 30,
                                                color: SkeletonColorScheme
                                                    .textSecondaryColor,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '이미지 업로드',
                                                style: TextStyle(
                                                  color: SkeletonColorScheme
                                                      .textSecondaryColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildLoadOptions(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 140,
                            width: 140,
                            child: Obx(
                              () => Center(
                                child: (controller.imageLoadController
                                        .loadedImageBytes.value.isNotEmpty)
                                    ? Container(
                                        height: 140,
                                        width: 140,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: SkeletonColorScheme
                                                .primaryColor
                                                .withValues(alpha: 0.3),
                                            width: 1.5,
                                          ),
                                          color: SkeletonColorScheme.cardColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.memory(
                                            fit: BoxFit.cover,
                                            controller.imageLoadController
                                                .loadedImageBytes.value,
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          controller.imageLoadController
                                              .getImageFromGallery();
                                        },
                                        child: Container(
                                          height: 140,
                                          width: 140,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: SkeletonColorScheme
                                                  .textColor
                                                  .withValues(alpha: 0.12),
                                              width: 1,
                                            ),
                                            color: SkeletonColorScheme.textColor
                                                .withValues(alpha: 0.03),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cloud_upload_outlined,
                                                size: 32,
                                                color: SkeletonColorScheme
                                                    .textSecondaryColor,
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                '이미지 업로드',
                                                style: TextStyle(
                                                  color: SkeletonColorScheme
                                                      .textSecondaryColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildLoadOptions(),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: buildDialogButton(
                            '불러오기',
                            color: SkeletonColorScheme.primaryColor,
                            isPrimary: true,
                            onPressed: () {
                              controller.imageLoadController.loadFromImage();
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Obx(
                            () => buildDialogButton(
                              'Vibe',
                              color: SkeletonColorScheme.primaryColor,
                              enabled: controller.modelConfigController
                                      .supportsVibeTransfer &&
                                  !controller.directorToolController.isEnabled,
                              onPressed: () {
                                controller.homeImageController.addVibeImage(
                                  controller.imageLoadController
                                      .loadedImageBytes.value,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Obx(
                            () => buildDialogButton(
                              '레퍼런스',
                              color: SkeletonColorScheme.primaryColor,
                              enabled: controller.modelConfigController
                                      .supportsCharacterReference &&
                                  controller.homeImageController
                                      .vibeParseImageBytes.isEmpty,
                              onPressed: () {
                                controller.directorToolController
                                    .setReferenceImage(
                                  controller.imageLoadController
                                      .loadedImageBytes.value,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxHeight: 50,
                      ),
                      child: _loadImageStatusBuilder(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _loadImageStatusBuilder() {
    return Obx(() {
      final statusText = controller.imageLoadController.loadImageStatus.value;
      final isFailed = statusText.contains("실패");
      final isEmpty = statusText.isEmpty || statusText == "null";

      Color accentColor = isFailed
          ? SkeletonColorScheme.negativeColor
          : SkeletonColorScheme.primaryColor;
      Color bgColor = isFailed
          ? Colors.red.withValues(alpha: 0.05)
          : SkeletonColorScheme.textColor.withValues(alpha: 0.03);
      Color borderColor = isFailed
          ? Colors.red.withValues(alpha: 0.15)
          : SkeletonColorScheme.textColor.withValues(alpha: 0.08);

      if (isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.4),
                    blurRadius: 3,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                statusText,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  color: isFailed
                      ? SkeletonColorScheme.negativeColor
                      : SkeletonColorScheme.textColor.withValues(alpha: 0.7),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget buildDialogButton(
    String title, {
    required Color color,
    required void Function() onPressed,
    bool enabled = true,
    bool isPrimary = false,
    EdgeInsets? padding,
  }) {
    Color btnBgColor = Colors.transparent;
    Color txtColor = SkeletonColorScheme.textColor;

    if (enabled) {
      if (isPrimary) {
        btnBgColor = SkeletonColorScheme.primaryColor;
        txtColor = Colors.white;
      } else {
        btnBgColor = SkeletonColorScheme.primaryColor.withValues(alpha: 0.12);
        txtColor = SkeletonColorScheme.primaryColor;
      }
    } else {
      btnBgColor = SkeletonColorScheme.textColor.withValues(alpha: 0.04);
      txtColor = SkeletonColorScheme.textSecondaryColor.withValues(alpha: 0.5);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: enabled ? onPressed : null,
        child: Ink(
          decoration: BoxDecoration(
            color: btnBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: enabled && !isPrimary
                  ? SkeletonColorScheme.primaryColor.withValues(alpha: 0.25)
                  : Colors.transparent,
              width: 0.8,
            ),
            boxShadow: isPrimary && enabled
                ? [
                    BoxShadow(
                      color: SkeletonColorScheme.primaryColor
                          .withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: txtColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
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
    bool isExifChecked = controller.imageLoadController.isExifChecked.value;

    // 사용 가능 여부
    final bool isEnabled = !hasImage && isExifChecked;

    return GestureDetector(
      onTap: () {
        if (!isEnabled) return;
        controller.imageLoadController.loadImageOptions[title] = !value;
        controller.update();
      },
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4, // 비활성화 상태면 은은한 투명도
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.5),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  activeColor: SkeletonColorScheme.primaryColor,
                  checkColor: Colors.white,
                  value: isExifChecked ? value : false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(
                    color: SkeletonColorScheme.textColor.withValues(
                      alpha: value && isEnabled ? 0.8 : 0.25,
                    ),
                    width: 1,
                  ),
                  onChanged: isEnabled
                      ? (bool? newValue) {
                          controller.imageLoadController
                              .loadImageOptions[title] = newValue!;
                          controller.update();
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isExifChecked
                        ? (value
                            ? SkeletonColorScheme.textColor
                            : SkeletonColorScheme.textSecondaryColor)
                        : Colors.transparent,
                    fontSize: 11.5,
                    fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: -0.3,
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
