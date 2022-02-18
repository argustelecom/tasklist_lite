import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/state/auth_controller.dart';
import 'package:tasklist_lite/tasklist/idle_time_reason_repository.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:tasklist_lite/tasklist/task_repository.dart';
import 'package:tasklist_lite/user_secure_storage/user_secure_storage_service.dart';

import '../tasklist/fixture/task_fixtures.dart';
import '../tasklist/history_events_repository.dart';
import '../tasklist/model/history_event.dart';

/// содержит state списка задач и (возможно в будущем) формы задачи
class TaskListController extends GetxController {
  /// открытые задачи. Их перечень не зависит от выбранного числа и обновляется только по необходимости
  /// (когда на сервере будут изменения)
  List<Task> openedTasks = List.of({});

  /// закрытые за выбранный день задачи. Как только день перевыбран, должны быть переполучены в репозитории
  /// (в его функции также может входить кеширование)
  List<Task> closedTasks = List.of({});

  /// справочные значения причин простоя. Запрашиваем из репозитория при инициализации контролллера
  /// (далее берем из кэша)
  /// TODO возможно, стоит перенести
  List<String> idleTimeReasons = List.of({});

  /// выбранный в календаре день
  /// если не выбран, считается "сегодня" (тут есть тех. сложности, т.к. для inherited widget нужно, чтобы
  /// конструктор initialState был константным, а DateTime.now() никак не константный)
  DateTime _currentDate = DateUtils.dateOnly(DateTime.now());

  AuthController authController = Get.find();

  DateTime get currentDate => _currentDate;

  set currentDate(DateTime value) {
    _currentDate = value;

    late String basicAuth = authController.getAuth();

    ApplicationState state = Get.find();
    String serverAddress = state.serverAddress;
    closedTasksSubscription = resubscribe(
        closedTasksSubscription,
        taskRepository.streamClosedTasks(
            basicAuth, serverAddress, this.currentDate), (event) {
      this.closedTasks = event;
      update();
    });
    update();
  }

  /// выбранный таск.
  Task? currentTask;

  Future initCurrentTask() async {
    currentTask = await UserSecureStorageService.getTask();
  }

  setCurrentTask(Task? task) {
    currentTask = task;
    UserSecureStorageService.setTask(task);
  }

  Task? getCurrentTask() {
    if (currentTask == null) {
      initCurrentTask().whenComplete(() => null);
    }
    return currentTask;
  }

  /// значение в поле ввода текста. в getTasks отдаются только таски, содержащие в названии этот текст
  String _searchText = "";

  String get searchText => _searchText;

  // в данном случае сеттер не только меняет внутренее состояние контрооллера, но и отвечает также за сигнал
  // о необходимости обновления. #TODO: пока не ясно, насколько это нормально и правильно
  set searchText(String value) {
    _searchText = value.toLowerCase();
    update();
  }

  /// признак раскрытости inline-календаря в списке задач
  /// #TODO: вообще хотелось state презентации держать в stateful-виджетах
  /// но этот(а также следующие searchBarExpanded, datePickerBarExpanded) нужен нескольким,
  /// которые не хочется объединять в uber-stateful. Но можно ведь хотя бы вынести
  /// в отдельный presentation-контроллер.
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
    openedTasks.sort((a, b) => a.dueDate == null
        ? 1
        : b.dueDate == null
            ? -1
            : a.dueDate!.compareTo(b.dueDate!));
    resultList.addAll(openedTasks);

