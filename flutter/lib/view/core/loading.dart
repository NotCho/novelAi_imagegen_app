import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:naiapp/view/core/util/scroll.dart';

import '../../application/core/global_controller.dart';

class SkeletonLoadingOverlay extends GetView<GlobalController> {
  final Widget child;
  const SkeletonLoadingOverlay({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScrollConfiguration(
          behavior: NoGlowBehavior(),
          child: child,
        ),
        Obx(() => controller.isLoading
            ? const SkeletonLoadingOverlayScaffold()
            : const SizedBox()),
      ],
    );
  }
}

class SkeletonLoadingOverlayScaffold extends StatelessWidget {
  const SkeletonLoadingOverlayScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: SkeletonColorScheme.surfaceColor,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
