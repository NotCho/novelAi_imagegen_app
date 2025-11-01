# Phase 1: 자동 생성 로직 분리 - 변경 사항 요약

## 📦 새로 생성된 파일

### `lib/application/home/auto_generation_controller.dart`
**책임**: 자동 이미지 생성 타이머 및 설정 관리

**이동된 필드**:
- `autoGenerateEnabled` - 자동 생성 활성화 여부
- `autoGenerateSeconds` - 자동 생성 대기 시간 (초)
- `autoGenerateRandomDelay` - 랜덤 딜레이 비율
- `remainingSeconds` - 남은 시간 표시
- `maxAutoGenerateCount` - 최대 자동 생성 횟수
- `currentAutoGenerateCount` - 현재 자동 생성 횟수
- `autoGenerateCountController` - 횟수 입력 텍스트 컨트롤러
- `_autoGenerateTimer` - 내부 타이머 객체

**이동된 메서드**:
- `toggleAutoGenerate()` - 자동 생성 ON/OFF
- `setAutoGenerateSeconds(double)` - 대기 시간 설정
- `setAutoGenerateRandomDelay(double)` - 랜덤 딜레이 설정
- `getRandomDelayCalculation()` - 랜덤 딜레이 계산 결과 문자열
- `startAutoGenerateTimer()` - 타이머 시작 (public)
- `cancelAutoGenerateTimer()` - 타이머 취소 (public)
- `_startAutoGenerateTimer()` - 타이머 시작 (private)
- `_cancelAutoGenerateTimer()` - 타이머 취소 (private)

---

## 🔧 수정된 파일

### 1. `lib/view/home/home_page_binding.dart`
**변경 내용**:
```dart
// 추가됨
import '../../application/home/auto_generation_controller.dart';

// dependencies() 메서드에 추가
Get.lazyPut<AutoGenerationController>(() => AutoGenerationController());
```

**목적**: AutoGenerationController를 GetX 의존성 주입 시스템에 등록

---

### 2. `lib/application/home/home_page_controller.dart`
**변경 내용**:

#### 추가된 의존성:
```dart
import 'package:naiapp/application/home/auto_generation_controller.dart';

// 컨트롤러 인스턴스 추가
AutoGenerationController autoGenerationController = 
    Get.find<AutoGenerationController>();
```

#### 제거된 필드:
- `autoGenerateEnabled`
- `autoGenerateSeconds`
- `autoGenerateRandomDelay`
- `remainingSeconds`
- `_autoGenerateTimer`
- `maxAutoGenerateCount`
- `currentAutoGenerateCount`
- `autoGenerateCountController`

#### 제거된 메서드:
- `toggleAutoGenerate()`
- `setAutoGenerateSeconds()`
- `setAutoGenerateRandomDelay()`
- `getRandomDelayCalculation()`
- `_startAutoGenerateTimer()`
- `_cancelAutoGenerateTimer()`

#### 수정된 메서드:

**`initLoading()`**:
```dart
// 변경 전
if (autoGenerateEnabled.value) {

// 변경 후
if (autoGenerationController.autoGenerateEnabled.value) {
```

**`generateImage()`**:
```dart
// 변경 전
_cancelAutoGenerateTimer();
if (autoGenerateEnabled.value) {
    _startAutoGenerateTimer();
    currentAutoGenerateCount.value++;
    if (maxAutoGenerateCount.value > 0) {
        if (currentAutoGenerateCount.value >= maxAutoGenerateCount.value) {
            autoGenerateEnabled.value = false;
            _cancelAutoGenerateTimer();

// 변경 후
autoGenerationController.cancelAutoGenerateTimer();
if (autoGenerationController.autoGenerateEnabled.value) {
    autoGenerationController.startAutoGenerateTimer();
    autoGenerationController.currentAutoGenerateCount.value++;
    if (autoGenerationController.maxAutoGenerateCount.value > 0) {
        if (autoGenerationController.currentAutoGenerateCount.value >= 
            autoGenerationController.maxAutoGenerateCount.value) {
            autoGenerationController.autoGenerateEnabled.value = false;
            autoGenerationController.cancelAutoGenerateTimer();
```

