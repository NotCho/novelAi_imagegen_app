import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'design_system.dart'; // 디자인 시스템 임포트 경로 확인 필요

class DesignDialog extends StatelessWidget {
  final String textTitle;
  final String textContent;
  final String? confirmText;
  final String? cancelText;
  final void Function()? onConfirm;
  final void Function()? onCancel;
  final Widget? customContent;

  const DesignDialog({
    super.key,
    required this.textTitle,
    required this.textContent,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            textTitle,
            style: SkeletonTextTheme.newBody18Bold,
          ),

          const SizedBox(height: 16),

          // 내용
          customContent ??
              Text(
                textContent,
                style: SkeletonTextTheme.newBody14.copyWith(
                  color: SkeletonColorScheme.newG600,
                ),
              ),

          const SizedBox(height: 24),

          // 버튼 섹션
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (cancelText != null)
                TextButton(
                  onPressed: onCancel ?? () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: SkeletonColorScheme.newG100,
                  ),
                  child: Text(
                    cancelText!,
                    style: SkeletonTextTheme.newBody14Bold.copyWith(
                      color: SkeletonColorScheme.newG600,
                    ),
                  ),
                ),
              if (cancelText != null) const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onConfirm ?? () => Get.back(),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: SkeletonColorScheme.primary,
                ),
                child: Text(
                  confirmText ?? '확인',
                  style: SkeletonTextTheme.newBody14Bold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 사용 예시:
class DialogHelper {
  static void showDesignDialog({
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    Function()? onConfirm,
    Function()? onCancel,
  }) {
    Get.dialog(
      DesignDialog(
        textTitle: title,
        textContent: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
      barrierDismissible: false,
    );
  }
}

class PromptDialog extends StatelessWidget {
  final TextEditingController textController;
  final String title;
  final Color color;

  const PromptDialog({
    super.key,
    required this.textController,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SkeletonColorScheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(SkeletonSpacing.spacing),
        width: Get.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: color),
                const SizedBox(width: SkeletonSpacing.smallSpacing),
                Text(
                  title,
                  style: const TextStyle(
                    color: SkeletonColorScheme.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SkeletonSpacing.spacing),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: Get.height * 0.33,
              ),
              child: TextField(
                controller: textController,
                style: const TextStyle(color: SkeletonColorScheme.textColor),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: '프롬프트를 입력하세요...',
                  hintStyle: const TextStyle(
                      color: SkeletonColorScheme.textSecondaryColor),
                  filled: true,
                  fillColor:
                      SkeletonColorScheme.surfaceColor.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                    borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                    borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                    borderSide: BorderSide(color: color),
                  ),
                ),
              ),
            ),
            const SizedBox(height: SkeletonSpacing.spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    String result = await Get.find<HomePageController>()
                        .router
                        .toParser(textController.text);
                    if (result.isNotEmpty) {
                      textController.text = result;
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.withValues(alpha: 0.1),
                    foregroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          SkeletonSpacing.borderRadius / 2),
                    ),
                  ),
                  child: Icon(Icons.recycling),
                ),
                const SizedBox(width: SkeletonSpacing.smallSpacing),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: SkeletonColorScheme.textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          SkeletonSpacing.borderRadius / 2),
                    ),
                  ),
                  child: const Text('닫기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const SettingsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _buildSettingsCard(title: title, icon: icon, child: child);
  }

  // 설정 카드 위젯
  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.7),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(SkeletonSpacing.borderRadius),
                topRight: Radius.circular(SkeletonSpacing.borderRadius),
              ),
              border: Border(
                bottom: BorderSide(
                  color:
                      SkeletonColorScheme.primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: SkeletonColorScheme.primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: SkeletonColorScheme.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 카드 내용
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }
}

class DropDownBuild extends StatelessWidget {
  final String value;
  final List<String> items;
  final String labelText;
  final Function(String?) onChanged;

  const DropDownBuild({
    super.key,
    required this.value,
    required this.items,
    required this.labelText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDropdownField(
        labelText: labelText, items: items, onChanged: onChanged, value: value);
  }

  // 드롭다운 필드 위젯
  Widget _buildDropdownField({
    required String labelText,
    required List<String> items,
    required Function(String?) onChanged,
    required String? value,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle:
            const TextStyle(color: SkeletonColorScheme.textSecondaryColor),
        filled: true,
        fillColor: SkeletonColorScheme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
          borderSide: const BorderSide(color: SkeletonColorScheme.surfaceColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dropdownColor: SkeletonColorScheme.surfaceColor,
      style: const TextStyle(color: SkeletonColorScheme.textColor),
      initialValue: value,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value,
              style: const TextStyle(color: SkeletonColorScheme.textColor)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

// 슬라이더 설정 클래스
class SliderConfig {
  final String label;
  final RxNum value;
  final double min;
  final double max;
  final int divisions;
  final double step;
  final String Function(double) formatter;
  final bool Function(double)? isWarning;

  SliderConfig({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    this.step = 1.0,
    required this.formatter,
    this.isWarning,
  });
}

class OptimizedSlider extends StatelessWidget {
  final SliderConfig config;

  const OptimizedSlider({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentValue = config.value.value.toDouble();
      final isWarningState = config.isWarning?.call(currentValue) ?? false;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                config.label,
                style: const TextStyle(
                  color: SkeletonColorScheme.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isWarningState
                      ? Colors.red.withValues(alpha: 0.2)
                      : SkeletonColorScheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
                ),
                child: Text(
                  config.formatter(currentValue),
                  style: TextStyle(
                    color: isWarningState
                        ? Colors.red
                        : SkeletonColorScheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildControlButtons(),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: isWarningState
                  ? Colors.red
                  : SkeletonColorScheme.primaryColor,
              inactiveTrackColor: SkeletonColorScheme.surfaceColor,
              thumbColor: isWarningState
                  ? Colors.red
                  : SkeletonColorScheme.primaryColor,
              overlayColor: (isWarningState
                      ? Colors.red
                      : SkeletonColorScheme.primaryColor)
                  .withValues(alpha: 0.2),
              valueIndicatorColor: isWarningState
                  ? Colors.red
                  : SkeletonColorScheme.primaryColor,
              valueIndicatorTextStyle:
                  const TextStyle(color: SkeletonColorScheme.textColor),
            ),
            child: Slider(
              value: currentValue,
              min: config.min,
              max: config.max,
              divisions: config.divisions,
              label: config.formatter(currentValue),
              onChanged: (value) {
                config.value.value = num.tryParse(value.toStringAsFixed(2))!;
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildControlButtons() {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              final newValue = (config.value.value.toDouble() - config.step)
                  .clamp(config.min, config.max);
              config.value.value = newValue;
            },
            icon: const Icon(Icons.remove,
                color: SkeletonColorScheme.textSecondaryColor, size: 12),
          ),
          IconButton(
            onPressed: () {
              final newValue = (config.value.value.toDouble() + config.step)
                  .clamp(config.min, config.max);
              config.value.value = newValue;
            },
            icon: const Icon(Icons.add,
                color: SkeletonColorScheme.textSecondaryColor, size: 12),
          ),
        ],
      ),
    );
  }
}
