#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"

cd "$PROJECT_DIR"

if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]]; then
  CREDENTIAL_PATH="$PROJECT_DIR/../nai-login-b8ba8d8f1788.json"
  if [[ -f "$CREDENTIAL_PATH" ]]; then
    export GOOGLE_APPLICATION_CREDENTIALS="$CREDENTIAL_PATH"
  else
    echo "서비스 계정 키 파일을 찾을 수 없습니다: $CREDENTIAL_PATH" >&2
    exit 1
  fi
fi

# ------------------------------
# Configuration (edit as needed)
# ------------------------------
FIREBASE_PROJECT_ID="nai-login"
STORAGE_BUCKET="nai-login.firebasestorage.app"
STORAGE_UPLOAD_PREFIX="releases"
REMOTE_CONFIG_VERSION_KEY="latest_version"
REMOTE_CONFIG_URL_KEY="apk_url"
REMOTE_CONFIG_CHANGELOG_KEY="changelog"
REMOTE_CONFIG_FORCE_KEY="force_update"
APK_BUILD_FLAVOR="release"

# ------------------------------
# Argument parsing
# ------------------------------
CHANGELOG_TEXT=""
FORCE_UPDATE="false"
NOTES_FILE=""

print_usage() {
  cat <<'EOF'
Usage: ./update_app.sh [options]

Options:
  --notes <file>        파일에서 변경 사항을 읽어 Remote Config changelog에 반영
  --notes-text <text>   변경 사항을 문자열로 직접 지정
  --force-update        Remote Config의 force_update 값을 true로 설정
  --skip-upload         Storage 업로드와 Remote Config 갱신을 건너뜀 (빌드만 수행)
  -h, --help            이 도움말을 표시하고 종료

사전 준비:
  - Firebase CLI (firebase-tools)
  - Google Cloud SDK (gcloud)
  - jq
  - Flutter SDK
  - gcloud auth application-default login (또는 서비스 계정 키 설정)
  - firebase login (Storage 업로드용)
EOF
}

SKIP_UPLOAD="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --notes)
      shift
      [[ $# -gt 0 ]] || { echo "--notes 플래그에 파일 경로가 필요합니다" >&2; exit 1; }
      NOTES_FILE="$1"
      ;;
    --notes-text)
      shift
      [[ $# -gt 0 ]] || { echo "--notes-text 플래그에 문자열이 필요합니다" >&2; exit 1; }
      CHANGELOG_TEXT="$1"
      ;;
    --force-update)
      FORCE_UPDATE="true"
      ;;
    --skip-upload)
      SKIP_UPLOAD="true"
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "알 수 없는 옵션: $1" >&2
      print_usage
      exit 1
      ;;
  esac
  shift || true
done

if [[ -n "$NOTES_FILE" ]]; then
  if [[ ! -f "$NOTES_FILE" ]]; then
    echo "지정한 노트 파일을 찾을 수 없습니다: $NOTES_FILE" >&2
    exit 1
  fi
  CHANGELOG_TEXT="$(cat "$NOTES_FILE")"
fi

# ------------------------------
# Dependency checks
# ------------------------------
require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "필수 명령어 '$1' 을(를) 찾을 수 없습니다. 먼저 설치해주세요." >&2
    exit 1
  fi
}

require_cmd flutter
require_cmd jq

if [[ "$SKIP_UPLOAD" != "true" ]]; then
  require_cmd firebase
  require_cmd gcloud
  require_cmd gsutil
  require_cmd curl
  require_cmd uuidgen
fi

# ------------------------------
# Helper functions
# ------------------------------
log() {
  printf '\n\033[1;34m[update_app]\033[0m %s\n' "$1"
}

rawurlencode() {
  local string="$1"
  local length=${#string}
  local encoded=""
  local pos c o
  for (( pos=0; pos<length; pos++ )); do
    c=${string:$pos:1}
    case "$c" in
      [a-zA-Z0-9.~_-])
        encoded+="$c"
        ;;
      *)
        printf -v o '%%%02X' "'"$c
        encoded+="$o"
        ;;
    esac
  done
  echo "$encoded"
}

