import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import 'design_system.dart';

enum SkeletonPictureAssetType {
  appBarCross,
  appBarCrossWhite,
  appBarCrossDark,
  appBarArrowRight,
  appBarBellDefault,
  appBarBellOn,
  appBarSettings,
  appBarSearch,
  appBarSearchBlack,
  appBarSettingsBlack,
  appBarBellDefaultBlack,
  appBarBellOnBlack,
  kakao,
  google,
  apple,
}

class SkeletonPictureAsset extends StatelessWidget {
  final SkeletonPictureAssetType type;

  const SkeletonPictureAsset({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SkeletonPictureAssetType.appBarCross:
        return SvgPicture.asset('assets/icons/icon-close.svg');
      case SkeletonPictureAssetType.appBarCrossWhite:
        return SvgPicture.asset(
          'assets/icons/icon-close.svg',
        );
      case SkeletonPictureAssetType.appBarCrossDark:
        return SvgPicture.asset(
          'assets/icons/icon-close.svg',
          color: SkeletonColorScheme.newG800,
        );
      case SkeletonPictureAssetType.appBarArrowRight:
        return SvgPicture.asset('assets/icons/arrow-right.svg');
      case SkeletonPictureAssetType.appBarBellDefault:
        return SvgPicture.asset('assets/icons/bell_default.svg');
      case SkeletonPictureAssetType.appBarBellOn:
        return SvgPicture.asset('assets/icons/bell_on.svg');
      case SkeletonPictureAssetType.appBarSettings:
        return SvgPicture.asset('assets/icons/solar_settings-linear.svg');
      case SkeletonPictureAssetType.appBarSearch:
        return SvgPicture.asset('assets/icons/icon-search.svg');
      case SkeletonPictureAssetType.appBarSearchBlack:
        return SvgPicture.asset('assets/icons/icon-search-black.svg');
      case SkeletonPictureAssetType.appBarSettingsBlack:
        return SvgPicture.asset(
          'assets/icons/solar_settings-linear.svg',
          color: SkeletonColorScheme.newG900,
        );
      case SkeletonPictureAssetType.appBarBellDefaultBlack:
        return SvgPicture.asset(
          'assets/icons/bell_default.svg',
          color: SkeletonColorScheme.newG900,
        );
      case SkeletonPictureAssetType.appBarBellOnBlack:
        return SvgPicture.asset(
          'assets/icons/bell_on.svg',
          color: SkeletonColorScheme.newG900,
        );
      case SkeletonPictureAssetType.kakao:
        return SvgPicture.asset(
          'assets/images/logos/kakao.svg',
          color: SkeletonColorScheme.kakaoYellow,
        );
      case SkeletonPictureAssetType.google:
        return SvgPicture.asset('assets/images/logos/google.svg');
      case SkeletonPictureAssetType.apple:
        return SvgPicture.asset('assets/images/logos/apple.svg');
    }
  }
}