---

### 3. `lib/view/home/home_page.dart`
**변경 내용**: 모든 자동 생성 관련 UI 참조를 새 컨트롤러로 변경

#### 자동 생성 스위치:
```dart
// 변경 전
value: controller.autoGenerateEnabled.value,
onChanged: (value) => controller.toggleAutoGenerate(),

// 변경 후
value: controller.autoGenerationController.autoGenerateEnabled.value,
onChanged: (value) => controller.autoGenerationController.toggleAutoGenerate(),
```

#### 남은 시간 표시:
```dart
// 변경 전
(controller.autoGenerateEnabled.value)
    ? '${controller.remainingSeconds.value.round()}초'
    : '${controller.autoGenerateSeconds.value.round()}초',

// 변경 후
(controller.autoGenerationController.autoGenerateEnabled.value)
    ? '${controller.autoGenerationController.remainingSeconds.value.round()}초'
    : '${controller.autoGenerationController.autoGenerateSeconds.value.round()}초',
```

#### 횟수 제한 표시:
```dart
// 변경 전
if (controller.maxAutoGenerateCount.value != 0)
    Text('횟수 제한\n${controller.currentAutoGenerateCount}/${controller.maxAutoGenerateCount}회',

// 변경 후
if (controller.autoGenerationController.maxAutoGenerateCount.value != 0)
    Text('횟수 제한\n${controller.autoGenerationController.currentAutoGenerateCount}/${controller.autoGenerationController.maxAutoGenerateCount}회',
```

#### 설정 다이얼로그:
```dart
// 변경 전
Slider(
    value: controller.autoGenerateSeconds.value,
    onChanged: (value) => controller.setAutoGenerateSeconds(value),
)

// 변경 후
Slider(
    value: controller.autoGenerationController.autoGenerateSeconds.value,
    onChanged: (value) => controller.autoGenerationController.setAutoGenerateSeconds(value),
)
```

#### 횟수 입력 필드:
```dart
// 변경 전
TextField(controller: controller.autoGenerateCountController,)
controller.maxAutoGenerateCount.value = 
    int.tryParse(controller.autoGenerateCountController.text) ?? 0;

// 변경 후
TextField(controller: controller.autoGenerationController.autoGenerateCountController,)
controller.autoGenerationController.maxAutoGenerateCount.value = 
    int.tryParse(controller.autoGenerationController.autoGenerateCountController.text) ?? 0;
```

---

### 4. `lib/view/home/home_setting.dart`
**변경 내용**: 순차 크기 변경 기능의 자동 생성 상태 확인

```dart
// 변경 전
color: controller.homeSettingController.autoChangeSize.value
    ? (controller.autoGenerateEnabled.value)
        ? SkeletonColorScheme.accentColor
        : SkeletonColorScheme.negativeColor

// 변경 후
color: controller.homeSettingController.autoChangeSize.value
    ? (controller.autoGenerationController.autoGenerateEnabled.value)
        ? SkeletonColorScheme.accentColor
        : SkeletonColorScheme.negativeColor
```

---

### 5. `lib/application/image/image_page_controller.dart`
**변경 내용**: 선택 모드 활성화 시 자동 생성 비활성화

```dart
// 변경 전
if (homePageController.autoGenerateEnabled.value) {
    homePageController.autoGenerateEnabled.value = false;

// 변경 후
if (homePageController.autoGenerationController.autoGenerateEnabled.value) {
    homePageController.autoGenerationController.autoGenerateEnabled.value = false;
```

---

## 🔍 GetX 상태 관리 테스트 시나리오

### 테스트 1: 자동 생성 토글
**목적**: autoGenerateEnabled 상태 변경이 UI에 반영되는지 확인

**테스트 방법**:
1. 홈 화면에서 자동 생성 스위치를 ON으로 변경
2. 확인 사항:
   - ✅ 스위치가 활성화 색상(accentColor)으로 변경
   - ✅ 타이머 표시가 "남은 시간"으로 변경
   - ✅ 포그라운드 서비스 알림이 표시됨
   - ✅ 설정 화면의 "순차 크기 변경" 아이콘 색상이 변경됨

