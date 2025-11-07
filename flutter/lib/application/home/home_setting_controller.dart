import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/gen/diffusion_model.dart' as df;
import '../core/skeleton_controller.dart';

import 'package:get/get.dart';

class HomeSettingController extends SkeletonController {
  final SharedPreferences prefs = Get.find<SharedPreferences>();

  // 스탭 관련 변수
  RxNum samplingSteps = RxNum(28);

  // 샘플러 관련 변수
  RxString selectedSampler = 'Euler a'.obs; // 초기값 설정

  // CFG 스케일 관련 변수
  RxNum cfgReScale = RxNum(0);

  // 프롬프트 가이던스 관련 변수
  RxNum promptGuidance = RxNum(5);

  String get selectedSamplerValue =>
      samplers[selectedSampler.value] ?? 'k_euler_ancestral';

  Map<String, String> samplers = {
    'Euler a': 'k_euler_ancestral',
    'Euler': 'k_euler',
    'DPM++ 2S Ancestral': 'k_dpmpp_2s_ancestral',
    'DPM++ 2M SDE': 'k_dpmpp_2m_sde',
    'DPM++ 2M': 'k_dpmpp_2m',
    'DPM++ SDE': 'k_dpmpp_sde',
  };

  Map<String, String> samplersReversed = {
    'k_euler_ancestral': 'Euler a',
    'k_euler': 'Euler',
    'k_dpmpp_2s_ancestral': 'DPM++ 2S Ancestral',
    'k_dpmpp_2m_sde': 'DPM++ 2M SDE',
    'k_dpmpp_2m': 'DPM++ 2M',
    'k_dpmpp_sde': 'DPM++ SDE',
  };

  // 시드 관련 변수
  final seedController = TextEditingController();
  RxBool randomSeed = true.obs;

  // 프리셋 관련 변수
  RxString selectedPreset = ''.obs;
  RxMap<String, df.DiffusionModel> presetMap =
      <String, df.DiffusionModel>{}.obs;

  // 해상도 관련 변수
  TextEditingController xSizeController = TextEditingController();
  TextEditingController ySizeController = TextEditingController();
  RxString selectedSize = '832 x 1216'.obs; // 초기값 설정
  Map<String, List<int>> sizeOptions = {
    '832 x 1216': [832, 1216],
    '1024 x 1024': [1024, 1024],
    '1216 x 832': [1216, 832],
  };

  // 자동생성 해상도 관련 변수
  TextEditingController autoSizeXController = TextEditingController();
  TextEditingController autoSizeYController = TextEditingController();
  RxBool autoChangeSize = false.obs; // 자동 해상도 변경 여부
  RxList<Size> sizeOptionsWithCustom = <Size>[].obs;
  int autoSizeCurrentIndex = 0;

  void autoResolutionChange() {
    if (autoChangeSize.value) {
      // 자동 해상도 변경이 켜져있으면, SizeOptions에서 해상도를 순차적으로 변경, 커스텀일 경우 0부터 시작
      if (autoSizeCurrentIndex < sizeOptionsWithCustom.length - 1) {
        autoSizeCurrentIndex++;
      } else {
        autoSizeCurrentIndex = 0; // 마지막 해상도면 처음으로 돌아감
      }
      Size customSize = sizeOptionsWithCustom[autoSizeCurrentIndex];
      selectedSize.value =
          "${customSize.width.toInt()} x ${customSize.height.toInt()}";
      xSizeController.text = customSize.width.toStringAsFixed(0); // 가로 해상도 업데이트
      ySizeController.text =
          customSize.height.toStringAsFixed(0); // 세로 해상도 업데이트
    }
  }

  void validateResolutionBeforeGenerate() {
    validateAndUpdateResolution(xSizeController.text, true);
    validateAndUpdateResolution(ySizeController.text, false);
  }

  void loadSettings(df.DiffusionModel setting) {
    selectedSize.value =
        '${setting.parameters.width} x ${setting.parameters.height}';

    xSizeController.text = '${setting.parameters.width}';
    ySizeController.text = '${setting.parameters.height}';
  }

