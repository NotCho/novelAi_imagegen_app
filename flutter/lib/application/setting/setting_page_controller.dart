import 'package:file_picker/file_picker.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/view/core/util/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPageController extends SkeletonController {
  static const String saveDirectoryPathKey = 'saveDirectoryPath';

  final RxBool pngMode = true.obs; // PNG 모드 여부
  final RxString saveDirectoryPath = ''.obs;
  final SharedPreferences prefs = Get.find<SharedPreferences>();

  void togglePngMode() {
    pngMode.value = !pngMode.value;
    prefs.setBool('pngMode', pngMode.value);
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

  @override
  Future<bool> initLoading() async {
    loadPngMode();
    loadSaveDirectoryPath();
    return true;
  }

  void logout() {
    Get.find<HomePageController>().logout();
  }
}