**예상 동작**:
```dart
// AutoGenerationController
autoGenerateEnabled.toggle() // false → true
→ FlutterForegroundTask.startService()
→ _startAutoGenerateTimer()
→ remainingSeconds 카운트다운 시작
```

---

### 테스트 2: 타이머 카운트다운
**목적**: remainingSeconds가 실시간으로 업데이트되는지 확인

**테스트 방법**:
1. 자동 생성을 5초로 설정
2. 자동 생성 활성화
3. 확인 사항:
   - ✅ 화면에 "5초", "4초", "3초"... 순서로 표시
   - ✅ 0초가 되면 generateImage() 호출
   - ✅ 이미지 생성 후 다시 타이머 시작

**예상 동작**:
```dart
// Timer.periodic 실행
remainingSeconds.value-- // 5 → 4 → 3 → 2 → 1 → 0
→ homePageController.generateImage()
→ _startAutoGenerateTimer() // 다시 시작
```

---

### 테스트 3: 대기 시간 변경
**목적**: autoGenerateSeconds 변경이 즉시 반영되는지 확인

**테스트 방법**:
1. 자동 생성 활성화 상태에서 설정 다이얼로그 열기
2. 슬라이더로 대기 시간을 10초로 변경
3. 확인 사항:
   - ✅ 슬라이더 값이 즉시 업데이트
   - ✅ 다이얼로그의 텍스트가 "10초 마다 자동 생성"으로 변경
   - ✅ 타이머가 재시작되어 10초부터 카운트다운

**예상 동작**:
```dart
// Slider onChanged
setAutoGenerateSeconds(10.0)
→ autoGenerateSeconds.value = 10.0
→ _startAutoGenerateTimer() // 타이머 재시작
```

---

### 테스트 4: 랜덤 딜레이 계산
**목적**: autoGenerateRandomDelay 변경이 계산에 반영되는지 확인

**테스트 방법**:
1. 대기 시간 10초, 랜덤 딜레이 20% 설정
2. 확인 사항:
   - ✅ "±2.00초의 랜덤 딜레이" 텍스트 표시
   - ✅ 실제 타이머가 8~12초 사이의 랜덤 값으로 시작

**예상 동작**:
```dart
// getRandomDelayCalculation()
randomRange = 10 * 0.2 = 2.0
return "±2.00초"

// _startAutoGenerateTimer()
randomOffset = Random(-2.0 ~ +2.0)
finalSeconds = 10 + randomOffset // 8~12초
```

---

### 테스트 5: 최대 횟수 제한
**목적**: maxAutoGenerateCount 도달 시 자동 중지되는지 확인

**테스트 방법**:
1. 최대 횟수를 3회로 설정
2. 자동 생성 활성화
3. 확인 사항:
   - ✅ "횟수 제한 0/3회" → "1/3회" → "2/3회" → "3/3회" 표시
   - ✅ 3회 도달 시 자동 생성이 자동으로 비활성화
   - ✅ 스낵바 메시지 표시

**예상 동작**:
```dart
// generateImage() 완료 후
currentAutoGenerateCount.value++ // 0 → 1 → 2 → 3
if (currentAutoGenerateCount.value >= maxAutoGenerateCount.value) {
    autoGenerateEnabled.value = false
    cancelAutoGenerateTimer()
    Get.snackbar("최대 자동 생성 이미지 수에 도달...")
}
```

---

### 테스트 6: 이미지 선택 모드와의 상호작용
**목적**: 다른 컨트롤러에서 AutoGenerationController 접근이 정상 작동하는지 확인

**테스트 방법**:
1. 자동 생성 활성화
2. 이미지 페이지로 이동
3. 선택 모드 활성화
4. 확인 사항:
   - ✅ 자동 생성이 자동으로 비활성화
   - ✅ "성능을 위해 이미지 자동 생성이 비활성화됩니다" 스낵바 표시
   - ✅ 홈 화면으로 돌아가면 스위치가 OFF 상태