# ------------------------------
# Build APK
# ------------------------------
log "Flutter clean 실행"
flutter clean

log "패키지 의존성 동기화"
flutter pub get

log "APK 빌드 (${APK_BUILD_FLAVOR})"
flutter build apk --${APK_BUILD_FLAVOR}

APK_OUTPUT_PATH="build/app/outputs/flutter-apk/app-${APK_BUILD_FLAVOR}.apk"

if [[ ! -f "$APK_OUTPUT_PATH" ]]; then
  echo "APK 파일을 찾을 수 없습니다: $APK_OUTPUT_PATH" >&2
  exit 1
fi

APP_VERSION="$(grep '^version:' pubspec.yaml | awk '{print $2}')"
if [[ -z "$APP_VERSION" ]]; then
  echo "pubspec.yaml에서 버전을 찾을 수 없습니다." >&2
  exit 1
fi

log "빌드 완료: ${APK_OUTPUT_PATH} (버전 ${APP_VERSION})"

if [[ "$SKIP_UPLOAD" == "true" ]]; then
  log "--skip-upload 플래그가 설정되어 APK 업로드와 Remote Config 갱신을 건너뜁니다."
  exit 0
fi

# ------------------------------
# Upload to Firebase Storage
# ------------------------------
OBJECT_NAME="${STORAGE_UPLOAD_PREFIX}/naiapp-${APP_VERSION}.apk"
OBJECT_URI="gs://${STORAGE_BUCKET}/${OBJECT_NAME}"

if gsutil -q stat "$OBJECT_URI"; then
  log "기존 APK 발견: ${OBJECT_URI}. 업로드를 건너뜁니다."
  EXISTING_TOKEN=$(gsutil stat "$OBJECT_URI" | awk -F': ' '/firebaseStorageDownloadTokens/ {gsub(/\r/,"",$2); print $2}' | tail -n 1)
  if [[ -z "$EXISTING_TOKEN" ]]; then
    UPLOAD_TOKEN="$(uuidgen | tr '[:upper:]' '[:lower:]')"
    log "기존 파일에 다운로드 토큰이 없어 메타데이터를 갱신합니다."
    gsutil setmeta \
      -h "x-goog-meta-firebaseStorageDownloadTokens:${UPLOAD_TOKEN}" \
      "$OBJECT_URI"
  else
    UPLOAD_TOKEN="$EXISTING_TOKEN"
  fi
else
  UPLOAD_TOKEN="$(uuidgen | tr '[:upper:]' '[:lower:]')"
  log "Firebase Storage 업로드: ${OBJECT_URI}"
  gsutil \
    -h "Content-Type: application/vnd.android.package-archive" \
    -h "x-goog-meta-firebaseStorageDownloadTokens:${UPLOAD_TOKEN}" \
    cp "$APK_OUTPUT_PATH" "$OBJECT_URI"
fi

ENCODED_OBJECT_NAME="$(rawurlencode "$OBJECT_NAME")"
DOWNLOAD_URL="https://firebasestorage.googleapis.com/v0/b/${STORAGE_BUCKET}/o/${ENCODED_OBJECT_NAME}?alt=media&token=${UPLOAD_TOKEN}"

log "업로드 완료. 다운로드 URL = ${DOWNLOAD_URL}"

# ------------------------------
# Update Remote Config
# ------------------------------
TEMP_TEMPLATE="$(mktemp)"
TEMP_HEADERS="$(mktemp)"
UPDATED_TEMPLATE="$(mktemp)"

cleanup() {
  rm -f "$TEMP_TEMPLATE" "$TEMP_HEADERS" "$UPDATED_TEMPLATE"
}
trap cleanup EXIT

