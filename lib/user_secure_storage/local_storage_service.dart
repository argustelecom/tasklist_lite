import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:tasklist_lite/tasklist/model/user_info.dart';

/// обеспечивает локальное хранение значений. То есть доступ к сохраненным
/// значениям кешируется, возможен без обращения к серверу.
/// Под капотом используется SecureStorage, который работает и нативно, и в вебе.
class LocalStorageService {
  static final _storage = FlutterSecureStorage();

  static const String _authenticatedKeyName = "authenticated";
  static const String _userInfoKeyName = "userinfo";
  static const String _taskKeyName = "task";
  static const String _serverAddressKeyName = "serverAddress";

  static Future<bool> readIsAuthenticated() async {
    final authStr = await _storage.read(key: _authenticatedKeyName);
    return (authStr == 'true');
  }

  static Future writeIsAuthenticated(bool authenticated) async => await _storage
      .write(key: _authenticatedKeyName, value: authenticated.toString());

  static Future<UserInfo?> readUserInfo() async {
    final userInfoStr = await _storage.read(key: _userInfoKeyName);
    return userInfoStr != null
        ? UserInfo.fromJson(jsonDecode(userInfoStr))
        : null;
  }

  static Future writeUserInfo(UserInfo? userInfo) async =>
      await _storage.write(key: _userInfoKeyName, value: jsonEncode(userInfo));

  static Future<Task?> readTask() async {
    final taskStr = await _storage.read(key: _taskKeyName);
    return taskStr != null ? Task.fromJson(jsonDecode(taskStr)) : null;
  }

  static Future writeTask(Task? task) async {
    if (task != null) {
      await _storage.write(key: _taskKeyName, value: jsonEncode(task));
    }
  }

  static Future<String?> readServerAddress() async {
    return await _storage.read(key: _serverAddressKeyName);
  }

  static Future writeServerAddress(String serverAddress) async {
    await _storage.write(key: _serverAddressKeyName, value: serverAddress);
  }

  static Future<List<String>> readList(String key) async {
    String? result = await _storage.read(key: key);
    if (result != null) {
      return (json.decode(result) as List).cast<String>();
    }
    return List.of({});
  }

  static Future writeList(String key, List<String> data) async {
    return await _storage.write(key: key, value: json.encode(data));
  }
}