**예상 동작**:
```dart
// ImagePageController
homePageController.autoGenerationController.autoGenerateEnabled.value = false
→ AutoGenerationController의 상태 변경
→ 모든 Obx 위젯이 자동 업데이트
```

---

### 테스트 7: 컨트롤러 생명주기
**목적**: 컨트롤러가 올바르게 생성/해제되는지 확인

**테스트 방법**:
1. 홈 페이지 진입 (컨트롤러 생성)
2. 자동 생성 활성화
3. 다른 페이지로 이동
4. 다시 홈 페이지로 돌아오기
5. 확인 사항:
   - ✅ 타이머가 계속 실행 중
   - ✅ 설정 값들이 유지됨
   - ✅ 앱 종료 시 타이머가 정리됨

**예상 동작**:
```dart
// HomePageBinding
Get.lazyPut<AutoGenerationController>() // 첫 접근 시 생성
→ 싱글톤으로 유지
→ onClose() 호출 시 타이머 정리
```

---

## ✅ GetX 상태 관리 체크리스트

### Reactive 변수 (Rx)
- [x] `autoGenerateEnabled.obs` - UI 자동 업데이트
- [x] `autoGenerateSeconds.obs` - 슬라이더 양방향 바인딩
- [x] `autoGenerateRandomDelay.obs` - 슬라이더 양방향 바인딩
- [x] `remainingSeconds.obs` - 타이머 카운트다운 표시
- [x] `maxAutoGenerateCount.obs` - 횟수 제한 표시
- [x] `currentAutoGenerateCount.obs` - 현재 횟수 표시

### 의존성 주입
- [x] `Get.lazyPut<AutoGenerationController>()` - 지연 로딩
- [x] `Get.find<AutoGenerationController>()` - 다른 컨트롤러에서 접근
- [x] HomePageBinding에 등록됨

### 생명주기 관리
- [x] `onClose()` - 타이머 정리
- [x] `TextEditingController.dispose()` - 메모리 누수 방지

### 컨트롤러 간 통신
- [x] HomePageController → AutoGenerationController (generateImage 트리거)
- [x] AutoGenerationController → HomePageController (타이머 완료 시)
- [x] ImagePageController → AutoGenerationController (선택 모드 시)

---

## 🎯 리팩토링 효과

### Before (HomePageController)
- **라인 수**: 981줄
- **책임**: 8가지 (생성, 자동생성, 이미지로드, 프롬프트, 프리셋, 설정, UI상태, 히스토리)

### After
- **HomePageController**: ~900줄 (약 80줄 감소)
- **AutoGenerationController**: 140줄 (새로 생성)
- **책임 분리**: 자동 생성 로직 완전 독립

### 장점
1. ✅ **단일 책임 원칙**: 각 컨트롤러가 명확한 책임
2. ✅ **테스트 용이성**: AutoGenerationController만 독립 테스트 가능
3. ✅ **재사용성**: 다른 페이지에서도 자동 생성 기능 사용 가능
4. ✅ **유지보수성**: 자동 생성 관련 버그 수정 시 한 곳만 수정
5. ✅ **가독성**: 코드 의도가 명확해짐

---

## 🚨 주의사항

### GetX 의존성 순서
```dart
// ✅ 올바른 순서
Get.lazyPut<HomeImageController>(() => HomeImageController());
Get.lazyPut<HomeSettingController>(() => HomeSettingController());
Get.lazyPut<AutoGenerationController>(() => AutoGenerationController());
Get.put(HomePageController()); // AutoGenerationController를 찾을 수 있음
```

### 순환 참조 방지
- AutoGenerationController → HomePageController (generateImage 호출)
- HomePageController → AutoGenerationController (상태 확인)
- ✅ 순환 참조 없음 (단방향 의존성)

### 타이머 정리
- ✅ `onClose()`에서 `_autoGenerateTimer?.cancel()` 호출
- ✅ 메모리 누수 방지

---

## 📊 다음 단계 (Phase 2)

이미지 로드 및 메타데이터 로직 분리 예정:
- `ImageLoadController` 생성
- `loadedImageBytes`, `loadedImageModel` 이동
- `getImage