import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

/// 자동 생성 로직을 담당하는 컨트롤러
///
/// 책임:
/// - 자동 생성 활성화/비활성화
/// - 자동 생성 타이머 관리
/// - 자동 생성 대기 시간 및 랜덤 딜레이 설정
/// - 최대 자동 생성 수 관리
/// - 포그라운드 서비스 관리
class AutoGenerationController extends GetxController {
  final SharedPreferences prefs = Get.find<SharedPreferences>();

  // 자동 생성 상태
  final autoGenerateEnabled = false.obs;
  RxDouble autoGenerateSeconds = 5.0.obs;
  RxDouble autoGenerateRandomDelay = 0.0.obs;
  final remainingSeconds = 0.obs;

  // 자동 생성 카운트
  RxInt maxAutoGenerateCount = 0.obs;
  RxInt currentAutoGenerateCount = 0.obs;

  // 컨트롤러
  final autoGenerateCountController = TextEditingController(text: '0');

  // 타이머
  Timer? _autoGenerateTimer;
  Timer? get autoGenerateTimer => _autoGenerateTimer;

  @override
  void onClose() {
    _cancelAutoGenerateTimer();
    autoGenerateCountController.dispose();
    super.onClose();
  }

  /// 자동 생성 활성화/비활성화 토글
  void toggleAutoGenerate() async {
    autoGenerateEnabled.toggle();

    if (autoGenerateEnabled.value) {
      await FlutterForegroundTask.startService(
        notificationTitle: '서비스 실행 중',
        notificationText: '탭하면 앱으로 돌아갑니다',
        notificationInitialRoute: '/home',
        callback: startCallback,
      );
    } else {
      FlutterForegroundTask.stopService();
    }

    final homePageController = Get.find<HomePageController>();
    if (autoGenerateEnabled.value && !homePageController.isGenerating.value) {
      _startAutoGenerateTimer();
    } else {
      _cancelAutoGenerateTimer();
    }
  }

  /// 자동 생성 대기 시간 설정
  void setAutoGenerateSeconds(double time) {
    autoGenerateSeconds.value = time;
    if (_autoGenerateTimer != null && _autoGenerateTimer!.isActive) {
      _startAutoGenerateTimer();
    }
  }

  /// 자동 생성 랜덤 딜레이 설정
  void setAutoGenerateRandomDelay(double delay) {
    autoGenerateRandomDelay.value = delay;
  }

  /// 랜덤 딜레이 계산 결과 문자열 반환
  String getRandomDelayCalculation() {
    double randomRange =
        autoGenerateSeconds.value * autoGenerateRandomDelay.value;
    return "±${randomRange.toStringAsFixed(2)}초";
  }

  /// 자동 생성 타이머 시작
  void startAutoGenerateTimer() {
    _startAutoGenerateTimer();
  }

  /// 자동 생성 타이머 취소
  void cancelAutoGenerateTimer() {
    _cancelAutoGenerateTimer();
  }

  void _startAutoGenerateTimer() {
    if (!autoGenerateEnabled.value) return;

    // 기본 시간 설정
    double baseSeconds = autoGenerateSeconds.value;

    // 랜덤 범위 계산 (최대 변동 폭)
    double randomRange = baseSeconds * autoGenerateRandomDelay.value;

    // -randomRange부터 +randomRange 사이의 랜덤 값 생성
    double randomOffset =
        (Random().nextDouble() * 2 * randomRange) - randomRange;

    // 최종 시간 계산 (기본 시간 ± 랜덤 오프셋)
    double finalSeconds = baseSeconds + randomOffset;

    // 최소 시간 보장 (음수가 되지 않도록)
    finalSeconds = max(1.0, finalSeconds);

    // 최종 시간 설정
    remainingSeconds.value = finalSeconds.round();

    _cancelAutoGenerateTimer();

    _autoGenerateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingSeconds.value--;
      if (remainingSeconds.value <= 0) {
        _cancelAutoGenerateTimer();
        final homePageController = Get.find<HomePageController>();
        if (!homePageController.isGenerating.value &&
            autoGenerateEnabled.value) {
          homePageController.generateImage();
        }
      }
    });
  }

  void _cancelAutoGenerateTimer() {
    _autoGenerateTimer?.cancel();
    _autoGenerateTimer = null;
  }
}
