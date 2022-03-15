import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/state/persistent_state.dart';

/// Общие атрибуты приложения: выбранная тема, флажок демо-режима, возможные адреса серверов и т.д.
class ApplicationState extends PersistentState {
  static const Map<String, String> _defaultPossibleServers = const {
    "localhost": "http://localhost:8080",
    "jboss12": "http://jboss12:8080"
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

  /// Флажок "приложение занято". Если выставлен, будет отображен CrazyProgressDialog.
  /// Не сохраняется в secure storage, т.к. относится к краткоживущему state.
  ///
  /// Поскольку запрос на "занятость" приложения может одновременно поступить из нескольких
  /// мест кода, а считать приложение "свободным" можно, только если все эти запросы завершены,
  /// под капотом флажка спрятан счетчик, который инкрементится при послуплении запроса на
  /// "занятость" и декрементится при снятии запроса. То есть приложение "освобождается" (
  /// и индикатор прогресса скрывается) только когда не будет ни одного действующего запроса.
  Rx<bool> isApplicationBusy() {
    return (!(PersistentState.busyClaimCount == 0)).obs;
  }

  /// пометить приложение как "занятое". На время "занятости" будет отображен индикатор прогресса
  /// CrazyProgressIndicator.
  void claimApplicationIsBusy() {
    PersistentState.incrementBusyCount();
  }

  /// снять пометку "занятости" приложения
  void unClaimApplicationIsBusy() {
    PersistentState.decrementBusyCount();
  }
}
