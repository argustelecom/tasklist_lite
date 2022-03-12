import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/state/persistent_state.dart';



/// Общие атрибуты приложения: выбранная тема, флажок демо-режима, возможные адреса серверов и т.д.
class ApplicationState extends PersistentState {
  static const Map<String, String> _defaultPossibleServers = const {
      "localhost": "http://localhost:8080",
    "jboss5": "http://jboss5:8080"
  };

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  final Rx<bool> inDemonstrationMode = false.obs;

  final RxMap<String, String> possibleServers =
      RxMap.of(_defaultPossibleServers);


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
    possibleServers.value = Map.of(jsonDecode(dotenv.get('possibleServers'))).cast<String, String>();
    return Future<void>.value();
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
