# NovelAI Image Generator App - 배포 가이드 (Deployment Guide)

이 문서는 NovelAI Image Generator Flutter 애플리케이션의 빌드 및 Firebase 배포 프로세스를 설명합니다. 본 프로젝트는 빌드, 에셋 동기화, Firebase Storage 업로드, 그리고 Firebase Remote Config(원격 구성) 업데이트까지의 전 과정을 자동화하는 쉘 스크립트를 제공합니다.

---

## 1. 사전 준비 사항 (Prerequisites)

배포 작업을 수행할 개발자 환경에는 아래 도구들과 권한 설정이 필요합니다.

### 1.1 필수 도구 설치
* **Flutter SDK**: 최신 안정화 버전
* **Firebase CLI (`firebase-tools`)**: Firebase Storage 업로드용
* **Google Cloud SDK (`gcloud`, `gsutil`)**: Remote Config 갱신 및 Storage 관리용
* **기타 유틸리티**: `jq` (JSON 파싱용), `curl`, `uuidgen`

macOS 환경 설치 예시 (Homebrew 사용):
```bash
brew install firebase-cli google-cloud-sdk jq
```

### 1.2 계정 및 인증 설정
1. **Firebase CLI 로그인**:
   ```bash
   firebase login
   ```
2. **Google Cloud Default Credentials 로그인** (Remote Config API 권한 획득용):
   ```bash
   gcloud auth application-default login
   ```
3. **서비스 계정 키 파일**:
   프로젝트 루트 디렉토리에 서비스 계정 키 파일 `nai-login-b8ba8d8f1788.json`이 존재해야 합니다. 스크립트 실행 시 해당 키 파일의 경로를 자동으로 감지하여 Google Cloud API 인증에 사용합니다.

---

## 2. 배포 스크립트 종류

배포 스크립트는 `flutter` 디렉토리 내에 위치해 있습니다.

### 2.1 `update_app.sh` (빌드 + 배포 통합)
* **목적**: 코드를 새로 빌드하고 Firebase에 즉시 배포할 때 사용합니다.
* **주요 동작**:
  1. `flutter clean` 및 `flutter pub get`으로 개발 환경 정리
  2. 최상위 `changes.json` 파일을 Flutter 에셋 경로(`flutter/assets/changes.json`)로 자동 복사하여 앱 내 릴리즈 노트 최신화
  3. `flutter build apk --release` 빌드 수행
  4. 생성된 APK를 Firebase Storage에 업로드하고 다운로드 URL 발급
  5. Firebase Remote Config 변수 자동 업데이트

### 2.2 `deploy_app.sh` (배포 전용)
* **목적**: 이미 빌드된 APK 파일이 존재할 때, 빌드 과정을 생략하고 업로드 및 Remote Config 업데이트만 수행할 때 사용합니다.
* **주요 동작**:
  1. 지정된 APK 경로 유효성 검증
  2. APK를 Firebase Storage에 업로드하고 다운로드 URL 발급
  3. Firebase Remote Config 변수 자동 업데이트

---

## 3. 스크립트 옵션 및 사용법

### 3.1 공통 옵션
* `--notes-text "<text>"`: 업데이트 변경 사항(Changelog)을 텍스트로 직접 입력합니다.
* `--notes <file>`: 변경 사항이 작성된 텍스트 파일의 경로를 지정합니다.
* `--auto-changelog`: 최상위 `changes.json` 파일에서 **현재 배포할 앱 버전과 일치하는 변경 사항**을 자동으로 추출하여 적용합니다. (권장)
* `--force-update`: 해당 버전을 설치하지 않은 사용자에게 앱 진입 시 **강제 업데이트 팝업**을 띄우도록 설정합니다. (`force_update` 파라미터를 `true`로 설정)
* `-h, --help`: 스크립트 도움말을 출력합니다.

