# NAIApp 1.3.99 BETA 피드백 점검

2026-04-26 기준 코드 확인 결과입니다.

## 우선 수정 필요

### 1. 프리셋 저장 시 와일드카드가 치환 결과로 저장됨

제보:
- "와일드카드를 넣은 채로 프리셋을 저장하면 와일드 카드가 아니고 와일드 카드 내용 중 랜덤으로 저장되네요"

확인:
- `HomePageController.savePreset()`이 `buildSetting()` 반환값을 그대로 프리셋 저장에 넘깁니다.
- `buildSetting()` 내부에서는 원본 프롬프트(`originalPos`, `originalNeg`, `charPromOriginal`)를 별도로 만들고 `lastSettings`에는 원본을 저장합니다.
- 하지만 `buildSetting()`의 반환값은 API 요청용 설정입니다. 이 설정은 `wildcardController.parsePrompt()`가 적용된 뒤라 `__name__`이 이미 랜덤 결과로 치환되어 있습니다.

관련 파일:
- `flutter/lib/application/home/home_page_controller.dart`
  - `savePreset()`
  - `buildSetting()`
- `flutter/lib/application/home/home_setting_controller.dart`
  - `savePreset()`
  - `_savePresetFinal()`

수정 방향:
- `buildSetting()`을 "API 요청용 빌드"와 "저장용 빌드"로 분리합니다.
- 예: `buildSetting({bool preserveWildcards = false})`
  - 이미지 생성: `preserveWildcards: false`
  - 프리셋 저장/lastSettings 저장: `preserveWildcards: true`
- 또는 `buildSettingPair()`처럼 `{requestSetting, storageSetting}`을 반환하게 해서 같은 입력에서 두 설정을 동시에 만들도록 정리합니다.

검증:
- 메인 프롬프트 `1girl, __hair_color__`
- 캐릭터 프롬프트 `__pose__`
- 프리셋 저장 후 앱 재시작/프리셋 로드
- UI 입력창과 저장 JSON 모두 `__hair_color__`, `__pose__`가 유지되어야 합니다.

### 2. 큰 와일드카드 파일에서 앱 종료/재실행 불가 가능성

제보:
- "와카 크기가 일정 이상 넘어가면 앱 튕김"
- "다시 설치하는 방법 이외에는 다시 안 켜지고 기존 데이터가 날아감"

확인:
- `WildcardService`가 와일드카드 전체 내용을 `SharedPreferences`의 `wildcard_list`에 JSON 문자열 리스트로 저장합니다.
- 앱 시작 시 `WildcardController.onInit()` -> `WildcardService.initialize()` -> `loadAllWildcards()`가 모든 와일드카드를 즉시 JSON decode하여 메모리 캐시에 올립니다.
- `_wildcardDirectory`는 정의되어 있지만 실제 저장에 사용되지 않습니다.
- 큰 txt를 임포트하면 SharedPreferences XML/플랫폼 채널/초기 JSON decode 비용이 커져 시작 시점에서 크래시가 날 수 있습니다.

관련 파일:
- `flutter/lib/infra/service/wildcard_service.dart`
- `flutter/lib/application/wildcard/wildcard_controller.dart`
- `flutter/lib/domain/wildcard/wildcard_model.dart`
- `flutter/lib/view/wildcard/wildcard_page.dart`

수정 방향:
- 와일드카드 본문은 앱 문서 디렉토리의 txt/json 파일로 저장합니다.
- SharedPreferences에는 이름, 활성화 여부, 파일 경로, 옵션 개수, 수정일 같은 가벼운 인덱스만 저장합니다.
- 앱 시작 시 전체 옵션을 모두 로드하지 말고, 파싱 또는 편집/미리보기 시 필요한 와일드카드만 lazy load합니다.
- 기존 `wildcard_list` 데이터는 최초 실행 때 파일 저장소로 마이그레이션하고, 성공 후 prefs 본문을 제거합니다.
- 편집/미리보기 다이얼로그는 큰 파일일 때 전체 TextField/ListView를 바로 만들지 말고 검색/페이지네이션/외부 편집 또는 상한 경고를 둡니다.

검증:
- 1천/1만/5만 줄 txt 임포트
- 앱 강제 종료 후 재시작
- 와일드카드 목록 진입, 프롬프트 치환, 편집/미리보기 동작

### 3. NAI3에서 레퍼런스/Vibe 관련 오류

제보:
- "nai3가 안되는 거 고쳐주실 수 있을까요? nai3는 레퍼런스를 입력할 수 없다고 뜹니다"

확인:
- `buildSetting()`은 모델이 `nai-diffusion-3`이어도 `reference_image_multiple`, `reference_strength_multiple`, Director Tool 관련 파라미터를 조건 없이 포함할 수 있습니다.
- `getVibeBytes()`도 현재 모델 제한 없이 `vibeParse()`를 호출합니다.
- UI에서도 모델 선택 시 V3에서 Vibe/Director Tool을 비활성화하거나 제거하는 흐름이 보이지 않습니다.

관련 파일:
- `flutter/lib/application/home/home_page_controller.dart`
- `flutter/lib/application/home/home_image_controller.dart`
- `flutter/lib/view/home/home_load_image.dart`
- `flutter/lib/view/home/home_director_tool.dart`
- `flutter/lib/view/home/home_appBar.dart`

수정 방향:
- 모델별 지원 기능을 명시하는 헬퍼를 둡니다.
  - 예: `supportsVibeTransfer(model)`, `supportsDirectorTool(model)`
