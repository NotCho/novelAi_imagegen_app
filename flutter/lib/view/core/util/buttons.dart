import 'package:flutter/cupertino.dart';
import 'package:naiapp/view/core/util/utils.dart';

import 'design_system.dart';

class SkeletonPrimaryButton extends StatelessWidget {
  final double height;
  final String text;
  final void Function() onTap;
  final bool enable;
  final TextStyle? style;
  final double width;
  final Color? color;
  final double? borderRadius;

  const SkeletonPrimaryButton({
    super.key,
    this.height = 50,
    this.width = double.infinity,
    required this.text,
    required this.onTap,
    this.enable = true,
    this.style,
    this.color,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        enable ? SkeletonColorScheme.keyColor : SkeletonColorScheme.newG200;

    return SkeletonTap(
      onTap: _onTap,
      child: SkeletonBox(
        borderColor: color ?? backgroundColor,
        borderRadius: borderRadius,
        backgroundColor: color ?? backgroundColor,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: width,
          height: height,
          child: Center(
            child: Text(
              text,
              style: style ??
                  SkeletonTextTheme.body2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: SkeletonColorScheme.newG300,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap() {
    if (enable) onTap();
  }
}
