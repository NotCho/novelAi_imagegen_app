import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/wildcard/wildcard_model.dart';

/// 와일드카드 파일 관리 및 프롬프트 파싱 서비스
class WildcardService {
  static const String _wildcardListKey = 'wildcard_list';
  static const String _wildcardDirName = 'wildcards';

  final SharedPreferences _prefs;
  final Random _random = Random();

  /// 메모리 캐시 (빠른 접근용)
  Map<String, WildcardModel> _wildcardCache = {};

  WildcardService(this._prefs);

  // ============================================================
  // 디렉토리/파일 관리
  // ============================================================

  /// 와일드카드 저장 디렉토리 경로 반환
  Future<Directory> get _wildcardDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final wildcardDir = Directory('${appDir.path}/$_wildcardDirName');
    if (!await wildcardDir.exists()) {
      await wildcardDir.create(recursive: true);
    }
    return wildcardDir;
  }

  // ============================================================
  // 와일드카드 CRUD
  // ============================================================

  /// 모든 와일드카드 목록 로드
  Future<List<WildcardModel>> loadAllWildcards() async {
    final jsonList = _prefs.getStringList(_wildcardListKey) ?? [];
    final wildcards = <WildcardModel>[];

    for (final jsonStr in jsonList) {
      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        final wildcard = WildcardModel.fromJson(json);
        wildcards.add(wildcard);
        _wildcardCache[wildcard.name] = wildcard;
      } catch (e) {
        // 파싱 에러 무시
        print('와일드카드 파싱 에러: $e');
      }
    }

    return wildcards;
  }

  /// 와일드카드 저장
  Future<void> saveWildcard(WildcardModel wildcard) async {
    final wildcards = await loadAllWildcards();

    // 기존 항목 업데이트 또는 새로 추가
    final existingIndex = wildcards.indexWhere((w) => w.name == wildcard.name);
    if (existingIndex >= 0) {
      wildcards[existingIndex] = wildcard;
    } else {
      wildcards.add(wildcard);
    }

    // 캐시 업데이트
    _wildcardCache[wildcard.name] = wildcard;

    // 저장
    await _saveWildcardList(wildcards);
  }

  /// 와일드카드 삭제
  Future<void> deleteWildcard(String name) async {
    final wildcards = await loadAllWildcards();
    wildcards.removeWhere((w) => w.name == name);
    _wildcardCache.remove(name);
    await _saveWildcardList(wildcards);
  }

  /// 와일드카드 목록을 SharedPreferences에 저장
  Future<void> _saveWildcardList(List<WildcardModel> wildcards) async {
    final jsonList = wildcards.map((w) => jsonEncode(w.toJson())).toList();
    await _prefs.setStringList(_wildcardListKey, jsonList);
  }

  /// 이름으로 와일드카드 조회
  WildcardModel? getWildcard(String name) {
    return _wildcardCache[name];
  }

  // ============================================================
  // 파일 임포트
  // ============================================================

  /// 텍스트 파일에서 와일드카드 임포트
  /// [filePath] 외부 파일 경로
  /// [name] 와일드카드 이름 (null이면 파일명에서 추출)
  Future<WildcardModel> importFromFile(String filePath, {String? name}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('파일을 찾을 수 없습니다: $filePath');
    }

    final content = await file.readAsString();
    final wildcardName = name ?? _extractNameFromPath(filePath);
    final wildcard = WildcardModel.fromText(wildcardName, content);

    await saveWildcard(wildcard);
    return wildcard;
  }

  /// 텍스트 내용에서 직접 와일드카드 생성
  Future<WildcardModel> createFromText(String name, String content) async {
    final wildcard = WildcardModel.fromText(name, content);
    await saveWildcard(wildcard);
    return wildcard;
  }

  /// 파일 경로에서 이름 추출 (확장자 제외)
  String _extractNameFromPath(String filePath) {
    final fileName = filePath.split('/').last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
  }

  // ============================================================
  // 프롬프트 파싱 (핵심 로직)
  // ============================================================

  /// 프롬프트에서 __name__ 패턴을 찾아 랜덤 옵션으로 치환
  /// 중첩 와일드카드도 지원 (최대 10단계)
  /// 가중치 기반 랜덤 선택 지원
  /// 없거나 비활성화된 와일드카드는 빈 문자열로 치환
  String parsePrompt(String prompt, {int maxDepth = 10}) {
    if (maxDepth <= 0) return prompt;

    // __name__ 패턴 찾기
    final pattern = RegExp(r'__([a-zA-Z0-9_]+)__');
    String result = prompt;

    while (pattern.hasMatch(result) && maxDepth > 0) {
      result = result.replaceAllMapped(pattern, (match) {
        final wildcardName = match.group(1)!;
        final wildcard = _wildcardCache[wildcardName];

        // 와일드카드가 없거나 비활성화되면 빈 문자열로 치환
        if (wildcard == null || !wildcard.isEnabled) {
          return '';
        }

        // 옵션이 비어있으면 빈 문자열
        if (wildcard.weightedOptions.isEmpty) {
          return '';
        }

        // 가중치 기반 랜덤 옵션 선택
        return wildcard.getRandomOption();
      });
      maxDepth--;
    }

    // 연속된 쉼표/공백 정리 (예: "1girl, , smile" -> "1girl, smile")
    result = result.replaceAll(RegExp(r',\s*,'), ',');
    result = result.replaceAll(RegExp(r',\s*$'), ''); // 끝에 쉼표 제거
    result = result.replaceAll(RegExp(r'^\s*,'), ''); // 앞에 쉼표 제거
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim(); // 연속 공백 정리

    return result;
  }

  /// 프롬프트에서 사용된 와일드카드 이름 목록 추출
  List<String> extractWildcardNames(String prompt) {
    final pattern = RegExp(r'__([a-zA-Z0-9_]+)__');
    final matches = pattern.allMatches(prompt);
    return matches.map((m) => m.group(1)!).toSet().toList();
  }

  /// 프롬프트의 와일드카드 유효성 검사
  /// 없는 와일드카드 이름 목록 반환
  List<String> validatePrompt(String prompt) {
    final usedNames = extractWildcardNames(prompt);
    return usedNames.where((name) => !_wildcardCache.containsKey(name)).toList();
  }

  // ============================================================
  // 샘플 와일드카드 생성 (초기 설정용)
  // ============================================================

  /// 기본 샘플 와일드카드 생성
  Future<void> createDefaultWildcards() async {
    // 텍스트 형식으로 샘플 정의 (가중치 포함 예시)
    final samples = {
      'hair_color': '''
black hair: 150
blonde hair: 100
silver hair: 80
white hair: 60
pink hair: 50
blue hair: 50
red hair: 40
brown hair: 100
purple hair: 30
green hair: 20
''',
      'eye_color': '''
blue eyes: 100
red eyes: 80
green eyes: 60
purple eyes: 50
yellow eyes: 40
brown eyes: 100
heterochromia: 20
golden eyes: 30
''',
      'outfit': '''
school uniform: 100
sailor uniform: 80
blazer: 60
maid outfit: 50
dress: 100
casual clothes: 120
sweater: 80
hoodie: 70
kimono: 40
military uniform: 30
''',
      'pose': '''
standing: 150
sitting: 100
lying down: 60
walking: 50
running: 30
jumping: 20
leaning forward: 40
arms behind back: 50
hand on hip: 60
crossed arms: 70
''',
      'expression': '''
smile: 200
grin: 80
serious: 100
embarrassed: 60
angry: 40
sad: 30
surprised: 50
sleepy: 30
crying: 20
laughing: 60
''',
      'background': '''
simple background: 150
white background: 100
gradient background: 80
outdoor: 100
indoor: 100
classroom: 60
bedroom: 50
city: 70
forest: 50
beach: 40
night sky: 60
''',
    };

    for (final entry in samples.entries) {
      final wildcard = WildcardModel.fromText(entry.key, entry.value);
      await saveWildcard(wildcard);
    }
  }

  /// 캐시 초기화 (앱 시작 시 호출)
  Future<void> initialize() async {
    await loadAllWildcards();
  }

  /// 캐시 클리어
  void clearCache() {
    _wildcardCache.clear();
  }
}