  bool addSizeOption() {
    if (autoSizeXController.text.isEmpty || autoSizeYController.text.isEmpty) {
      Get.snackbar('오류', '가로와 세로 해상도를 모두 입력해주세요.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    int x = _parseResolutionSafely(autoSizeXController.text, 64);
    int y = _parseResolutionSafely(autoSizeYController.text, 64);

    sizeOptionsWithCustom.add(Size(x.toDouble(), y.toDouble()));
    saveSizeOptions();
    autoSizeXController.text = "";
    autoSizeYController.text = "";
    return true;
  }

  void saveSizeOptions() {
    prefs.setStringList("customSizeList", [
      ...sizeOptionsWithCustom
          .map((s) => '${s.width.toInt()} x ${s.height.toInt()}')
    ]);
  }

  int _parseResolutionSafely(String value, int defaultValue) {
    // 빈 값이면 64로 설정
    if (value.isEmpty || value.trim().isEmpty) {
      return 64;
    }

    try {
      int parsed = int.parse(value);
      // 0이나 음수면 64로
      if (parsed <= 0) {
        return 64;
      }
      // 64의 배수로 조정
      return roundToMultipleOf64(parsed);
    } catch (e) {
      // 파싱 실패시 64로
      return 64;
    }
  }

// 해상도 입력값 검증 및 변환
  void validateAndUpdateResolution(String value, bool isWidth) {
    if (value.isEmpty) return;

    try {
      int inputValue = int.parse(value);
      int validValue = roundToMultipleOf64(inputValue);

      if (isWidth) {
        if (inputValue != validValue) {
          xSizeController.text = validValue.toString();
          // 사용자에게 알림 (너무 자주 뜨지 않게 조건부로)
          if ((inputValue - validValue).abs() > 32) {
            Get.snackbar(
              '해상도 자동 조정',
              '가로 해상도가 $inputValue → $validValue 로 조정되었습니다.',
              backgroundColor: Colors.orange.withValues(alpha: 0.8),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        }
      } else {
        if (inputValue != validValue) {
          ySizeController.text = validValue.toString();
          if ((inputValue - validValue).abs() > 32) {
            Get.snackbar(
              '해상도 자동 조정',
              '세로 해상도가 $inputValue → $validValue 로 조정되었습니다.',
              backgroundColor: Colors.orange.withValues(alpha: 0.8),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        }
      }

      // 커스텀 해상도 업데이트
      setCustomResolution();
    } catch (e) {
      // 숫자가 아닌 경우 기본값으로 설정
      if (isWidth) {
        xSizeController.text = '832';
      } else {
        ySizeController.text = '1216';
      }
    }
  }

// 기존 setCustomResolution 함수 수정
  void setCustomResolution() {
    // 빈 값 체크 후 기본값 설정
    if (xSizeController.text.isEmpty) {
      xSizeController.text = '832';
    }
    if (ySizeController.text.isEmpty) {
      ySizeController.text = '1216';
    }

    try {
      int width = int.parse(xSizeController.text);
      int height = int.parse(ySizeController.text);

      // 64의 배수로 자동 조정
      width = roundToMultipleOf64(width);
      height = roundToMultipleOf64(height);

      // 값이 변경되었으면 컨트롤러 업데이트
      if (xSizeController.text != width.toString()) {
        xSizeController.text = width.toString();
      }
      if (ySizeController.text != height.toString()) {
        ySizeController.text = height.toString();
      }
    } catch (e) {
      // 파싱 오류 시 기본값으로 되돌리기
      xSizeController.text = '832';
      ySizeController.text = '1216';
    }
  }

  int roundToMultipleOf64(int value) {
    // 최소값 64, 최대값 2048로 제한 (NovelAI 기준)
    value = value.clamp(64, 2048);

    // 가장 가까운 64의 배수로 반올림
    int remainder = value % 64;
    if (remainder == 0) {
      return value;
    } else if (remainder < 32) {
      // 32보다 작으면 내림
      return value - remainder;
    } else {
      // 32보다 크거나 같으면 올림
      return value + (64 - remainder);
    }
  }

  void removeSizeOption(int index) {
    sizeOptionsWithCustom.removeAt(index);
    prefs.setStringList("customSizeList", [
      ...sizeOptionsWithCustom
          .map((s) => '${s.width.toInt()} x ${s.height.toInt()}')
    ]);
  }

  void savePreset(String presetName, df.DiffusionModel setting) {
    // 현재 설정을 JSON 문자열로 변환
    final currentSettingJson = jsonEncode(setting.toJson());

    // 동일한 프리셋이 있는지 확인
    bool hasIdenticalPreset = false;
    String? identicalPresetName;

    for (final entry in presetMap.entries) {
      final existingSettingJson = jsonEncode(entry.value.toJson());
      if (currentSettingJson == existingSettingJson) {
        hasIdenticalPreset = true;
        identicalPresetName = entry.key;
        break;
      }
    }

    if (hasIdenticalPreset) {
      Get.dialog(
        AlertDialog(
          title: const Text('동일한 프리셋 발견'),
          content: Text(
              '현재 설정과 동일한 "$identicalPresetName" 프리셋이 이미 존재합니다. 그래도 저장하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Get.back(); // 다이얼로그 닫기
                Get.back(); // 다이얼로그 닫기
                selectedPreset.value = presetName;
                // 그래도 저장 진행
                _savePresetFinal(presetName, setting, currentSettingJson);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      );
    } else {
      // 동일한 설정이 없으면 바로 저장
      Get.back(); // 다이얼로그 닫기
      selectedPreset.value = presetName;
      _savePresetFinal(presetName, setting, currentSettingJson);
    }
  }

  df.DiffusionModel? loadPreset(String presetName) {
    Get.back();

    final presetJson = prefs.getString("preset_$presetName");
    if (presetJson == null) {
      Get.snackbar('프리셋 없음', '$presetName 프리셋이 존재하지 않습니다.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return null;
    }
    try {
      Map<String, dynamic> data = jsonDecode(presetJson);
      final setting = df.DiffusionModel.fromJson(data);
      // print("setting: $setting");
      selectedPreset.value = presetName;
      setSettings(setting);
      return setting;
    } catch (e) {
      Get.snackbar('로드 오류', '$presetName 프리셋을 로드하는 중 오류가 발생했습니다: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }

  void setSettings(df.DiffusionModel setting) {
    setResolution(setting);
    setSampler(setting);
    setSampleingSteps(setting);
    setCfgReScale(setting);
    setPromptGuidance(setting);
  }

  void setPromptGuidance(df.DiffusionModel setting) {
    // 프리셋에서 프롬프트 가이던스 설정
    promptGuidance.value = setting.parameters.scale;
  }

  void setCfgReScale(df.DiffusionModel setting) {
    // 프리셋에서 CFG 스케일 설정
    cfgReScale.value = setting.parameters.cfg_rescale;
  }

  void setSampleingSteps(df.DiffusionModel setting) {
    samplingSteps.value = setting.parameters.steps;
  }

  // 프리셋에서 설정값 적용

  void setResolution(df.DiffusionModel setting) {
    // 프리셋에서 해상도 설정
    xSizeController.text = setting.parameters.width.toString();
    ySizeController.text = setting.parameters.height.toString();
    selectedSize.value =
        '${setting.parameters.width} x ${setting.parameters.height}';
  }

  void setSampler(df.DiffusionModel setting) {
    // 프리셋에서 샘플러 설정
    selectedSampler.value =
        samplersReversed[setting.parameters.sampler] ?? 'Euler a';
  }

  void _savePresetFinal(
      String presetName, df.DiffusionModel setting, String jsonStr) {
    // 랜덤 시드 여부에 따라 처리
    if (randomSeed.value || setting.parameters.seed == 999999999) {
      // 랜덤 시드면 999999999로 저장
      setting = setting.copyWith(
        parameters: setting.parameters.copyWith(
          seed: 999999999,
        ),
      );
    } else if (seedController.text.isNotEmpty) {
      // 사용자 입력 시드가 있으면 그걸로 저장
      setting = setting.copyWith(
        parameters: setting.parameters.copyWith(
          seed: int.parse(seedController.text),
        ),
      );
    }

    prefs.setString("preset_$presetName", jsonEncode(setting.toJson()));
    presetMap[presetName] = setting;
  }

  void loadPresets() {
    presetMap.clear();

    // SharedPreferences에서 프리셋으로 시작하는 모든 키 가져오기
    final keys =
        prefs.getKeys().where((key) => key.startsWith('preset_')).toList();

    for (var key in keys) {
      if (key.startsWith('preset_')) {
        try {
          final presetName = key.substring(7);
          final presetJson = prefs.getString(key);
          if (presetJson != null) {
            Map<String, dynamic> data = jsonDecode(presetJson);

            final setting = df.DiffusionModel.fromJson(data);
            presetMap[presetName] = setting;
          }
        } catch (e) {
        }
      }
    }
  }

  Future<void> deletePreset(String presetName) async {
    //스낵바 모두 닫기
    Get.closeAllSnackbars();
    Get.back(closeOverlays: true);

    prefs.remove("preset_$presetName");
    presetMap.remove(presetName);
  }

  @override
  Future<bool> initLoading() async {
    return true;
  }
}
