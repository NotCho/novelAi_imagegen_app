import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/task_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {
    // 주기 실행 로직
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // 해제/정리 로직
  }

  @override
  void onNotificationPressed() {}
}