log "Remote Config 템플릿 가져오기"
ACCESS_TOKEN="${GOOGLE_API_TOKEN:-}"
if [[ -z "$ACCESS_TOKEN" ]]; then
  ACCESS_TOKEN="$(gcloud auth application-default print-access-token)"
fi
if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "gcloud access token을 가져오지 못했습니다." >&2
  exit 1
fi

HTTP_STATUS=$(curl -s -D "$TEMP_HEADERS" -o "$TEMP_TEMPLATE" -w "%{http_code}" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Accept: application/json" \
  "https://firebaseremoteconfig.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/remoteConfig")

if [[ "$HTTP_STATUS" != "200" ]]; then
  echo "Remote Config 템플릿 조회 실패 (HTTP ${HTTP_STATUS})" >&2
  cat "$TEMP_TEMPLATE" >&2
  exit 1
fi

ETAG="$(awk 'tolower($1)=="etag:" { $1=""; sub(/^ /,""); print; exit }' "$TEMP_HEADERS" 2>/dev/null | tr -d '\r')"
if [[ -z "$ETAG" ]]; then
  log "경고: ETag 헤더를 찾지 못했습니다. 강제 갱신 모드(*)로 진행합니다."
  ETAG="*"
fi

CHANGELOG_PAYLOAD="$CHANGELOG_TEXT"

jq \
  --arg version "$APP_VERSION" \
  --arg url "$DOWNLOAD_URL" \
  --arg changelog "$CHANGELOG_PAYLOAD" \
  --arg force "$FORCE_UPDATE" \
  --arg versionKey "$REMOTE_CONFIG_VERSION_KEY" \
  --arg urlKey "$REMOTE_CONFIG_URL_KEY" \
  --arg changeKey "$REMOTE_CONFIG_CHANGELOG_KEY" \
  --arg forceKey "$REMOTE_CONFIG_FORCE_KEY" \
  '(
     .parameters = (.parameters // {}) |
     .parameters[$versionKey] = ((.parameters[$versionKey] // {}) + {defaultValue: {value: $version}, valueType: "STRING"}) |
     .parameters[$urlKey]     = ((.parameters[$urlKey]     // {}) + {defaultValue: {value: $url}, valueType: "STRING"}) |
     (if ($changelog | length) > 0 then
        .parameters[$changeKey] = ((.parameters[$changeKey] // {}) + {defaultValue: {value: $changelog}, valueType: "STRING"})
      else . end) |
     .parameters[$forceKey] = ((.parameters[$forceKey] // {}) + {
        defaultValue: {value: (if $force == "true" then "true" else "false" end)},
        valueType: "BOOLEAN"
      })
   )' "$TEMP_TEMPLATE" > "$UPDATED_TEMPLATE"

log "Remote Config 갱신"
HTTP_STATUS=$(curl -s -o /tmp/remote_config_response.json -w "%{http_code}" \
  -X PUT "https://firebaseremoteconfig.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/remoteConfig" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json; UTF-8" \
  -H "If-Match: ${ETAG}" \
  --data-binary @"$UPDATED_TEMPLATE")

if [[ "$HTTP_STATUS" != "200" ]]; then
  echo "Remote Config 갱신 실패 (HTTP ${HTTP_STATUS})" >&2
  cat /tmp/remote_config_response.json >&2
  exit 1
fi

log "Remote Config 갱신 완료"

cat <<EOF

다음 값으로 Remote Config가 업데이트되었습니다:
  - ${REMOTE_CONFIG_VERSION_KEY} = ${APP_VERSION}
  - ${REMOTE_CONFIG_URL_KEY}     = ${DOWNLOAD_URL}
  - ${REMOTE_CONFIG_FORCE_KEY}   = ${FORCE_UPDATE}
  - ${REMOTE_CONFIG_CHANGELOG_KEY} = ${CHANGELOG_PAYLOAD:-<empty>}

빌드 파일: ${APK_OUTPUT_PATH}
Storage 경로: gs://${STORAGE_BUCKET}/${OBJECT_NAME}
EOF

