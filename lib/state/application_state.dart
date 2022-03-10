import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/state/persistent_state.dart';



/// Общие атрибуты приложения: выбранная тема, флажок демо-режима, возможные адреса серверов и т.д.
class ApplicationState extends PersistentState {
  static const Map<String, String> _defaultPossibleServers = const {
    "localhost": "http://localhost:8080",
  //для проверки из-под эмулятора используй этот адрес, если не работает дефолт
  //static const defaultServerAddress = "http://10.0.2.2:8080";

  static const defaultServerAddress = "http://192.168.100.84:8080";
    "jboss12": "http://jboss12:8080"
  };

  Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  Rx<bool> inDemonstrationMode = false.obs;

  RxMap<String, String> possibleServers = RxMap.of(_defaultPossibleServers);
  //TODO: научиться прокидывать значение в настройки в const-конструктор.
  // final Map<String, String> possibleServers = Map<String, String>.from(jsonDecode(dotenv.get('URL_SERVERS', fallback:
  // "{\"localhost\": \"$defaultServerAddress\", \"jboss12\": \"http://jboss12:8080\"}")));

  ApplicationState();

  @override
  List<RxInterface> getPersistentReactiveAttrs() {
    return [themeMode, inDemonstrationMode, possibleServers];
  }

  static const String _applicationStateKeyName = "applicationState";

  @override
  String getKeyName() {
    return _applicationStateKeyName;
  }

  @override
  Future<void> doPriorAsyncInit() {
    // #TODO[ВС]: написать сюда код чтения настроек из переменных окружения.
    // (ессно, удалить при этом вызов super)
    return super.doPriorAsyncInit();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['themeMode'] = themeMode.value.index;
    data['inDemonstrationMode'] = inDemonstrationMode.value;
    // Lists are reactive by default. Therefore unlike other observables, you don't need to use .value to access the list.
    // Map, очевидно, тоже. https://stackoverflow.com/questions/69460163/the-member-value-can-only-be-used-within-instance-members-of-subclasses-with-f
    data['possibleServers'] = jsonEncode(possibleServers);
    return data;
  }

  @override
  void copyFromJson(Map<String, dynamic> json) {
    themeMode.value = ThemeMode.values.elementAt(json['themeMode']);
    inDemonstrationMode.value =
        json['inDemonstrationMode'].toString().toLowerCase() == "true";

    possibleServers.value =
        Map.of(jsonDecode(json['possibleServers'])).cast<String, String>();
  }
}
