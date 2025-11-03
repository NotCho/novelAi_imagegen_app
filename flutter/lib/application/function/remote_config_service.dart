import 'dart:math';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigUpdateInfo {
  const RemoteConfigUpdateInfo({
    required this.latestVersion,
    required this.apkUrl,
    required this.forceUpdate,
    required this.changelog,
  });

  final String latestVersion;
  final String apkUrl;
  final bool forceUpdate;
  final String changelog;

  bool get isValid => latestVersion.isNotEmpty && apkUrl.isNotEmpty;
}

class RemoteConfigService {
  RemoteConfigService._(this._remoteConfig);

  static const _latestVersionKey = 'latest_version';
  static const _apkUrlKey = 'apk_url';
  static const _forceUpdateKey = 'force_update';
  static const _changelogKey = 'changelog';

  final FirebaseRemoteConfig _remoteConfig;

  static Future<RemoteConfigService> initialize() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 10),
      minimumFetchInterval: Duration(hours: 1),
    ));

    await remoteConfig.setDefaults(const <String, dynamic>{
      _latestVersionKey: '',
      _apkUrlKey: '',
      _forceUpdateKey: false,
      _changelogKey: '',
    });

    try {
      await remoteConfig.fetchAndActivate();
    } catch (e, stackTrace) {
      debugPrint('Remote Config 초기 로드 실패: $e\n$stackTrace');
    }

    return RemoteConfigService._(remoteConfig);
  }

  RemoteConfigUpdateInfo get cachedUpdateInfo => RemoteConfigUpdateInfo(
        latestVersion: _remoteConfig.getString(_latestVersionKey),
        apkUrl: _remoteConfig.getString(_apkUrlKey),
        forceUpdate: _remoteConfig.getBool(_forceUpdateKey),
        changelog: _remoteConfig.getString(_changelogKey),
      );

  Future<RemoteConfigUpdateInfo> refreshUpdateInfo({
    bool forceRemoteFetch = false,
  }) async {
    try {
      if (forceRemoteFetch) {
        await _remoteConfig.fetchAndActivate();
      } else {
        await _remoteConfig.fetch();
        await _remoteConfig.activate();
      }
    } catch (e, stackTrace) {
      debugPrint('Remote Config 갱신 실패: $e\n$stackTrace');
    }

    return cachedUpdateInfo;
  }

  bool isRemoteVersionNewer(String currentVersion) {
    final remoteVersion = cachedUpdateInfo.latestVersion;
    if (remoteVersion.isEmpty || currentVersion.isEmpty) {
      return false;
    }
    return _compareVersions(remoteVersion, currentVersion) > 0;
  }

  int _compareVersions(String a, String b) {
    final sanitizedA = a.split('+').first;
    final sanitizedB = b.split('+').first;

    final partsA = sanitizedA.split('.');
    final partsB = sanitizedB.split('.');

    final maxLength = max(partsA.length, partsB.length);

    for (var i = 0; i < maxLength; i++) {
      final valueA = i < partsA.length ? int.tryParse(partsA[i]) ?? 0 : 0;
      final valueB = i < partsB.length ? int.tryParse(partsB[i]) ?? 0 : 0;

      if (valueA != valueB) {
        return valueA.compareTo(valueB);
      }
    }

    return 0;
  }
}
