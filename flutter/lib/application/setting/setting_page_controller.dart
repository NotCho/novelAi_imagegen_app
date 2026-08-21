import 'package:file_picker/file_picker.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/view/core/util/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:naiapp/domain/gen/i_novelAI_repository.dart';

class SettingPageController extends SkeletonController {
  static const String saveDirectoryPathKey = 'saveDirectoryPath';

  final RxBool pngMode = true.obs; // PNG 모드 여부
  final RxBool imageGenerationStreamingMode = false.obs;
  final RxString saveDirectoryPath = ''.obs;
  final RxBool liquidGlassMode = false.obs;
  final RxDouble liquidGlassBlur = 1.0.obs;
  final RxDouble liquidGlassRefraction = 1.5.obs;
  final RxDouble liquidGlassAberration = 0.0.obs;
  final RxDouble liquidGlassThickness = 27.0.obs;
  final RxDouble liquidGlassLightIntensity = 1.0.obs;
  final RxDouble liquidGlassSaturation = 1.6.obs;
  final SharedPreferences prefs = Get.find<SharedPreferences>();

  void togglePngMode() {
    pngMode.value = !pngMode.value;
    prefs.setBool('pngMode', pngMode.value);
  }

  Future<void> setImageGenerationStreamingMode(bool value) async {
    imageGenerationStreamingMode.value = value;
    await prefs.setBool(imageGenerationStreamingModePreferenceKey, value);
  }

  void toggleLiquidGlassMode() {
    if (!liquidGlassMode.value) {
      Get.dialog(
        AlertDialog(
          backgroundColor: SkeletonColorScheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text(
                '울트라 모드 활성화 경고',
                style: TextStyle(
                  color: SkeletonColorScheme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            '울트라 액체 유리 효과는 실시간 GPU 셰이더를 사용하여 매우 아름다운 3D 굴절 효과를 렌더링하지만, 일부 기기에서 발열, 배터리 소모 또는 앱 불안정성(크래시)이 발생할 수 있습니다.\n\n불안정할 수 있는 이 실험적 효과를 정말로 활성화하시겠습니까?',
            style: TextStyle(
              color: SkeletonColorScheme.textColor,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('취소',
                  style:
                      TextStyle(color: SkeletonColorScheme.textSecondaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Get.back();
                _enableLiquidMode();
              },
              child: const Text('동의 및 활성화'),
            ),
          ],
        ),
      );
    } else {
      _disableLiquidMode();
    }
  }

  void _enableLiquidMode() {
    liquidGlassMode.value = true;
    prefs.setBool('liquidGlassMode', true);
    if (Get.isRegistered<HomePageController>()) {
      Get.find<HomePageController>().liquidGlassMode.value = true;
    }
    AppSnackBar.show(
      '울트라 셰이더 모드 ON',
      '불안정할 수 있는 울트라 액체 유리(셰이더) 효과가 활성화되었습니다. 기기 이상 시 즉시 꺼주세요.',
      backgroundColor: Colors.cyan,
      textColor: Colors.white,
    );
  }

  void _disableLiquidMode() {
    liquidGlassMode.value = false;
    prefs.setBool('liquidGlassMode', false);
    if (Get.isRegistered<HomePageController>()) {
      Get.find<HomePageController>().liquidGlassMode.value = false;
    }
    AppSnackBar.show(
      '일반 모드 안정화 ON',
      '실시간 GPU 셰이더를 종료하고 100% 안정적인 일반 글래스모피즘 효과로 복구되었습니다.',
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  void loadPngMode() {
    pngMode.value = prefs.getBool('pngMode') ?? true;
  }

  void loadSaveDirectoryPath() {
    saveDirectoryPath.value = prefs.getString(saveDirectoryPathKey) ?? '';
  }

  Future<void> selectSaveDirectory() async {
    try {
      final path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '이미지 저장 폴더 선택',
      );
      if (path == null || path.isEmpty) return;

      await prefs.setString(saveDirectoryPathKey, path);
      saveDirectoryPath.value = path;
      AppSnackBar.show(
        '저장 경로 설정',
        path,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      AppSnackBar.show(
        '오류',
        '저장 경로 선택 실패: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> clearSaveDirectory() async {
    await prefs.remove(saveDirectoryPathKey);
    saveDirectoryPath.value = '';
    AppSnackBar.show(
      '저장 경로 초기화',
      '이미지는 기본 갤러리에 저장됩니다.',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void setLiquidGlassBlur(double value) {
    liquidGlassBlur.value = value;
    prefs.setDouble('liquidGlassBlur', value);
    if (Get.isRegistered<HomePageController>()) {
      Get.find<HomePageController>().liquidGlassBlur.value = value;
    }
  }

  void setLiquidGlassRefraction(double value) {
    liquidGlassRefraction.value = value;
    prefs.setDouble('liquidGlassRefraction', value);
    if (Get.isRegistered<HomePageController>()) {
      Get.find<HomePageController>().liquidGlassRefraction.value = value;
    }
  }

  void setLiquidGlassAberration(double value) {
    liquidGlassAberration.value = value;
    prefs.setDouble('liquidGlassAberration', value);
    if (Get.isRegistered<HomePageController>()) {
      Get.find<HomePageController>().liquidGlassAberration.value = value;
    }
  }

  void setLiquidGlassThickness(double value) {
    liquidGlassThickness.value = value;
    prefs.setDouble('liquidGlassThickness', value);
    if (Get.isRegistered<HomePageController>()) {
      Get.find<HomePageController>().liquidGlassThickness.value = value;
    }
  }

  void setLiquidGlassLightIntensity(double value) {
    liquidGlassLightIntensity.value = value;
    prefs.setDouble('liquidGlassLightIntensity', value);
    if (Get.isRegistered<HomePageController>()) {
      Get.find<HomePageController>().liquidGlassLightIntensity.value = value;
    }
  }

  void setLiquidGlassSaturation(double value) {
    liquidGlassSaturation.value = value;
    prefs.setDouble('liquidGlassSaturation', value);
    if (Get.isRegistered<HomePageController>()) {
      Get.find<HomePageController>().liquidGlassSaturation.value = value;
    }
  }

  @override
  Future<bool> initLoading() async {
    loadPngMode();
    imageGenerationStreamingMode.value =
        prefs.getBool(imageGenerationStreamingModePreferenceKey) ?? false;
    loadSaveDirectoryPath();
    liquidGlassMode.value = prefs.getBool('liquidGlassMode') ?? false;
    liquidGlassBlur.value = prefs.getDouble('liquidGlassBlur') ?? 1.0;
    liquidGlassRefraction.value =
        prefs.getDouble('liquidGlassRefraction') ?? 1.5;
    liquidGlassAberration.value =
        prefs.getDouble('liquidGlassAberration') ?? 0.0;
    liquidGlassThickness.value =
        prefs.getDouble('liquidGlassThickness') ?? 27.0;
    liquidGlassLightIntensity.value =
        prefs.getDouble('liquidGlassLightIntensity') ?? 1.0;
    liquidGlassSaturation.value =
        prefs.getDouble('liquidGlassSaturation') ?? 1.6;
    return true;
  }

  void logout() {
    Get.find<HomePageController>().logout();
  }
}
