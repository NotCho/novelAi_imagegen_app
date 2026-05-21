import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:naiapp/domain/gen/i_novelAI_repository.dart';
import 'package:naiapp/infra/gen/novelAI_repository.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/core/global_controller.dart';
import '../../application/core/router.dart';
import '../../application/function/remote_config_service.dart';
import '../../application/home/image_cache_manager.dart';
import '../../application/wildcard/wildcard_controller.dart';
import '../../domain/core/i_connection.dart';
import 'connection.dart';
import 'package:http/http.dart' as http;

Future<void> injectDependencies() async {
  print('[Dependency Inject] Starting injectDependencies...');
  // 웹이 아닐 때만 권한 요청 및 포그라운드 서비스 초기화
  if (!kIsWeb) {
    print('[Dependency Inject] Requesting permissions (non-blocking)...');
    _requestPermissions();
    print('[Dependency Inject] Initializing foreground service...');
    _initForegroundService();
  } else {
  }

  print('[Dependency Inject] Initializing Firebase...');
  await _initializeFirebase();

  print('[Dependency Inject] Putting SharedPreferences...');
  Get.put<SharedPreferences>(await SharedPreferences.getInstance());
  
  print('[Dependency Inject] Putting IConnection...');
  Get.put<IConnection>(JSEO.instance);
  
  print('[Dependency Inject] Putting INovelAIRepository...');
  Get.put<INovelAIRepository>(NovelAIRepository(
      httpClient: http.Client(), prefs: await SharedPreferences.getInstance()));

  print('[Dependency Inject] Putting ISkeletonRouter...');
  Get.put<ISkeletonRouter>(SkeletonRouter());
  
  print('[Dependency Inject] Initializing RemoteConfigService...');
  Get.put<RemoteConfigService>(
    await RemoteConfigService.initialize(),
    permanent: true,
  );
  
  print('[Dependency Inject] Putting GlobalController...');
  Get.put<GlobalController>(GlobalController());
  
  print('[Dependency Inject] Putting ImageCacheManager...');
  Get.put(ImageCacheManager(), permanent: true);
  
  print('[Dependency Inject] Putting WildcardController...');
  Get.put<WildcardController>(WildcardController(), permanent: true);
  
  print('[Dependency Inject] Finished injectDependencies successfully.');
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    rethrow;
  }
}

Future<void> _requestPermissions() async {
  // 웹에서는 실행하지 않음
  if (kIsWeb) return;

  try {
    // Android 13+: 알림 권한 요청
    final permission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  } catch (e) {
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
    // 초기화 실패해도 앱 진행
  }
}

// 포그라운드 서비스 시작 (사용하는 곳에서 호출)
Future<void> startForegroundService() async {
  if (kIsWeb) {
    return;
  }

  try {
    await FlutterForegroundTask.startService(
      notificationTitle: 'NAI App 실행 중',
      notificationText: '백그라운드에서 실행 중입니다',
      callback: _foregroundTaskCallback,
    );
  } catch (e) {
  }
}

// 포그라운드 서비스 중지
Future<void> stopForegroundService() async {
  if (kIsWeb) return;

  try {
    await FlutterForegroundTask.stopService();
  } catch (e) {
  }
}

// 포그라운드 태스크 콜백 (필요하면 사용)
@pragma('vm:entry-point')
void _foregroundTaskCallback() {
  // 백그라운드에서 실행될 작업
}
