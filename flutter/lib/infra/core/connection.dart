import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/core/i_connection.dart';
import 'environment.dart';

class JSEO extends IConnection {
  static JSEO? _jseo;
  static const authTokenKey = 'JSEOGIVEMEDATA!';
  static final _pref = Get.find<SharedPreferences>();

  static String getTokenFromSharedPreference() {
    final token = _pref.getString(JSEO.authTokenKey);
    return token ?? '';
  }

  static JSEO get instance {
    _jseo ??= JSEO._(
      getTokenFromSharedPreference(),
    );
    return _jseo!;
  }

  final String authToken;
  JSEO._(this.authToken) {
    setAuthToken(authToken);
  }

  final Map<String, String> _headers = {};
  final Map<int, void Function()> _httpCallbacks = {};
  final Map<String, void Function(dynamic data)> _eventCallbacks = {};

  @override
  Future<http.Response> get(String uri) {
    return http
        .get(
      _createUri(uri),
      headers: _headers,
    )
        .then((res) {
      _callByStatus(res.statusCode);
      return res;
    });
  }

  @override
  Future<http.Response> post(String uri, {String? data}) {
    return http
        .post(
      _createUri(uri),
      body: data,
      headers: _headers,
    )
        .then((res) {
      _callByStatus(res.statusCode);
      return res;
    });
  }

  @override
  Future<http.Response> delete(String uri, {String? data}) {
    return http
        .delete(
      _createUri(uri),
      body: data,
      headers: _headers,
    )
        .then((res) {
      _callByStatus(res.statusCode);
      return res;
    });
  }

  @override
  Future<http.Response> patch(String uri, {String? data}) {
    return http
        .patch(
      _createUri(uri),
      body: data,
      headers: _headers,
    )
        .then((res) {
      _callByStatus(res.statusCode);
      return res;
    });
  }

  @override
  Future<http.Response> uploadFile(
    String uri, {
    required File file,
  }) async {
    final mimeTypeData =
        lookupMimeType(file.path, headerBytes: [0xFF, 0xD8])!.split('/');
    final contentType = MediaType(mimeTypeData[0], mimeTypeData[1]);

    final uploadFile = await http.MultipartFile.fromPath(
      'image',
      file.path,
      contentType: contentType,
    );
    final req = http.MultipartRequest('POST', _createUri(uri))
      ..headers[HttpHeaders.authorizationHeader] =
          _headers[HttpHeaders.authorizationHeader]!
      ..files.add(uploadFile);
    return req.send().then((res) async {
      _callByStatus(res.statusCode);
      final response = await http.Response.fromStream(res);
      return response;
    });
  }

  void _callByStatus(int statusCode) {
    final callback = _httpCallbacks[statusCode];
    if (callback != null) {
      callback();
    }
  }

  @override
  Map<String, dynamic> getJsonMapOrCrash(String body, {String? key}) {
    final json = (jsonDecode(body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>;
    if (key != null) {
      return json[key] as Map<String, dynamic>;
    } else {
      return json;
    }
  }

  @override
  Iterable getIterableOrCrash(String body) {
    final json = (jsonDecode(body) as Map<String, dynamic>)['data'] as Iterable;
    return json;
  }

  Uri _createUri(String path) {
    return Uri.parse("${EnvironmentConfig.backEndUrl}$path");
  }

  @override
  void setCallback(int statusCode, void Function() callback) {
    if (_httpCallbacks[statusCode] == null) {
      _httpCallbacks[statusCode] = callback;
    }
  }

  @override
  void removeCallback(int statusCode) {
    _httpCallbacks.remove(statusCode);
  }

  @override
  void setAuthToken(String token) {
    _pref.setString(JSEO.authTokenKey, token);
    _headers[HttpHeaders.authorizationHeader] = token;
    // _socketConnect();
  }

  @override
  void removeAuthToken() {
    _headers.remove(HttpHeaders.authorizationHeader);
  }

  @override
  void logOut() {
    removeAuthToken();
    _pref.clear();
    _eventCallbacks.clear();
  }

  @override
  void setEvent(String event, void Function(dynamic data) callback) {
    _eventCallbacks[event] = callback;
  }
}
