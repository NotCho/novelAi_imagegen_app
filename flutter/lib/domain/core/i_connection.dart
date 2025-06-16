import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class IConnection {
  Future<http.Response> get(String uri);
  Future<http.Response> post(String uri, {String? data});
  Future<http.Response> delete(String uri, {String? data});
  Future<http.Response> patch(String uri, {String? data});
  void setEvent(String event, void Function(dynamic data) callback);

  Future<http.Response> uploadFile(String uri, {required File file});

  Map<String, dynamic> getJsonMapOrCrash(String body, {String? key});
  Iterable<dynamic> getIterableOrCrash(String body);

  void setCallback(int statusCode, void Function() callback);
  void removeCallback(int statusCode);
  void setAuthToken(String token);
  void removeAuthToken();
  void logOut();
}
