import 'package:flutter/material.dart';

import 'design_system.dart';

class SkeletonTap extends StatelessWidget {
  final void Function() onTap;
  final Widget child;

  const SkeletonTap({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  late final double borderRadius;
  late final double borderWidth;
  late final Color borderColor;
  late final Alignment childAlign;

  final bool withShadow;
  late final double shadowRadius;
  late final double shadowBlurRadius;
  late final Color shadowColor;
  final Offset? shadowOffset;

  late final EdgeInsetsGeometry padding;
  late final Color backgroundColor;
  final Widget? child;
  final double? width;
  final double? height;
  final Gradient? backgroundGradient;

  SkeletonBox({
    super.key,
    Alignment? childAlign,
    double? borderRadius,
    double? borderWidth,
    Color? borderColor,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    double? shadowRadius,
    double? shadowBlurRadius,
    Color? shadowColor,
    this.withShadow = false,
    this.shadowOffset,
    this.child,
    this.width,
    this.height,
    this.backgroundGradient,
  }) {
    this.childAlign = childAlign ?? Alignment.center;
    this.borderColor = borderColor ?? SkeletonColorScheme.newG200;
    this.borderWidth = borderWidth ?? 1;
    this.borderRadius = borderRadius ?? 4;
    this.padding =
        padding ?? EdgeInsets.all(SkeletonSpacing.tiny - this.borderWidth);
    this.shadowBlurRadius = shadowBlurRadius ?? 0;
    this.shadowRadius = shadowRadius ?? 0;
    this.shadowColor = shadowColor ?? SkeletonColorScheme.newG100;
    this.backgroundColor = backgroundColor ?? SkeletonColorScheme.newG200;
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(width: borderWidth, color: borderColor),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          spreadRadius: shadowRadius,
          blurRadius: shadowBlurRadius,
          offset: shadowOffset ?? Offset.zero,
        )
      ],
    );

    if (backgroundGradient != null) {
      boxDecoration = boxDecoration.copyWith(gradient: backgroundGradient);
    } else {
      boxDecoration = boxDecoration.copyWith(color: backgroundColor);
    }

    return Container(
      padding: padding,
      width: width,
      height: height,
      alignment: childAlign,
      decoration: boxDecoration,
      child: child,
    );
  }

}
