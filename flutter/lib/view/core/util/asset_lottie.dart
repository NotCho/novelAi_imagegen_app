import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum SkeletonLottieAssetType {
  loading,
}

class SkeletonLottieAsset extends StatelessWidget {
  final SkeletonLottieAssetType type;
  final double? width;
  final double? height;
  const SkeletonLottieAsset({
    super.key,
    required this.type,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SkeletonLottieAssetType.loading:
        return Lottie.asset(
          'assets/lotties/loading_circle.json',
          width: width,
          height: height,
        );
    }
  }
}
