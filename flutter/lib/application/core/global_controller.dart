import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:naiapp/application/core/router.dart';
import 'package:naiapp/application/function/remote_config_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../infra/service/ImageSaveManager.dart';

class GlobalController extends GetxController {
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set isLoading(bool value) => _isLoading.value = value;

  RxString currentClientVersion = '버전 로드 실패'.obs;
  final _updateInfo = Rxn<RemoteConfigUpdateInfo>();
  final _isUpdateAvailable = false.obs;
  final _isCheckingUpdate = false.obs;
  final _isDownloadingUpdate = false.obs;
  final _downloadProgress = 0.0.obs;
  String? _downloadedApkPath;
  bool _hasPromptedUpdate = false;

  String _jwtToken = '';
  final RemoteConfigService _remoteConfigService =
      Get.find<RemoteConfigService>();
  final router = Get.find<ISkeletonRouter>();

  set jwtToken(String jwtToken) {
    _jwtToken = jwtToken;
  }

  String get jwtToken => _jwtToken;

  RemoteConfigUpdateInfo? get updateInfo => _updateInfo.value;

  bool get isUpdateAvailable => _isUpdateAvailable.value;

  bool get isForceUpdateRequired =>
      isUpdateAvailable && (_updateInfo.value?.forceUpdate ?? false);

  bool get isCheckingUpdate => _isCheckingUpdate.value;

  bool get isDownloadingUpdate => _isDownloadingUpdate.value;

  double get downloadProgress => _downloadProgress.value;

  String get apkDownloadUrl => _updateInfo.value?.apkUrl ?? '';

