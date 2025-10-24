# HomePageController 리팩토링 계획

## 현재 상황
`home_page_controller.dart` 파일이 981줄로, 너무 많은 책임을 가지고 있음.
- 자동 생성 로직
- 이미지 로드/메타데이터 파싱
- 프롬프트 및 캐릭터 관리
- 프리셋 관리
- 이미지 생성
- UI 상태 관리

## 목표
단일 책임 원칙(SRP)에 따라 컨트롤러를 분리하여 유지보수성과 테스트 가능성 향상

---

## 📋 작업 목록

### ✅ Phase 1: 자동 생성 로직 분리
**새 파일**: `lib/application/home/auto_generation_controller.dart`

**이동할 내용**:
- `autoGenerateEnabled` (자동 생성 활성화 여부)
- `autoGenerateSeconds` (자동 생성 대기 시간)
- `autoGenerateRandomDelay` (랜덤 딜레이)
- `remainingSeconds` (남은 시간)
- `_autoGenerateTimer` (타이머)
- `maxAutoGenerateCount` (최대 자동 생성 수)
- `currentAutoGenerateCount` (현재 자동 생성 수)
- `autoGenerateCountController` (입력 컨트롤러)
- `toggleAutoGenerate()` 메서드
- `setAutoGenerateSeconds()` 메서드
- `setAutoGenerateRandomDelay()` 메서드
- `getRandomDelayCalculation()` 메서드
- `_startAutoGenerateTimer()` 메서드
- `_cancelAutoGenerateTimer()` 메서드

**의존성**:
- `FlutterForegroundTask` (포그라운드 서비스)
- `HomePageController.isGenerating` (생성 중 여부 확인)
- `HomePageController.generateImage()` (이미지 생성 트리거)

**작업 순서**:
1. `AutoGenerationController` 클래스 생성
2. 위 필드와 메서드들을 새 컨트롤러로 이동
3. `HomePageController`에서 `AutoGenerationController` 인스턴스 생성
4. `home_page_binding.dart`에 `AutoGenerationController` 바인딩 추가
5. 기존 코드에서 자동 생성 관련 참조를 새 컨트롤러로 변경
6. 테스트 및 검증

---

### ✅ Phase 2: 이미지 로드 및 메타데이터 로직 분리
**새 파일**: `lib/application/home/image_load_controller.dart`

**이동할 내용**:
- `loadedImageBytes` (로드된 이미지 바이트)
- `loadedImageModel` (로드된 이미지 모델)
- `loadImageStatus` (로드 상태 메시지)
- `isExifChecked` (EXIF 체크 여부)
- `loadImageOptions` (로드 옵션 맵)
- `imageCache` (이미지 캐시)
- `getImageFromGallery()` 메서드
- `_checkImageMetadata()` 메서드
- `loadFromImage()` 메서드
- `clearImageDialog()` 메서드
- `cancelImageLoad()` 메서드

**의존성**:
- `ImagePicker` (갤러리 접근)
- `WebPMetadataParser` (메타데이터 파싱)
- `HomeImageController` (이미지 관리)
- `HomeSettingController` (설정 관리)

**작업 순서**:
1. `ImageLoadController` 클래스 생성
2. 위 필드와 메서드들을 새 컨트롤러로 이동
3. `HomePageController`에서 `ImageLoadController` 인스턴스 생성
4. `home_page_binding.dart`에 `ImageLoadController` 바인딩 추가
5. UI에서 이미지 로드 관련 참조를 새 컨트롤러로 변경
6. 테스트 및 검증

---

### ✅ Phase 3: 프롬프트 및 캐릭터 관리 분리
**새 파일**: `lib/application/home/prompt_controller.dart`

**이동할 내용**:
- `positivePromptController` (긍정 프롬프트 텍스트 컨트롤러)
- `negativePromptController` (부정 프롬프트 텍스트 컨트롤러)
- `characterPrompts` (캐릭터 프롬프트 리스트)
- `selectedCharacterIndex` (선택된 캐릭터 인덱스)
- `confirmRemoveIndex` (삭제 확인 플래그)
- `characterPositions` (캐릭터 위치)
- `characterScrollController` (스크롤 컨트롤러)
- `setCharacterPosition()` 메서드
- `onCharaAddButtonTap()` 메서드
- `onCharaRemoveButtonTap()` 메서드
- `onCharaTap()` 메서드

**의존성**:
- `TextEditingController` (Flutter)
- `ScrollController` (Flutter)
- `df.CharacterPrompt` (도메인 모델)

**작업 순서**:
1. `PromptController` 클래스 생성
2. 위 필드와 메서드들을 새 컨트롤러로 이동
3. `HomePageController`에서 `PromptController` 인스턴스 생성
4. `home_page_binding.dart`에 `PromptController` 바인딩 추가
5. UI에서 프롬프트 관련 참조를 새 컨트롤러로 변경
6. `buildSetting()` 메서드에서 프롬프트 데이터 접근 방식 수정
7. 테스트 및 검증

---

