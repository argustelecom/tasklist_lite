import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/tasklist/idle_time_reason_repository.dart';
import 'package:tasklist_lite/tasklist/model/close_code.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:tasklist_lite/tasklist/task_repository.dart';

import '../tasklist/close_code_repository.dart';
import '../tasklist/fixture/task_fixtures.dart';
import '../tasklist/history_events_repository.dart';
import '../tasklist/model/idle_time.dart';
import 'auth_state.dart';
import 'tasklist_state.dart';

/// содержит state списка задач и (возможно в будущем) формы задачи
class TaskListController extends GetxController {
  AuthState authState = Get.find();

  TaskListState taskListState = Get.put(TaskListState());

  /// значение в поле ввода текста. в getTasks отдаются только таски, содержащие в названии этот текст
  String _searchText = "";

  String get searchText => _searchText;

  // в данном случае сеттер не только меняет внутренее состояние контрооллера, но и отвечает также за сигнал
  // о необходимости обновления. #TODO: пока не ясно, насколько это нормально и правильно
  set searchText(String value) {
    _searchText = value.toLowerCase();
    update();
  }

  /// признак раскрытости inline-календаря в списке задач.
  /// Это state презентации, он не нуждается в персисте в локальную хранилку, поэтому
  /// живет в контроллере, а не в соответствующем state-классе.
  bool _calendarOpened = false;
  bool _datePickerBarExpanded = false;
  bool _searchBarExpanded = false;

  bool get calendarOpened => _calendarOpened;

  set calendarOpened(bool value) {
    _calendarOpened = value;
    update();
  }

  bool get datePickerBarExpanded => _datePickerBarExpanded;

  set datePickerBarExpanded(bool value) {
    _datePickerBarExpanded = value;
    update();
  }

  bool get searchBarExpanded => _searchBarExpanded;

  set searchBarExpanded(bool value) {
    _searchBarExpanded = value;
    update();
  }

  /// #TODO: сюда просится автоматический тест
  /// задачи, которые должны отображаться в списке задач, с учетом фильтров
  List<Task> getTasks() {
    /// хотим отображать сначала открытые, упорядоченные по КС (без КС в конце)...
    List<Task> resultList = List.of({});
    taskListState.openedTasks.sort((a, b) => a.dueDate == null
        ? 1
        : b.dueDate == null
            ? -1
            : a.dueDate!.compareTo(b.dueDate!));
    resultList.addAll(taskListState.openedTasks);

    /// ...затем закрытые, упорядоченные по дате закрытия
    taskListState.closedTasks
        .sort((a, b) => a.closeDate!.compareTo(b.closeDate!));
    resultList.addAll(taskListState.closedTasks);
    return List.of(resultList
        // фильтруем по наличию введенного (в поле поиска) текста в названии и других полях задачи
        .where((element) => (element.name.toLowerCase().contains(searchText) ||
            element.flexibleAttribs[TaskFixtures.foreignOrderIdFlexAttrName]
                .toString()
                .toLowerCase()
                .contains(searchText) ||
            element.flexibleAttribs[TaskFixtures.objectNameFlexAttrName]
                .toString()
                .toLowerCase()
                .contains(searchText) ||
            element.flexibleAttribs[TaskFixtures.orderOperatorNameFlexAttrName]
                .toString()
                .toLowerCase()
                .contains(searchText) ||
            element.getAddressDescription().contains(searchText)))
        // фильтруем по попаданию даты закрытия в текущий день
        .where((element) => ((!element.isClosed ||
            DateUtils.dateOnly(element.closeDate!).millisecondsSinceEpoch ==
                taskListState.currentDate.value.millisecondsSinceEpoch))));
  }

  StreamSubscription? _openedTasksSubscription;
  StreamSubscription? _closedTasksSubscription;
  StreamSubscription? _authStringSubscription;
  StreamSubscription? _serverAddressSubscription;
  StreamSubscription? _currentDateSubscription;
  StreamSubscription? _idleTimeReasonsSubscription;
  StreamSubscription? _closeCodesSubscription;

  TaskRepository taskRepository = Get.find();
  IdleTimeReasonRepository idleTimeReasonRepository = Get.find();
  CloseCodeRepository closeCodeRepository = Get.find();
  HistoryEventRepository historyEventRepository = Get.find();

  StreamSubscription resubscribe<T>(StreamSubscription? streamSubscription,
      Stream<T> stream, void onData(T event)) {
    streamSubscription?.cancel();
    return stream.listen(onData);
  }

