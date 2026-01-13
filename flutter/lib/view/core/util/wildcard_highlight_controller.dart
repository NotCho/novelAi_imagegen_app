import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/wildcard/wildcard_controller.dart';
import 'design_system.dart';

/// 와일드카드 패턴(__name__)을 하이라이트하는 커스텀 TextEditingController
/// 존재하고 활성화된 와일드카드는 색상으로, 없거나 비활성화된 것은 회색으로 표시
class WildcardHighlightController extends TextEditingController {
  /// 와일드카드 패턴: __영문숫자언더스코어__
  static final RegExp wildcardPattern = RegExp(r'__[a-zA-Z0-9_]+__');

  /// 활성화된 와일드카드 하이라이트 색상
  final Color activeColor;
  
  /// 비활성화/없는 와일드카드 색상
  final Color inactiveColor;
  
  /// 기본 텍스트 스타일
  final TextStyle? baseStyle;

  WildcardHighlightController({
    String? text,
    this.activeColor = SkeletonColorScheme.primaryColor,
    this.inactiveColor = SkeletonColorScheme.textSecondaryColor,
    this.baseStyle,
  }) : super(text: text);

  /// 와일드카드가 존재하고 활성화되어 있는지 확인
  bool _isWildcardActive(String wildcardName) {
    try {
      final controller = Get.find<WildcardController>();
      final wildcard = controller.getWildcard(wildcardName);
      return wildcard != null && wildcard.isEnabled;
    } catch (e) {
      // WildcardController가 아직 초기화되지 않은 경우
      return false;
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final effectiveStyle = style ?? baseStyle ?? const TextStyle();
    final List<InlineSpan> children = [];

    // 텍스트가 비어있으면 빈 TextSpan 반환
    if (text.isEmpty) {
      return TextSpan(style: effectiveStyle, children: children);
    }

    // 패턴 매칭으로 분리
    text.splitMapJoin(
      wildcardPattern,
      onMatch: (Match match) {
        final fullMatch = match.group(0)!;
        
        // __name__ 에서 name만 추출 (앞뒤 2글자씩 제거)
        String wildcardName = '';
        if (fullMatch.length > 4) {
          wildcardName = fullMatch.substring(2, fullMatch.length - 2);
        }
        
        final isActive = _isWildcardActive(wildcardName);
        
        final color = isActive ? activeColor : inactiveColor;
        
        children.add(TextSpan(
          text: fullMatch,
          style: effectiveStyle.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            backgroundColor: color.withValues(alpha: 0.15),
            decoration: isActive ? null : TextDecoration.lineThrough,
            decorationColor: inactiveColor.withValues(alpha: 0.5),
          ),
        ));
        return '';
      },
      onNonMatch: (String nonMatch) {
        // 일반 텍스트 - 기본 스타일
        if (nonMatch.isNotEmpty) {
          children.add(TextSpan(text: nonMatch, style: effectiveStyle));
        }
        return '';
      },
    );

    return TextSpan(style: effectiveStyle, children: children);
  }
}

/// 일반 TextField를 와일드카드 하이라이팅이 적용된 TextField로 래핑하는 위젯
class WildcardTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextStyle? style;
  final InputDecoration? decoration;
  final int? maxLines;
  final bool enabled;
  final Color highlightColor;

  const WildcardTextField({
    super.key,
    required this.controller,
    this.style,
    this.decoration,
    this.maxLines,
    this.enabled = true,
    this.highlightColor = SkeletonColorScheme.primaryColor,
  });

  @override
  State<WildcardTextField> createState() => _WildcardTextFieldState();
}

class _WildcardTextFieldState extends State<WildcardTextField> {
  late WildcardHighlightController _highlightController;

  @override
  void initState() {
    super.initState();
    _highlightController = WildcardHighlightController(
      text: widget.controller.text,
      activeColor: widget.highlightColor,
    );

    // 양방향 동기화
    widget.controller.addListener(_syncFromOriginal);
    _highlightController.addListener(_syncToOriginal);
  }

  void _syncFromOriginal() {
    if (_highlightController.text != widget.controller.text) {
      _highlightController.text = widget.controller.text;
    }
  }

  void _syncToOriginal() {
    if (widget.controller.text != _highlightController.text) {
      widget.controller.text = _highlightController.text;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromOriginal);
    _highlightController.removeListener(_syncToOriginal);
    _highlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _highlightController,
      style: widget.style,
      decoration: widget.decoration,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
    );
  }
}