  String get updateChangelog => _updateInfo.value?.changelog ?? '';

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await getCurrentClientVersion();
    await checkForUpdate();
  }

  Future<void> checkForUpdate({bool forceRemoteFetch = false}) async {
    if (_isCheckingUpdate.value) return;

    _isCheckingUpdate.value = true;
    try {
      final info = await _remoteConfigService.refreshUpdateInfo(
        forceRemoteFetch: forceRemoteFetch,
      );
      _updateInfo.value = info;
      print('원격 구성에서 업데이트 정보 가져옴: ${info.latestVersion}');

      final clientVersion = currentClientVersion.value;
      _isUpdateAvailable.value = info.isValid &&
              clientVersion.isNotEmpty &&
              clientVersion != '버전 로드 실패'
          ? _remoteConfigService.isRemoteVersionNewer(clientVersion)
          : false;

      if (_isUpdateAvailable.value) {

        print('업데이트가 필요합니다. ${clientVersion}');
        _promptUpdateIfNeeded(forcePrompt: forceRemoteFetch);
      } else if (forceRemoteFetch) {
        print('업데이트가 필요하지 않습니다.$clientVersion');
        _hasPromptedUpdate = false;
      }
    } finally {
      _isCheckingUpdate.value = false;
    }
  }

  void _promptUpdateIfNeeded({bool forcePrompt = false}) {
    if (!_isUpdateAvailable.value) return;

    final shouldPrompt =
        forcePrompt || !_hasPromptedUpdate || isForceUpdateRequired;
    if (!shouldPrompt) return;

    _hasPromptedUpdate = true;
    _showUpdateDialog();
  }

  void _showUpdateDialog() {
    final info = _updateInfo.value;
    if (info == null) return;

    final buffer = StringBuffer()
      ..writeln('현재 버전: ${currentClientVersion.value}')
      ..writeln('최신 버전: ${info.latestVersion.split('+')[0]}');

    final changelog = info.changelog.trim();
    if (changelog.isNotEmpty) {
      buffer
        ..writeln()

        ..writeln('변경 사항')
        ..writeln(changelog);
    }

    Get.defaultDialog(
      title: '업데이트 안내',
      middleText: buffer.toString(),
      barrierDismissible: !info.forceUpdate,
      onWillPop: () async => !info.forceUpdate,
      confirm: TextButton(
        onPressed: () {
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          downloadAndInstallApk();
        },
        child: const Text('업데이트'),
      ),
      cancel: info.forceUpdate
          ? null
          : TextButton(
              onPressed: () {
                if (Get.isDialogOpen ?? false) {
                  Get.back();
                }
              },
              child: const Text('나중에'),
            ),
    );
  }

  Future<void> downloadAndInstallApk() async {
    if (!GetPlatform.isAndroid) {
      _showSnackBar('업데이트', 'Android 기기에서만 수동 설치를 지원합니다.');
      return;
    }

    final url = apkDownloadUrl;
    if (url.isEmpty) {
      _showSnackBar('업데이트 실패', '다운로드 URL이 설정되어 있지 않습니다. 관리자에게 문의하세요.');
      return;
    }

    final installPermission = await Permission.requestInstallPackages.status;
    if (!installPermission.isGranted) {
      final result = await Permission.requestInstallPackages.request();
      if (!result.isGranted) {
        _showSnackBar('업데이트 실패', '설치 권한이 거부되어 APK를 설치할 수 없습니다.');
        return;
      }
    }

    if (_isDownloadingUpdate.value) {
      if (_downloadedApkPath != null) {
        await _installApk(_downloadedApkPath!);
      }
      return;
    }

    _isDownloadingUpdate.value = true;
    _downloadProgress.value = 0.0;
    isLoading = true;

    try {
      _downloadedApkPath = await _downloadApkFile(url);
      await _installApk(_downloadedApkPath!);
    } catch (e, stackTrace) {
      debugPrint('APK 다운로드/설치 실패: $e\n$stackTrace');
      _showSnackBar('업데이트 실패', '다운로드 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.');
    } finally {
      isLoading = false;
      _isDownloadingUpdate.value = false;
      _downloadProgress.value = 0.0;
    }
  }

  Future<String> _downloadApkFile(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw const FormatException('잘못된 URL 형식입니다.');
    }

    final client = http.Client();
    try {
      final request = http.Request('GET', uri);
      final response = await client.send(request);

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('다운로드 실패 (HTTP ${response.statusCode})', uri: uri);
      }

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/naiapp_update_${DateTime.now().millisecondsSinceEpoch}.apk';
      final file = File(filePath);
      final sink = file.openWrite();
      final completer = Completer<void>();
      final totalBytes = response.contentLength ?? 0;
      int received = 0;

      response.stream.listen(
        (chunk) {
          received += chunk.length;
          sink.add(chunk);
          if (totalBytes > 0) {
            _downloadProgress.value = received / totalBytes;
          }
        },
        onError: (error, stackTrace) async {
          await sink.flush();
          await sink.close();
          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }
        },
        onDone: () async {
          await sink.flush();
          await sink.close();
          _downloadProgress.value = 1.0;
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        cancelOnError: true,
      );

      await completer.future;
      return file.path;
    } finally {
      client.close();
    }
  }

  Future<void> _installApk(String filePath) async {
    if (!File(filePath).existsSync()) {
      throw ArgumentError('APK 파일을 찾을 수 없습니다.');
    }

    try {
      final result = await OpenFilex.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );

      if (result.type != ResultType.done) {
        final message = result.message.trim();
        switch (result.type) {
          case ResultType.fileNotFound:
            throw Exception('APK 파일을 찾을 수 없습니다. 다시 다운로드해주세요.');
          case ResultType.noAppToOpen:
            throw Exception('APK를 열 수 있는 앱을 찾을 수 없습니다. 기기 설정을 확인해주세요.');
          case ResultType.permissionDenied:
            throw Exception('설치 권한이 거부되었습니다. 설정에서 "알 수 없는 앱 설치"를 허용해주세요.');
          case ResultType.error:
            throw Exception(
                message.isNotEmpty ? message : '설치 화면을 여는 데 실패했습니다.');
          case ResultType.done:
            break;
        }
      }

      _showSnackBar('업데이트', '설치 화면을 열었습니다. 안내에 따라 설치를 완료해주세요.');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? '설치 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  void _showSnackBar(String title, String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> tryLogin() async {}

  Future<void> pageInitLoadingFail() async {
    Get.defaultDialog(
      title: '알림',
      middleText: '페이지를 불러오는데 실패했습니다.',
      confirm: TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('확인'),
      ),
    );
  }

  Future<void> getCurrentClientVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentClientVersion.value = packageInfo.version;
    } catch (e, stackTrace) {
      debugPrint('클라이언트 버전 조회 실패: $e\n$stackTrace');
      currentClientVersion.value = '버전 로드 실패';
    }
  }

  Future<void> saveMultipleImages(List<Uint8List> imageBytesList) async {
    await ExifPreservingImageSaver().saveMultipleImagesWithExif(imageBytesList,
        saveInPng: Get.find<SharedPreferences>().getBool('pngMode') ?? true);
  }

  Future<void> saveImageWithMetadata(Uint8List imageBytes) async {
    final imageName = "novelai_${DateTime.now().millisecondsSinceEpoch}";
    await ExifPreservingImageSaver().saveImageWithExif(imageBytes,
        customName: imageName,
        saveInPng: Get.find<SharedPreferences>().getBool('pngMode') ?? true);
  }

  Map<String, String> extractPngTextChunks(Uint8List bytes) {
    const pngSignatureLength = 8;
    final textChunks = <String, String>{};
    int i = pngSignatureLength;

    while (i + 8 < bytes.length) {
      // 청크 길이 (4바이트 빅엔디안)
      final length = (bytes[i] << 24) |
          (bytes[i + 1] << 16) |
          (bytes[i + 2] << 8) |
          (bytes[i + 3]);
      final chunkType = String.fromCharCodes(bytes.sublist(i + 4, i + 8));
      final dataStart = i + 8;
      final dataEnd = dataStart + length;

      if (dataEnd > bytes.length) break;

      if (chunkType == 'tEXt') {
        final chunkData = bytes.sublist(dataStart, dataEnd);
        // 키워드와 텍스트는 널(0x00)로 구분
        final nullIndex = chunkData.indexOf(0);
        if (nullIndex != -1) {
          final key = utf8.decode(chunkData.sublist(0, nullIndex));
          final value = utf8.decode(chunkData.sublist(nullIndex + 1));
          textChunks[key] = value;
        }
      }

      // CRC(4바이트)까지 건너뛰기
      i = dataEnd + 4;
    }

    return textChunks;
  }
}
