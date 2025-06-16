import 'package:flutter/material.dart';
import 'package:naiapp/view/core/util/utils.dart';

import 'design_system.dart';

class SkeletonIconTextButton extends StatelessWidget {
  final double iconSize;
  final Widget icon;
  final String text;
  final void Function() onTap;
  const SkeletonIconTextButton({
    super.key,
    this.iconSize = 32,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(blurRadius: 14, color: SkeletonColorScheme.newG200)
            ],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SkeletonColorScheme.newG200, width: 1),
            color: SkeletonColorScheme.newG100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: icon,
            ),
            Text(
              text,
              style: SkeletonTextTheme.body2.copyWith(
                color: SkeletonColorScheme.title,
              ),
            ),
            SizedBox(width: iconSize),
          ],
        ),
      ),
    );
  }
}
