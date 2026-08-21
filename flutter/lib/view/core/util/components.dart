import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'design_system.dart'; // 디자인 시스템 임포트 경로 확인 필요
import 'wildcard_highlight_controller.dart';

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
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height - mediaQuery.viewInsets.bottom;

    return Dialog(
      backgroundColor: SkeletonColorScheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(SkeletonSpacing.spacing),
        width: mediaQuery.size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: color),
                const SizedBox(width: SkeletonSpacing.smallSpacing),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SkeletonColorScheme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SkeletonSpacing.spacing),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: availableHeight * 0.33,
              ),
              child: WildcardTextField(
                controller: textController,
                highlightColor: color,
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
                  child: const Icon(Icons.recycling),
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
      color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.5),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        side: BorderSide(
          color: SkeletonColorScheme.textColor.withValues(alpha: 0.08),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: SkeletonColorScheme.primaryColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(SkeletonSpacing.borderRadius - 0.8),
                topRight: Radius.circular(SkeletonSpacing.borderRadius - 0.8),
              ),
              border: Border(
                bottom: BorderSide(
                  color:
                      SkeletonColorScheme.textColor.withValues(alpha: 0.08),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: SkeletonColorScheme.primaryColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: SkeletonColorScheme.textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // 카드 내용
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        fillColor: SkeletonColorScheme.cardColor.withValues(alpha: 0.6),
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
            children: [
              Expanded(
                child: Text(
                  config.label,
                  style: const TextStyle(
                    color: SkeletonColorScheme.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 수치 값 뱃지
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isWarningState
                      ? Colors.red.withValues(alpha: 0.08)
                      : SkeletonColorScheme.primaryColor.withValues(alpha: 0.06),
                  borderRadius:
                      BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
                  border: Border.all(
                    color: isWarningState
                        ? Colors.red.withValues(alpha: 0.2)
                        : SkeletonColorScheme.primaryColor.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  config.formatter(currentValue),
                  style: TextStyle(
                    color: isWarningState
                        ? Colors.red
                        : SkeletonColorScheme.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 조작 버튼 (-, +)
              _buildControlButtons(),
            ],
          ),
          const SizedBox(height: 4),
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
                  .withValues(alpha: 0.15),
              valueIndicatorColor: isWarningState
                  ? Colors.red
                  : SkeletonColorScheme.primaryColor,
              valueIndicatorTextStyle:
                  const TextStyle(color: SkeletonColorScheme.textColor),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
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
      height: 26,
      decoration: BoxDecoration(
        color: SkeletonColorScheme.surfaceColor,
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius / 2),
        border: Border.all(
          color: SkeletonColorScheme.textColor.withValues(alpha: 0.08),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 마이너스 버튼
          GestureDetector(
            onTap: () {
              final newValue = (config.value.value.toDouble() - config.step)
                  .clamp(config.min, config.max);
              config.value.value = newValue;
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              child: const Icon(
                Icons.remove,
                color: SkeletonColorScheme.textSecondaryColor,
                size: 13,
              ),
            ),
          ),
          // 중앙 버티컬 구분선
          Container(
            width: 0.8,
            height: 14,
            color: SkeletonColorScheme.textColor.withValues(alpha: 0.08),
          ),
          // 플러스 버튼
          GestureDetector(
            onTap: () {
              final newValue = (config.value.value.toDouble() + config.step)
                  .clamp(config.min, config.max);
              config.value.value = newValue;
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add,
                color: SkeletonColorScheme.textSecondaryColor,
                size: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
