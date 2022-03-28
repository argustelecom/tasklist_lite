import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/crazy_progress_dialog.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/idle_time_reason_repository.dart';
import 'package:tasklist_lite/tasklist/model/close_code.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:tasklist_lite/tasklist/task_repository.dart';

import '../common/resubscribe.dart';
import '../tasklist/close_code_repository.dart';
import '../tasklist/comments_repository.dart';
import '../tasklist/fixture/task_fixtures.dart';
import '../tasklist/model/idle_time.dart';
import '../tasklist/model/work.dart';
import '../tasklist/work_repository.dart';
import 'auth_state.dart';
import 'tasklist_state.dart';

/// содержит state списка задач и (возможно в будущем) формы задачи
class TaskListController extends GetxController {
  AuthState authState = Get.find();
  ApplicationState _applicationState = Get.find();

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
    /// добавляем сортировку по id для нарядов без КС
    List<Task> resultList = List.of({});
    taskListState.openedTasks.sort((a, b) => a.dueDate == null
        ? b.dueDate == null
            ? a.id.compareTo(b.id)
            : 1
        : b.dueDate == null
            ? -1
            : a.dueDate!.compareTo(b.dueDate!));
    resultList.addAll(taskListState.openedTasks);

    /// ...затем закрытые, упорядоченные по дате закрытия
    // #TODO: возможно, дата закрытия с сервера по задачам не получается.
    // иначе сложно объснитьь, почему в закрытых тасках эта дата null
    // в любом случае, надо проверять, что там на сервере. Затычки ниже
    // нерабочие, просто чтобы не падало.
    taskListState.closedTasks.sort(
        (a, b) => a.closeDate == null
            ? b.closeDate == null
            ? a.id.compareTo(b.id)
            : 1
            : b.closeDate == null
            ? -1
            : a.closeDate!.compareTo(b.closeDate!));
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
            element.getAddressDescription().toLowerCase().contains(searchText))));
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
  CommentRepository historyEventRepository = Get.find();

  @override
  void onInit() {
    super.onInit();
    // берем stream`ы, на которых висят данные по открытым и закрытым задачам, и заводим их
    // на изменение соотв. полей контроллера списка. То есть, если изменилась например строка аутентификации,
    // мы должны сделать resubscribe списков открытых и закрытых задач. То же самое при изменении адреса
    // сервера или текущей даты.

    // #TODO: тут вложенный resubscribe, из-за того, что адрес сервера и authString
    // при f5 асинхронно дочитываются, а без вложенного resubscribe будет использоваться
    // null вместо адреса и authString. Проблема бы решилась, если адрес и authString
    // не пробрасывать параметром, а брать напрямую
    _authStringSubscription = resubscribe<String?>(
        _authStringSubscription, authState.authString.stream,
        (authStringValue) {
      _openedTasksSubscription = resubscribe<List<Task>>(
          _openedTasksSubscription,
          taskRepository.streamOpenedTasks(
              authStringValue, authState.serverAddress.value), (event) {
        taskListState.openedTasks.value = event;
        update();
      }, showProgress: true);

      _closedTasksSubscription = resubscribe<List<Task>>(
          _closedTasksSubscription,
          taskRepository.streamClosedTasks(
              authStringValue,
              authState.serverAddress.value,
              taskListState.currentDate.value), (event) {
        taskListState.closedTasks.value = event;
        update();
      }, showProgress: true);
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
      }, showProgress: true);

      _closedTasksSubscription = resubscribe<List<Task>>(
          _closedTasksSubscription,
          taskRepository.streamClosedTasks(authState.authString.value,
              serverAddressValue, taskListState.currentDate.value), (event) {
        taskListState.closedTasks.value = event;
        update();
      }, showProgress: true);
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
      }, showProgress: true);
    });

    // на момент переподписывания здесь, значения в authState уже могли быть
    // заданы, и нового event`а может не быть очень долго. Чтобы заполнить список,
    // спровоцируем event явно.
    // 25.03.2022: в некоторых случаях прямой refresh приводит к ошибке setState()
    // or markNeedsBuild() called during build. Это потому, что под капотом refresh
    // reactive-переменной провоцируют вызов setState() у ObxWidget, зависящих от
    // нее, что конечно низя в ходе onInit. Поэтому делаем не напрямую, а через
    // postFrameCallback, как учат в интернетах.
    WidgetsBinding.instance!.addPostFrameCallback((Duration duration) {
      authState.serverAddress.refresh();
    });

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

  Future<IdleTime> registerIdle(int taskInstanceId, int reasonId,
      DateTime beginTime, DateTime? endTime) async {
    return await taskRepository.registerIdle(
        authState.authString.value!,
        authState.serverAddress.value!,
        taskInstanceId,
        reasonId,
        beginTime,
        endTime);
  }

  Future<IdleTime> finishIdle(
      int taskInstanceId, DateTime beginTime, DateTime endTime) async {
    AuthState authState = Get.find();
    return await taskRepository.finishIdle(authState.authString.value!,
        authState.serverAddress.value!, taskInstanceId, beginTime, endTime);
  }

  Future<bool?> completeStage(int taskInstanceId) async {
    return await taskRepository.completeStage(authState.authString.value!,
        authState.serverAddress.value!, taskInstanceId);
  }

  Future<bool?> closeOrder(int taskInstanceId, int closeCodeId) async {
    return await taskRepository.closeOrder(authState.authString.value!,
        authState.serverAddress.value!, taskInstanceId, closeCodeId);
  }

  Future<Work> registerWorkDetail(int taskInstanceId, int workTypeId,
      bool notRequired, double? amount, List<int>? workers) async {
    return await asyncShowProgressIndicatorOverlay(
      asyncFunction: () async {
        return await taskRepository.registerWorkDetail(
            authState.authString.value!,
            authState.serverAddress.value!,
            taskInstanceId,
            workTypeId,
            notRequired,
            amount,
            workers);
      },
    );
  }

  Future<Work> deleteWorkDetail(int taskInstanceId, int workDetailId) async {
    return await asyncShowProgressIndicatorOverlay(asyncFunction: () async {
      return await taskRepository.deleteWorkDetail(authState.authString.value!,
          authState.serverAddress.value!, taskInstanceId, workDetailId);
    });
  }

  String _searchWorksText = "";

  String get searchWorksText => _searchWorksText;

  set searchWorksText(String value) {
    _searchWorksText = value.toLowerCase();
    update();
  }

  List<Work> getWorks() {
    WorkRepository workRepository = Get.find();
    List<Work> sortedWorks = workRepository
        .orderWorksByState(taskListState.currentTask.value?.works);

    return sortedWorks
        .where((element) =>
            element.workType.name.toLowerCase().contains(searchWorksText))
        .toList();
  }

  // #TODO[НИ]: в каком случае markWorksNotRequired может вернуть null?
  // зачем обязывать вызывающего обрабатывать это?
  Future<bool?> markWorksNotRequired(
      int taskInstanceId, List<int> workTypes) async {
    return await taskRepository.markWorksNotRequired(
        authState.authString.value!,
        authState.serverAddress.value!,
        taskInstanceId,
        workTypes);
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

  /// Храним сколько максимально линий может быть в примечании в карточке задачи
  late int maxLines = 5;

  /// Изменяем кол-во отображаемых строк, чтобы посмотреть больше в примечании в карточке задачи
  viewFullCommentary() {
    maxLines = 500;
    update();
  }

  /// Изменяем кол-во отображаемых строк, чтобы скрыть в примечании в карточке задачи
  hideCommentary() {
    maxLines = 5;
    update();
  }
}
