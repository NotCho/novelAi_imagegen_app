import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/home_generation_controller.dart';
import 'package:naiapp/application/home/home_image_controller.dart';
import 'package:naiapp/application/home/home_setting_controller.dart';
import 'package:naiapp/main.dart'; // For startCallback

import 'package:flutter/material.dart';

class HomeAutoGenerationController extends GetxController {
  final autoGenerateCountController =
      TextEditingController(text: '0');
  // Dependencies will be injected later, for now we use Get.find
  HomeGenerationController get _homeGenerationController => Get.find<HomeGenerationController>();
  HomeImageController get _homeImageController => Get.find<HomeImageController>();
  HomeSettingController get _homeSettingController => Get.find<HomeSettingController>();

  final autoGenerateEnabled = false.obs; // 자동 생성 활성화 여부
  final RxDouble autoGenerateSeconds = 5.0.obs; // 자동 생성 대기 시간 (초)
  final RxDouble autoGenerateRandomDelay = 0.0.obs; // 자동 생성 대기 시간 랜덤 범위
  final remainingSeconds = 0.obs; // 남은 시간 표시용
  Timer? _autoGenerateTimer; // 자동 생성 타이머
  Timer? get autoGenerateTimer => _autoGenerateTimer;
  final RxInt maxAutoGenerateCount = 0.obs; // 최대 자동 생성 이미지 수
  final RxInt currentAutoGenerateCount = 0.obs; // 현재 자동 생성 이미지 수

  @override
  void onClose() {
    _cancelAutoGenerateTimer(); // 타이머 취소
    super.onClose();
  }

  void _cancelAutoGenerateTimer() {
    _autoGenerateTimer?.cancel();
    _autoGenerateTimer = null;
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
        if (!_homeGenerationController.isGenerating.value && autoGenerateEnabled.value) {
          _homeGenerationController.generateImage();
        }
      }
    });
  }

  // This method will be called from HomeGenerationController after an image is successfully generated.
  void onImageGenerated() {
    if (autoGenerateEnabled.value) {
      _startAutoGenerateTimer();
      _homeSettingController.autoResolutionChange();
      currentAutoGenerateCount.value++;
      if (maxAutoGenerateCount.value > 0 && currentAutoGenerateCount.value >= maxAutoGenerateCount.value) {
        autoGenerateEnabled.value = false;
        _cancelAutoGenerateTimer();
        Get.snackbar(
          '알림',
          '최대 자동 생성 이미지 수에 도달했습니다. 자동 생성이 비활성화됩니다.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    }

    if (FlutterForegroundTask.isRunningService) {
        updateNotification();
    }
  }

  void toggleAutoGenerate() async {
    autoGenerateEnabled.toggle();
    if (autoGenerateEnabled.value) {
      await FlutterForegroundTask.startService(
        notificationTitle: '서비스 실행 중',
        notificationText: '탭하면 앱으로 돌아갑니다',
        notificationInitialRoute: '/home',
        callback: startCallback,
      );
      _startAutoGenerateTimer();
    } else {
      FlutterForegroundTask.stopService();
      _cancelAutoGenerateTimer();
    }
  }

  void setAutoGenerateSeconds(double time) {
    autoGenerateSeconds.value = time;
    if (_autoGenerateTimer != null && _autoGenerateTimer!.isActive) {
      _startAutoGenerateTimer();
    }
  }

  void setAutoGenerateRandomDelay(double delay) {
    autoGenerateRandomDelay.value = delay;
  }

  String getRandomDelayCalculation() {
    double randomRange =
        autoGenerateSeconds.value * autoGenerateRandomDelay.value;
    return "±${randomRange.toStringAsFixed(2)}초";
  }

  void updateNotification() {
      FlutterForegroundTask.updateService(
          notificationTitle: '자동 생성 활성화',
          notificationText:
              '현재 생성된 이미지 수 : ${_homeImageController.generationHistory.length}개 | ${(_homeSettingController.autoSave.value) ? "자동 저장중" : "저장 안함"}',
          notificationInitialRoute: '',
          callback: startCallback,
        );
  }
}
