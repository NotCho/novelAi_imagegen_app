import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/task_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('포그라운드 서비스 시작: $timestamp');
    
    // SharedPreferences를 통해 안전하게 상태 설정
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('skip_init_loading', true);
    print('initLoading 건너뛰기 플래그 설정됨');
  }

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
