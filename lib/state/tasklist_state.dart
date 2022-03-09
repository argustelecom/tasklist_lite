import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/state/persistent_state.dart';
import 'package:tasklist_lite/tasklist/model/idle_time.dart';

import '../tasklist/model/task.dart';

/// реактивные атрибуты списка задач и формы задачи: коллекции открытых и закрытых задач,
/// отображаемых в списке; коллекция простоев, текущий выбранный таск (если есть) и т.д.
class TaskListState extends PersistentState {
  TaskListState();

  /// открытые задачи. Их перечень не зависит от выбранного числа и обновляется только по необходимости
  /// (когда на сервере будут изменения)
  RxList<Task> openedTasks = RxList.of({});

  /// закрытые за выбранный день задачи. Как только день перевыбран, должны быть переполучены в репозитории
  /// (в его функции также может входить кеширование)
  RxList<Task> closedTasks = RxList.of({});

  /// справочные значения причин простоя. Запрашиваем из репозитория при инициализации контролллера
  /// (далее берем из кэша)
  /// TODO возможно, стоит перенести
  RxList<IdleTimeReason> idleTimeReasons = RxList.of({});

  /// выбранный в календаре день
  /// если не выбран, считается "сегодня" (тут есть тех. сложности, т.к. для inherited widget нужно, чтобы
  /// конструктор initialState был константным, а DateTime.now() никак не константный)
  Rx<DateTime> currentDate = DateUtils.dateOnly(DateTime.now()).obs;

  /// выбранный таск.
  Rx<Task?> currentTask = Rxn<Task?>();

  @override
  List<RxInterface> getPersistentReactiveAttrs() {
    return [
      openedTasks,
      closedTasks,
      idleTimeReasons,
      currentDate,
      currentTask
    ];
  }

  static const String _taskListStateKeyName = "taskListState";

  @override
  String getKeyName() {
    return _taskListStateKeyName;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['openedTasks'] = jsonEncode(openedTasks);
    data['closedTasks'] = jsonEncode(closedTasks);
    data['idleTimeReasons'] = jsonEncode(idleTimeReasons);
    // если дата = "сегодня", сохраним null, т.к. хранить конкретную дату нет смысла
    DateTime now = DateTime.now();
    if ((currentDate.value.year == now.year) &&
        (currentDate.value.month == now.month) &&
        (currentDate.value.day == now.day)) {
      data['currentDate'] = null;
    } else {
      data['currentDate'] = currentDate.value.toIso8601String();
    }
    // если currentTask null, запишем именно null, а не jsonEncode (а то он сам запишет
    // строку "null", что осложнит decode
    data['currentTask'] =
        currentTask.value != null ? jsonEncode(currentTask.value) : null;

    return data;
  }

  @override
  void copyFromJson(Map<String, dynamic> json) {
    openedTasks.value = List.of(jsonDecode(json['openedTasks']).map<Task>((e) {
      return Task.fromJson(e);
    }));
    closedTasks.value = List.of(jsonDecode(json['closedTasks']).map<Task>((e) {
      return Task.fromJson(e);
    }));
    idleTimeReasons.value =
        List.of(jsonDecode(json['idleTimeReasons']).map<IdleTimeReason>((e) {
      return IdleTimeReason.fromJson(e);
    }));
    currentDate.value = (json['currentDate'] == null
        ? DateTime.now()
        : DateTime.parse(json['currentDate']));
    currentTask.value = json['currentTask'] == null
        ? null
        : Task.fromJson(jsonDecode(json['currentTask']));
  }
}