- `nai-diffusion-3` 선택 시:
  - 기존 Vibe/Director 참조가 있으면 경고 후 제거하거나, 생성 요청에서 제외합니다.
  - Vibe/Director UI를 disabled 처리하고 "V3에서는 레퍼런스 미지원" 안내를 보여줍니다.
  - `getVibeBytes()`는 지원 모델에서만 호출합니다.
- 이미지 메타데이터 로드 시 V3 이미지에 Vibe 옵션을 적용하지 않도록 방어합니다.

검증:
- V3 + 레퍼런스 없음: 정상 생성
- V3 + Vibe 이미지 남아 있음: 요청 전에 제거/차단
- V4/V4.5 + Vibe/Director: 기존 동작 유지

### 4. 캐릭터 1 프롬프트가 다른 캐릭터 표시 영역에 보이는 문제

제보:
- "캐릭프롬 표시되는거 캐릭터 1로 고정"
- "캐릭1에 있던게 캐릭2 프롬창에 뜸. 입력칸 열면 새로운 것 같은데 입력칸 닫으면 다시 캐릭1 프롬으로 표시"

확인:
- 캐릭터 표시 영역의 `WildcardTextField`는 선택 캐릭터가 바뀔 때 다른 `TextEditingController`를 받습니다.
- 기존 `WildcardTextField`는 `initState()`에서만 원본 컨트롤러와 내부 하이라이트 컨트롤러를 연결했다면, controller 교체 시 이전 텍스트가 남을 수 있습니다.
- 현재 작업트리에는 `didUpdateWidget()`에서 리스너를 교체하고 내부 텍스트를 새 controller 값으로 동기화하는 패치가 들어와 있습니다. 이 제보를 겨냥한 수정으로 보입니다.

관련 파일:
- `flutter/lib/view/core/util/wildcard_highlight_controller.dart`
- `flutter/lib/view/home/home_char_prompt.dart`

남은 확인:
- 현재 패치가 실제 빌드에 포함된 APK인지 확인해야 합니다.
- 선택 캐릭터 변경, 캐릭터 삭제, 이미지 메타데이터 로드, 프리셋 로드 후 표시가 모두 바뀌는지 테스트가 필요합니다.

추가 개선:
- `WildcardTextField`에 `ValueKey(controller)` 또는 캐릭터 인덱스 기반 key를 주면 Flutter 위젯 재사용으로 인한 표시 꼬임을 더 줄일 수 있습니다.
- `TextEditingController`를 `Map<String, dynamic>`에 넣는 구조는 장기적으로 버그를 만들기 쉬우므로 `CharacterPromptEditorState` 같은 타입으로 분리하는 것이 좋습니다.

## 기능 요청/UX 개선으로 분류

### 프리셋 덮어쓰기

제보:
- "프리셋 덮어쓰기 기능도 만들어줄 수 있어?"

현재:
- 같은 이름을 입력하면 내부적으로 덮어쓸 수는 있지만, UX상 "현재 프리셋 덮어쓰기" 버튼이나 확인 흐름이 없습니다.

수정 방향:
- 최근 프리셋이 선택되어 있으면 `덮어쓰기` 버튼을 노출합니다.
- 프리셋 카드 long press 메뉴를 `로드 / 덮어쓰기 / 삭제 / 이름 변경`으로 확장합니다.

### 이미지 뷰어 모드 툴바 숨김

제보:
- "이미지 뷰어모드에서 상단이랑 중단에 툴바 안보이게"

수정 방향:
- 이미지 뷰어 페이지에 immersive toggle 상태를 추가합니다.
- 이미지 탭 시 toolbar overlay 표시/숨김, 뒤로가기나 저장 버튼 접근성 유지가 필요합니다.

### 저장 경로 변경

제보:
- "저장 경로 변경 가능한가요?"

수정 방향:
- Android 10+ scoped storage 정책을 고려해야 합니다.
- `ACTION_OPEN_DOCUMENT_TREE` 또는 MediaStore 기반 저장 위치 선택을 검토합니다.
- 현재 `ImageSaveManager` 저장 경로와 갤러리 저장 방식을 먼저 확인한 뒤 설계합니다.

### 와일드카드 한글 이름

제보:
- "__제목__은 안 되고 영어만 인식"

현재:
- 이름 검증과 파싱 정규식이 영문/숫자/언더스코어만 허용합니다.
- 의도된 제한이면 도움말에 더 명확히 써야 합니다.

수정 방향:
- 한글 이름을 지원하려면 정규식을 Unicode letter 기반으로 확장하고 파일명/저장소 호환성을 점검합니다.
- 지원하지 않을 거라면 생성/도움말/오류 메시지에 "와일드카드 이름은 영문/숫자/_만"을 더 잘 노출합니다.

## 기타 확인 사항

### Firebase Functions entryPoint

확인:
- 루트 `firebase.json`의 `entryPoint`는 `get_novelai_tokens`입니다.
- 실제 Python 함수명은 `get_novelai_key`입니다.

수정 방향:
- 현재 배포에 사용하는 firebase.json이 루트 파일이라면 entryPoint를 실제 함수명에 맞춰야 합니다.
- FlutterFire 설정 파일인 `flutter/firebase.json`과 혼동하지 않도록 배포 문서를 정리합니다.

## 추천 수정 순서

1. 프리셋 와일드카드 원본 저장 문제 수정
2. NAI3에서 Vibe/Director 파라미터 차단
3. 큰 와일드카드 저장소를 SharedPreferences에서 파일 기반으로 마이그레이션
4. 캐릭터 프롬프트 표시 패치가 포함된 APK 재빌드/배포 검증
5. 프리셋 덮어쓰기 UX 추가
6. 저장 경로/뷰어 툴바/한글 와일드카드 이름 같은 UX 요청 처리

