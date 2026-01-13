import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/wildcard/wildcard_model.dart';
import '../../infra/service/wildcard_service.dart';
import '../../view/core/util/app_snackbar.dart';

/// 와일드카드 관리 컨트롤러
class WildcardController extends GetxController {
  late final WildcardService _wildcardService;

  /// 와일드카드 목록
  final wildcards = <WildcardModel>[].obs;

  /// 로딩 상태
  final isLoading = false.obs;

  /// 에러 메시지
  final errorMessage = ''.obs;

  /// 선택된 와일드카드 (편집용)
  final selectedWildcard = Rxn<WildcardModel>();

  @override
  void onInit() {
    super.onInit();
    _wildcardService = WildcardService(Get.find<SharedPreferences>());
    _loadWildcards();
  }

  /// 와일드카드 목록 로드
  Future<void> _loadWildcards() async {
    isLoading.value = true;
    try {
      await _wildcardService.initialize();
      wildcards.value = await _wildcardService.loadAllWildcards();
    } catch (e) {
      errorMessage.value = '와일드카드 로드 실패: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 새로고침
  Future<void> refreshWildcards() async {
    await _loadWildcards();
  }

  /// 텍스트 파일에서 와일드카드 임포트
  Future<void> importFromFilePicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      isLoading.value = true;

      for (final file in result.files) {
        if (file.path != null) {
          await _wildcardService.importFromFile(file.path!);
        }
      }

      await _loadWildcards();
      AppSnackBar.show('성공', '${result.files.length}개 와일드카드 임포트 완료', backgroundColor: Colors.green, textColor: Colors.white);
    } catch (e) {
      errorMessage.value = '임포트 실패: $e';
      AppSnackBar.show('오류', '임포트 실패: $e', backgroundColor: Colors.red, textColor: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// 텍스트에서 직접 와일드카드 생성
  Future<void> createWildcard(String name, String content) async {
    if (name.isEmpty) {
      AppSnackBar.show('오류', '와일드카드 이름을 입력해주세요', backgroundColor: Colors.red, textColor: Colors.white);
      return;
    }

    // 이름 유효성 검사 (영문, 숫자, 언더스코어만)
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name)) {
      AppSnackBar.show('오류', '이름은 영문, 숫자, 언더스코어(_)만 사용 가능해요', backgroundColor: Colors.red, textColor: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      await _wildcardService.createFromText(name, content);
      await _loadWildcards();
      AppSnackBar.show('성공', '__${name}__ 와일드카드 생성 완료', backgroundColor: Colors.green, textColor: Colors.white);
    } catch (e) {
      errorMessage.value = '생성 실패: $e';
      AppSnackBar.show('오류', '생성 실패: $e', backgroundColor: Colors.red, textColor: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// 와일드카드 업데이트
  Future<void> updateWildcard(WildcardModel wildcard) async {
    try {
      isLoading.value = true;
      await _wildcardService.saveWildcard(wildcard);
      await _loadWildcards();
      AppSnackBar.show('성공', '와일드카드 업데이트 완료', backgroundColor: Colors.green, textColor: Colors.white);
    } catch (e) {
      errorMessage.value = '업데이트 실패: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 와일드카드 삭제
  Future<void> deleteWildcard(String name) async {
    try {
      isLoading.value = true;
      await _wildcardService.deleteWildcard(name);
      await _loadWildcards();
      AppSnackBar.show('성공', '__${name}__ 삭제 완료', backgroundColor: Colors.green, textColor: Colors.white);
    } catch (e) {
      errorMessage.value = '삭제 실패: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 와일드카드 활성화/비활성화 토글
  Future<void> toggleWildcard(String name) async {
    final wildcard = wildcards.firstWhereOrNull((w) => w.name == name);
    if (wildcard == null) return;

    final updated = wildcard.copyWith(isEnabled: !wildcard.isEnabled);
    await updateWildcard(updated);
  }

  /// 기본 샘플 와일드카드 생성
  Future<void> createDefaultWildcards() async {
    try {
      isLoading.value = true;
      await _wildcardService.createDefaultWildcards();
      await _loadWildcards();
      AppSnackBar.show('성공', '기본 와일드카드 생성 완료', backgroundColor: Colors.green, textColor: Colors.white);
    } catch (e) {
      errorMessage.value = '생성 실패: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // 프롬프트 파싱 관련
  // ============================================================

  /// 프롬프트에서 와일드카드 치환
  String parsePrompt(String prompt) {
    return _wildcardService.parsePrompt(prompt);
  }

  /// 프롬프트에서 사용된 와일드카드 이름 추출
  List<String> extractWildcardNames(String prompt) {
    return _wildcardService.extractWildcardNames(prompt);
  }

  /// 프롬프트 유효성 검사 (없는 와일드카드 이름 반환)
  List<String> validatePrompt(String prompt) {
    return _wildcardService.validatePrompt(prompt);
  }

  /// 프롬프트 미리보기 (와일드카드 치환 결과)
  String previewPrompt(String prompt) {
    final missing = validatePrompt(prompt);
    if (missing.isNotEmpty) {
      return '⚠️ 없는 와일드카드: ${missing.join(", ")}';
    }
    return parsePrompt(prompt);
  }

  /// 이름으로 와일드카드 조회
  WildcardModel? getWildcard(String name) {
    return _wildcardService.getWildcard(name);
  }

  // ============================================================
  // 편집 관련
  // ============================================================

  /// 편집할 와일드카드 선택
  void selectForEdit(WildcardModel wildcard) {
    selectedWildcard.value = wildcard;
  }

  /// 편집 취소
  void cancelEdit() {
    selectedWildcard.value = null;
  }
}