  @override
  void onInit() {
    super.onInit();
    // берем stream`ы, на которых висят данные по открытым и закрытым задачам, и заводим их
    // на изменение соотв. полей контроллера списка. То есть, если изменилась например строка аутентификации,
    // мы должны сделать resubscribe списков открытых и закрытых задач. То же самое при изменении адреса
    // сервера или текущей даты.

    // #TODO: наверняка код ниже можно оптимизировать
    _authStringSubscription = resubscribe<String?>(
        _authStringSubscription, authState.authString.stream,
        (authStringValue) {
      _openedTasksSubscription = resubscribe<List<Task>>(
          _openedTasksSubscription,
          taskRepository.streamOpenedTasks(
              authStringValue, authState.serverAddress.value), (event) {
        taskListState.openedTasks.value = event;
        update();
      });

      _closedTasksSubscription = resubscribe<List<Task>>(
          _closedTasksSubscription,
          taskRepository.streamClosedTasks(
              authStringValue,
              authState.serverAddress.value,
              taskListState.currentDate.value), (event) {
        taskListState.closedTasks.value = event;
        update();
      });
    });

    _serverAddressSubscription = resubscribe<String?>(
        _serverAddressSubscription, authState.serverAddress.stream,
        (serverAddressValue) {
      _openedTasksSubscription = resubscribe<List<Task>>(
          _openedTasksSubscription,
          taskRepository.streamOpenedTasks(
              authState.authString.value, serverAddressValue), (event) {
        taskListState.openedTasks.value = event;
        update();
      });

      _closedTasksSubscription = resubscribe<List<Task>>(
          _closedTasksSubscription,
          taskRepository.streamClosedTasks(authState.authString.value,
              serverAddressValue, taskListState.currentDate.value), (event) {
        taskListState.closedTasks.value = event;
        update();
      });
    });

    _currentDateSubscription = resubscribe<DateTime>(
        _currentDateSubscription, taskListState.currentDate.stream,
        (dateTimeValue) {
      _closedTasksSubscription = resubscribe<List<Task>>(
          _closedTasksSubscription,
          taskRepository.streamClosedTasks(
              authState.authString.value,
              authState.serverAddress.value,
              taskListState.currentDate.value), (event) {
        taskListState.closedTasks.value = event;
        update();
      });
    });

    // на момент переподписывания здесь, значения в authState уже могли быть
    // заданы, и нового event`а может не быть очень долго. Чтобы заполнить список,
    // спровоцируем event явно.
    authState.serverAddress.refresh();

    _idleTimeReasonsSubscription = resubscribe<List<IdleTimeReason>>(
        _idleTimeReasonsSubscription,
        idleTimeReasonRepository
            .getIdleTimeReasons(
                authState.authString.value!, authState.serverAddress.value!)
            .asStream(), (event) {
      taskListState.idleTimeReasons.value = event;
      update();
    });

    _closeCodesSubscription = resubscribe<List<CloseCode>>(
        _closeCodesSubscription,
        closeCodeRepository
            .getCloseCodes(
                authState.authString.value!, authState.serverAddress.value!)
            .asStream(), (event) {
      taskListState.closeCodes.value = event;
      update();
    });
  }

  Future<IdleTime?> registerIdle(int taskInstanceId,
      int reasonId, DateTime beginTime, DateTime? endTime) async {
    return await taskRepository.registerIdle(
        authState.authString.value!,
        authState.serverAddress.value!,
        taskInstanceId,
        reasonId,
        beginTime,
        endTime);
  }

  Future<IdleTime?> finishIdle(int taskInstanceId,
      DateTime beginTime, DateTime endTime) async {
    AuthState authState = Get.find();
    return await taskRepository.finishIdle(
        authState.authString.value!,
        authState.serverAddress.value!,
        taskInstanceId,
        beginTime,
        endTime);
  }

  Future<bool?> completeStage(
      int taskInstanceId, int? closeCodeId) async {
    return await taskRepository.completeStage(
        authState.authString.value!,
        authState.serverAddress.value!,
        taskInstanceId,
        closeCodeId);
  }

  @override
  void onClose() {
    _openedTasksSubscription?.cancel();
    _closedTasksSubscription?.cancel();
    _serverAddressSubscription?.cancel();
    _authStringSubscription?.cancel();
    _currentDateSubscription?.cancel();
    _idleTimeReasonsSubscription?.cancel();
    _closeCodesSubscription?.cancel();
    super.onClose();
  }
}