    /// ...затем закрытые, упорядоченные по дате закрытия
    closedTasks.sort((a, b) => a.closeDate!.compareTo(b.closeDate!));
    resultList.addAll(closedTasks);
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
                currentDate.millisecondsSinceEpoch))));
  }

  StreamSubscription? openedTasksSubscription;
  StreamSubscription? closedTasksSubscription;

  TaskRepository taskRepository = Get.find();
  IdleTimeReasonRepository idleTimeReasonRepository = Get.find();
  HistoryEventRepository historyEventRepository = Get.find();

  StreamSubscription resubscribe(StreamSubscription? streamSubscription,
      Stream<List<Task>> stream, void onData(List<Task> event)) {
    streamSubscription?.cancel();
    return stream.listen(onData);
  }

  @override
  void onInit() {
    super.onInit();
    // берем stream`ы, на которых висят данные по открытым и закрытым задачам, и заводим их
    // на изменение соотв. полей контроллера списка.
    late String basicAuth = authController.getAuth();
    ApplicationState state = Get.find();
    String serverAddress = state.serverAddress;

    openedTasksSubscription = resubscribe(openedTasksSubscription,
        taskRepository.streamOpenedTasks(basicAuth, serverAddress), (event) {
      this.openedTasks = event;
      update();
    });

    closedTasksSubscription = resubscribe(
        closedTasksSubscription,
        taskRepository.streamClosedTasks(
            basicAuth, serverAddress, this.currentDate), (event) {
      this.closedTasks = event;
      update();
    });

    idleTimeReasons = idleTimeReasonRepository.getIdleTimeReasons();
  }

  @override
  void onClose() {
    openedTasksSubscription?.cancel();
    closedTasksSubscription?.cancel();
    super.onClose();
  }

  ///***************************************************************************
  ///**  по замыслу, вызывается, когда изменились неявные зависимости контроллера
  /// Например, выбрана новая фикстура в настройках, что требует переподписки на
  /// stream`ы taskRepository
  ///***************************************************************************
  void didChangeDependencies() {
    late String basicAuth = authController.getAuth();
    ApplicationState state = Get.find();
    String serverAddress = state.serverAddress;
    openedTasksSubscription = resubscribe(openedTasksSubscription,
        taskRepository.streamOpenedTasks(basicAuth, serverAddress), (event) {
      this.openedTasks = event;
      update();
    });
    closedTasksSubscription = resubscribe(
        closedTasksSubscription,
        taskRepository.streamClosedTasks(
            basicAuth, serverAddress, this.currentDate), (event) {
      this.closedTasks = event;
      update();
    });
  }

  /// *************  Тут начинается блок нужных штук для истории по наряду *************
  /// **********************************************************************************

  /// Данный метод отвечает за первичное наполнение листа с историческими событиями
  initHistory(Task task) {
    return historyEventList = historyEventRepository.getHistoryEvent(task);
  }

  /// Лист с историческими событиями по наряду
  List<HistoryEvent> historyEventList = List.of({});

  /// Метод для добавления комментария по наряду
  addComment(String comment, bool isAlarm, Task task) {
    var newComment = new HistoryEvent(
        // TODO: Персону нужно будет брать из учетки
        person: 'Вы',
        type: "Комментарий",
        content: comment,
        date: DateTime.now(),
        isAlarm: isAlarm,
        task: task);

    if (comment.length > 0) {
      HistoryEventRepository().addNewComment(newComment);
    }
    update();
  }

  /// Добавлеяем новый коммент с проверкой аварии(для кнопки проверка аварии)
  addNewCrashComment(Task currentTask) {
    var newCrashComment = new HistoryEvent(
        // TODO: Персону нужно будет брать из учетки
        person: 'Текущий пользователь',
        type: "Комментарий",
        content: 'Проверка аварии *111*1234#',
        date: DateTime.now(),
        isAlarm: false,
        task: currentTask);

    HistoryEventRepository().addNewComment(newCrashComment);
    update();
  }

  /// Метод для получения списка событий
  getHistoryEvents() {
    historyEventList.sort((a, b) => a.date.compareTo(b.date));
    return historyEventList;
  }

  /// Признак нужно ли уведомление, когда оставляем комментарий(колокольчик)
  var isAlarmComment = false;

  /// Получаем признак нужности уведомления
  getIsAlarmComment() {
    return isAlarmComment;
  }

  /// Переключаем признак нужности уведомления
  changeIsAlarmComment() {
    isAlarmComment = !isAlarmComment;
    update();
  }

  /// Фокуснода для текстового поля ввода комментария
  FocusNode focusNodeCommentInput = FocusNode();

  /// Чтобы моментально фокусироваться и получать
  setFocus() {
    focusNodeCommentInput.requestFocus();
    update();
  }

  /// *************  Тут заканчивается блок нужных штук для истории по наряду *************
  /// **********************************************************************************

}
