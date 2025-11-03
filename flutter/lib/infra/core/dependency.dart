import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:naiapp/domain/gen/i_novelAI_repository.dart';
import 'package:naiapp/infra/gen/novelAI_repository.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/core/global_controller.dart';
import '../../application/core/router.dart';
import '../../application/home/image_cache_manager.dart';
import '../../domain/core/i_connection.dart';
import 'connection.dart';
import 'package:http/http.dart' as http;

Future<void> injectDependencies() async {
  // 웹이 아닐 때만 권한 요청 및 포그라운드 서비스 초기화
  if (!kIsWeb) {
    await _requestPermissions();
    _initForegroundService();
  } else {
    print('웹 환경에서는 포그라운드 서비스를 사용하지 않습니다');
  }

  /// Repo
  Get.put<SharedPreferences>(await SharedPreferences.getInstance());
  Get.put<IConnection>(JSEO.instance);
  Get.put<INovelAIRepository>(NovelAIRepository(
      httpClient: http.Client(), prefs: await SharedPreferences.getInstance()));

  /// Service
  Get.put<ISkeletonRouter>(SkeletonRouter());
  Get.put<GlobalController>(GlobalController());
  Get.put(ImageCacheManager(), permanent: true);

}

Future<void> _requestPermissions() async {
  // 웹에서는 실행하지 않음
  if (kIsWeb) return;

  try {
    // Android 13+: 알림 권한 요청
    final permission = await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  } catch (e) {
    print('권한 요청 중 오류 발생: $e');
    // 권한 요청이 실패해도 앱 진행
  }
}

void _initForegroundService() {
  // 웹에서는 실행하지 않음
  if (kIsWeb) return;

  try {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription: '서비스 실행 중에 표시됩니다',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  } catch (e) {
    print('포그라운드 서비스 초기화 중 오류 발생: $e');
    // 초기화 실패해도 앱 진행
  }
}

// 포그라운드 서비스 시작 (사용하는 곳에서 호출)
Future<void> startForegroundService() async {
  if (kIsWeb) {
    print('웹에서는 포그라운드 서비스를 지원하지 않습니다');
    return;
  }

  try {
    await FlutterForegroundTask.startService(
      notificationTitle: 'NAI App 실행 중',
      notificationText: '백그라운드에서 실행 중입니다',
      callback: _foregroundTaskCallback,
    );
  } catch (e) {
    print('포그라운드 서비스 시작 실패: $e');
  }
}

// 포그라운드 서비스 중지
Future<void> stopForegroundService() async {
  if (kIsWeb) return;

  try {
    await FlutterForegroundTask.stopService();
  } catch (e) {
    print('포그라운드 서비스 중지 실패: $e');
  }
}

// 포그라운드 태스크 콜백 (필요하면 사용)
@pragma('vm:entry-point')
void _foregroundTaskCallback() {
  // 백그라운드에서 실행될 작업
  print('포그라운드 서비스 실행 중...');
}