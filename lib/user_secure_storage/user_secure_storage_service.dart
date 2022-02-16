import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:tasklist_lite/tasklist/model/user_info.dart';

class UserSecureStorageService {
  static final _storage = FlutterSecureStorage();

  static const String _authenticatedKeyName = "authenticated";
  static const String _userInfoKeyName = "userinfo";
  static const String _taskKeyName = "task";

  static Future<bool> getAuthenticated() async {
    final authStr = await _storage.read(key: _authenticatedKeyName);
    return (authStr == 'true');
  }

  static Future setAuthenticated(bool authenticated) async => await _storage
      .write(key: _authenticatedKeyName, value: authenticated.toString());

  static Future<UserInfo?> getUserInfo() async {
    final userInfoStr = await _storage.read(key: _userInfoKeyName);
    return userInfoStr != null ? UserInfo.fromJson(jsonDecode(userInfoStr))
        : null;
  }

  static Future setUserInfo(UserInfo? userInfo) async =>
      await _storage.write(key: _userInfoKeyName, value: jsonEncode(userInfo));

  static Future<Task?> getTask() async {
    final taskStr = await _storage.read(key: _taskKeyName);
    return taskStr != null ? Task.fromJson(jsonDecode(taskStr)) : null;
  }

  static Future setTask(Task? task) async {
    if (task != null) {
      await _storage.write(key: _taskKeyName, value: jsonEncode(task));
    }
  }

}
