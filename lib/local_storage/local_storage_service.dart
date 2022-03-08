import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// обеспечивает локальное хранение значений. То есть доступ к сохраненным
/// значениям кешируется, возможен без обращения к серверу.
/// Под капотом используется SecureStorage, который работает и нативно, и в вебе.
@Deprecated("используй лучше PersistentState")
class LocalStorageService extends GetxController {
  static final _storage = FlutterSecureStorage();

  // #TODO: затоптать лишние методы здесь
  static Future<List<String>> readList(String key) async {
    String? result = await _storage.read(key: key);
    if (result != null) {
      return (json.decode(result) as List).cast<String>();
    }
    return List.of({});
  }

  static Future writeList(String key, List data) async {
    return await _storage.write(key: key, value: json.encode(data));
  }
}
