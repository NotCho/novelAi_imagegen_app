import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:naiapp/view/core/util/asset_picture.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:naiapp/view/core/util/utils.dart';

import '../../application/core/bottom_nav_bar.dart';
import '../../application/core/global_controller.dart';
import 'bottom_nav_bar.dart';
import 'loading.dart';

class SkeletonPage extends StatelessWidget {
  final bool isMain;
  final bool isLoading;
  final Widget page;
  final Widget fallback;
  final bool? Function()? callback;

  const SkeletonPage(
      {super.key,
      required this.isLoading,
      required this.page,
      this.isMain = false,
      this.fallback = const SkeletonLoadingOverlayScaffold(),
      this.callback});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Stack(
          children: [
            isLoading ? const SizedBox() : page,
            Visibility(
              visible: isLoading,
              child: fallback,
            ),
          ],
        ),
        onWillPop: () async {
          BottomNavBarController bottomNavBarController =
              Get.find<BottomNavBarController>();
          if (callback?.call() == false) {
            return false;
          }
          if (isMain) {
            if (bottomNavBarController.currentIndex == 0) {
              return true;
            } else {
              bottomNavBarController.currentIndex = 0;
              return false;
            }
          }
          return true;
        });
  }
}

enum SkeletonAppBarIconType {
  cross,
  crossWhite,
  leftArrow,
}

class SkeletonAppBar extends GetView<GlobalController>
    implements PreferredSizeWidget {
  final SkeletonAppBarIconType iconType;
  final String? titleText;
  final String? actionText;
  final bool inOverlay;
  final bool isLeftIconDisplayed;
  final bool isIconAction;
  final bool isLeftTitle;
  final bool isSearchIcon;
  final bool isOnlyAlarmIcon;
  final bool isIconColorBlack;
  final bool isStatusbarBlur;
  final Color? backgroundColor;
  final Color? shadowColor;
  final void Function()? actionCallback;
  final Widget? customAction;

  const SkeletonAppBar(
      {super.key,
      this.iconType = SkeletonAppBarIconType.leftArrow,
      this.titleText,
      this.actionText,
      this.actionCallback,
      this.backgroundColor,
      this.shadowColor,
      this.customAction,
      this.inOverlay = false,
      this.isLeftIconDisplayed = true,
      this.isIconAction = false,
      this.isLeftTitle = false,
      this.isSearchIcon = false,
      this.isOnlyAlarmIcon = false,
      this.isIconColorBlack = false,
      this.isStatusbarBlur = false});

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: isStatusbarBlur
            ? ImageFilter.blur(sigmaX: 1, sigmaY: 1)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: AppBar(
          toolbarHeight: 60,
          leading: isLeftIconDisplayed
              ? IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () => Get.back(),
                  icon: _getLeftIcon(),
                )
              : null,
          automaticallyImplyLeading: false,
          centerTitle: !isLeftTitle,
          title: _getTitle(),
          titleSpacing: 0,
          actions: _getAction(),
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: shadowColor ?? Colors.transparent,
          backgroundColor: backgroundColor ?? Colors.transparent,
        ),
      ),
    );
  }

  List<Widget>? _getAction() {
    if (customAction != null) {
      return [customAction!];
    } else {
      return isIconAction ? _getIconAction() : _getTextAction();
    }
  }

  Widget _getLeftIcon() {
    switch (iconType) {
      case SkeletonAppBarIconType.cross:
        return const SkeletonPictureAsset(
          type: SkeletonPictureAssetType.appBarCross,
        );
      case SkeletonAppBarIconType.leftArrow:
        return const SkeletonPictureAsset(
          type: SkeletonPictureAssetType.appBarArrowRight,
        );
      case SkeletonAppBarIconType.crossWhite:
        return const SkeletonPictureAsset(
          type: SkeletonPictureAssetType.appBarCrossWhite,
        );
    }
  }

  Widget? _getTitle() {
    if (titleText == null) {
      return null;
    } else {
      if (isLeftTitle) {
        if (isLeftIconDisplayed) {
          return Text(
            titleText!,
            style: SkeletonTextTheme.newBody16Bold,
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              titleText!,
              style: SkeletonTextTheme.newBody16Bold,
            ),
          );
        }
      } else {
        return Text(
          titleText!,
          style: SkeletonTextTheme.h3.copyWith(height: 1),
        );
      }
    }
  }

  List<Widget>? _getTextAction() {
    if (actionText == null) {
      return null;
    } else {
      return [
        SkeletonTap(
          onTap: () => actionCallback?.call(),
          child: Center(
            child: Text(
              actionText!,
              style: SkeletonTextTheme.body2.copyWith(
                color: SkeletonColorScheme.keyColor,
              ),
            ),
          ),
        ),
        SkeletonSpacing.hXBase,
      ];
    }
  }

  List<Widget>? _getIconAction() {
    if (isSearchIcon) {
      return [
        searchActionIcon(isIconColorBlack: isIconColorBlack),
        SkeletonSpacing.hXBase,
      ];
    } else if (isOnlyAlarmIcon) {
      return [];
    } else {
      return [
        // alarmActionIcon(isIconColorBlack: isIconColorBlack),
        // SkeletonSpacing.hSmall,
        settingsIcon(isIconColorBlack: isIconColorBlack),
        SkeletonSpacing.hXBase,
      ];
    }
  }

  Widget searchActionIcon({bool isIconColorBlack = false}) {
    return SkeletonTap(
        //settings
        onTap: () => actionCallback?.call(),
        child: isIconColorBlack
            ? const SkeletonPictureAsset(
                type: SkeletonPictureAssetType.appBarSearchBlack)
            : const SkeletonPictureAsset(
                type: SkeletonPictureAssetType.appBarSearch));
  }

  Widget alarmActionIcon({bool isIconColorBlack = false}) {
    return SkeletonTap(
      //bell
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: isIconColorBlack
            ? const SkeletonPictureAsset(
                type: SkeletonPictureAssetType.appBarBellDefaultBlack)
            : const SkeletonPictureAsset(
                type: SkeletonPictureAssetType.appBarBellDefault),
      ),
    );
  }

  Widget settingsIcon({bool isIconColorBlack = false}) {
    return SkeletonTap(
        //settings
        onTap: () {},
        child: isIconColorBlack
            ? const SkeletonPictureAsset(
                type: SkeletonPictureAssetType.appBarSettingsBlack)
            : const SkeletonPictureAsset(
                type: SkeletonPictureAssetType.appBarSettings));
  }
}

class SkeletonScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final EdgeInsetsGeometry bodyPadding;
  final bool withNavBar;
  final Color? backgroundColor;
  final Widget? navBar;
  final bool resizeToAvoidBottomInset;
  final bool isExtendBodyBehindAppBar;
  final Widget? bottomSheet;
  final Drawer? drawer;
  final Widget? floatingActionButton;

  const SkeletonScaffold(
      {super.key,
      required this.body,
      this.appBar,
      this.bodyPadding = const EdgeInsets.all(20),
      this.withNavBar = false,
      this.navBar,
      this.backgroundColor,
      this.resizeToAvoidBottomInset = true,
      this.isExtendBodyBehindAppBar = false,
      this.bottomSheet,
      this.floatingActionButton,
      this.drawer});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      extendBodyBehindAppBar: isExtendBodyBehindAppBar,
      appBar: appBar,
      body: Padding(
        padding: bodyPadding,
        child: Column(
          children: [
            Expanded(child: SafeArea(child: body)),
            // GetPlatform.isIOS ? SkeletonSpacing.vBase : SkeletonSpacing.none
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: withNavBar
          ? (navBar == null ? const SkeletonBottomNavigationBar() : navBar!)
          : null,
      backgroundColor: backgroundColor ?? Colors.white,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomSheet: bottomSheet,
      drawer: drawer,
    );
  }
}