### 3.2 `update_app.sh` 전용 옵션
* `--skip-upload`: Firebase 업로드와 Remote Config 갱신을 생략하고, Flutter 빌드(clean, pub get, apk build) 및 에셋 동기화만 수행합니다.

### 3.3 `deploy_app.sh` 전용 옵션
* `--apk <path>`: 업로드할 APK 파일의 경로를 지정합니다. (기본값: `build/app/outputs/flutter-apk/app-release.apk`)
* `--version <value>`: Remote Config에 반영할 앱 버전을 수동 지정합니다. (기본값: `pubspec.yaml`에 적힌 버전 자동 감지)

---

## 4. 실전 배포 시나리오

모든 명령어는 **`flutter` 디렉토리 내**에서 실행해야 합니다.

### 시나리오 A: 일반적인 업데이트 배포 (가장 많이 사용)
앱의 버전을 올리고, 변경사항을 적용하여 일반 업데이트(선택 업데이트)로 배포합니다.
1. `flutter/pubspec.yaml`의 `version`을 변경합니다. (예: `1.3.5+12` -> `1.3.6+13`)
2. 최상위 `changes.json`에 새 버전에 대한 변경사항을 기재합니다.
3. 배포 스크립트를 실행합니다.
   ```bash
   ./update_app.sh --auto-changelog
   ```

### 시나리오 B: 긴급 강제 업데이트 배포
치명적인 버그 수정이나 필수 기능 변경으로 모든 사용자가 반드시 업데이트를 해야 할 때 사용합니다.
```bash
./update_app.sh --auto-changelog --force-update
```

### 시나리오 C: 이미 빌드된 APK를 수동으로 배포할 때
이미 APK 빌드를 마쳤고, 이 파일을 그대로 배포에 활용하고 싶을 때 사용합니다.
```bash
./deploy_app.sh --apk build/app/outputs/flutter-apk/app-release.apk --auto-changelog
```

---

## 5. Firebase 원격 구성 (Remote Config) 파라미터 정보
스크립트 실행 완료 시, Firebase 콘솔의 **Remote Config**에 다음 값들이 자동으로 주입됩니다. 앱은 구동 시 이 값들을 읽어와 업데이트 창을 띄웁니다.

* `latest_version`: 배포된 최신 앱 버전 (예: `1.3.6+13`)
* `apk_url`: Firebase Storage에 업로드된 APK의 안전한 다이렉트 다운로드 링크
* `changelog`: 업데이트 팝업에 표시될 변경 사항 목록
* `force_update`: 강제 업데이트 여부 (`true` / `false`)

---

## 6. 트러블슈팅 (Troubleshooting)

### Q1. "서비스 계정 키 파일을 찾을 수 없습니다" 에러 발생 시
* **원인**: 프로젝트 루트 폴더에 `nai-login-b8ba8d8f1788.json` 서비스 계정 키 파일이 없거나 이름이 다른 경우입니다.
* **해결**: 구글 클라우드 콘솔에서 서비스 계정 키를 새로 발급받아 최상위 폴더에 파일명을 일치시켜 배치하거나, 시스템 환경 변수로 `GOOGLE_APPLICATION_CREDENTIALS`에 키 파일의 절대 경로를 설정해 주세요.
  ```bash
  export GOOGLE_APPLICATION_CREDENTIALS="/경로/파일명.json"
  ```

### Q2. "gcloud access token을 가져오지 못했습니다" 에러 발생 시
* **원인**: Google Cloud SDK 인증이 만료되었거나 비정상 상태입니다.
* **해결**: 터미널에서 다음 명령어를 실행하여 계정 인증을 다시 완료해 주세요.
  ```bash
  gcloud auth application-default login
  ```

### Q3. "gsutil: command not found" 또는 "firebase: command not found"
* **원인**: 필수 CLI 도구들이 시스템 PATH에 등록되어 있지 않습니다.
* **해결**: Google Cloud SDK 및 Firebase CLI 설치 상태를 다시 확인하고 PATH 설정을 업데이트하세요.