### ✅ Phase 4: 프리셋 관리 분리
**새 파일**: `lib/application/home/preset_controller.dart`

**이동할 내용**:
- `loadPreset()` 메서드
- `savePreset()` 메서드
- `loadSetting()` 메서드
- `getPrevSettings()` 메서드

**의존성**:
- `SharedPreferences` (로컬 저장소)
- `HomeSettingController` (설정 관리)
- `df.DiffusionModel` (도메인 모델)

**작업 순서**:
1. `PresetController` 클래스 생성
2. 위 메서드들을 새 컨트롤러로 이동
3. `HomePageController`에서 `PresetController` 인스턴스 생성
4. `home_page_binding.dart`에 `PresetController` 바인딩 추가
5. UI에서 프리셋 관련 참조를 새 컨트롤러로 변경
6. 테스트 및 검증

---

### ✅ Phase 5: HomePageController 슬림화
**수정 파일**: `lib/application/home/home_page_controller.dart`

**남겨둘 내용**:
- `isGenerating` (생성 중 여부)
- `usingModel` (사용 중인 모델)
- `selectedNoiseSchedule` (노이즈 스케줄)
- `anlasLeft` (Anlas 잔여량)
- `isPanelExpanded` (패널 확장 여부)
- `floatingButtonExpanded` (플로팅 버튼 확장)
- `expandHistory` (히스토리 확장)
- `autoSave` (자동 저장)
- `_addQualityTags` (품질 태그 추가)
- `modelNames` (모델 이름 맵)
- `noiseScheduleOptions` (노이즈 스케줄 옵션)
- `generateImage()` 메서드 (핵심 생성 로직)
- `buildSetting()` 메서드 (설정 빌드)
- `initLoading()` 메서드 (초기화)
- `getAnlasRemaining()` 메서드
- `logout()` 메서드
- `onGridTap()` 메서드
- `loadFromHistory()` 메서드
- `addVibeImage()` 메서드
- `getVibeBytes()` 메서드
- `getAspectRatioSize()` 메서드

**작업 순서**:
1. 분리된 컨트롤러들의 인스턴스를 `HomePageController`에 추가
2. 기존 메서드들이 새 컨트롤러들을 참조하도록 수정
3. `generateImage()` 메서드에서 분리된 컨트롤러들의 데이터 사용
4. 불필요한 import 제거
5. 코드 정리 및 주석 추가
6. 전체 테스트

---

### ✅ Phase 6: UI 레이어 업데이트
**수정 파일들**:
- `lib/view/home/home_page.dart`
- `lib/view/home/home_char_prompt.dart`
- `lib/view/home/home_main_prompt.dart`
- `lib/view/home/home_setting.dart`
- `lib/view/home/home_load_image.dart`

**작업 순서**:
1. 각 UI 파일에서 사용하는 컨트롤러 참조 확인
2. `Get.find<>()` 호출을 적절한 컨트롤러로 변경
3. 예: `homePageController.autoGenerateEnabled` → `autoGenerationController.autoGenerateEnabled`
4. 모든 UI 파일 업데이트 완료 후 테스트

---

### ✅ Phase 7: 최종 검증 및 정리
**작업 내용**:
1. 전체 앱 빌드 및 실행 테스트
2. 각 기능별 동작 확인:
   - 이미지 생성
   - 자동 생성
   - 프리셋 저장/로드
   - 이미지 로드
   - 캐릭터 프롬프트 관리
3. 메모리 누수 확인 (dispose 메서드 체크)
4. 불필요한 코드 제거
5. 주석 및 문서화
6. 코드 리뷰

---

## 🎯 기대 효과

1. **유지보수성 향상**: 각 컨트롤러가 명확한 책임을 가짐
2. **테스트 용이성**: 독립적인 단위 테스트 가능
3. **코드 가독성**: 파일당 200-300줄 정도로 관리 가능
4. **재사용성**: 다른 페이지에서도 필요한 컨트롤러만 사용 가능
5. **협업 효율성**: 여러 개발자가 동시에 다른 컨트롤러 작업 가능

---

## ⚠️ 주의사항

1. **의존성 순환 방지**: 컨트롤러 간 순환 참조가 발생하지 않도록 주의
2. **GetX 바인딩**: 모든 새 컨트롤러를 `home_page_binding.dart`에 등록
3. **상태 동기화**: 여러 컨트롤러 간 상태가 일관되게 유지되도록 관리
4. **dispose 처리**: 각 컨트롤러의 리소스를 적절히 해제
5. **점진적 마이그레이션**: 한 번에 하나씩 분리하고 테스트

---

## 📝 작업 진행 상황

- [ ] Phase 1: 자동 생성 로직 분리
- [ ] Phase 2: 이미지 로드 및 메타데이터 로직 분리
- [ ] Phase 3: 프롬프트 및 캐릭터 관리 분리
- [ ] Phase 4: 프리셋 관리 분리
- [ ] Phase 5: HomePageController 슬림화
- [ ] Phase 6: UI 레이어 업데이트
- [ ] Phase 7: 최종 검증 및 정리
