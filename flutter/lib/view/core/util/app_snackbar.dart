import 'package:flutter/material.dart';

/// Root messenger key for showing SnackBars without relying on an Overlay context.
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class AppSnackBar {
  static void show(
    String title,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    EdgeInsetsGeometry margin = const EdgeInsets.all(16),
    double borderRadius = 12,
  }) {
    final messenger = appScaffoldMessengerKey.currentState;
    if (messenger == null) {
      // App not mounted yet; try again next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        show(
          title,
          message,
          backgroundColor: backgroundColor,
          textColor: textColor,
          duration: duration,
          margin: margin,
          borderRadius: borderRadius,
        );
      });
      return;
    }

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: margin,
        duration: duration,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        content: DefaultTextStyle(
          style: TextStyle(color: textColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }
}


