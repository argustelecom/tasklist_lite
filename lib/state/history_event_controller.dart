import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';
import 'package:tasklist_lite/state/auth_controller.dart';

import '../tasklist/history_events_repository.dart';
import '../tasklist/model/history_event.dart';
import '../tasklist/model/task.dart';

class HistoryEventController extends GetxController {
  /// Ищем нужные нам штуки
  HistoryEventRepository historyEventRepository = Get.find();
  TaskListController taskListController = Get.find();
  AuthController authController = Get.find();

  /// Инициализируем список событий
  @override
  void onInit() {
    initHistory(taskListController.taskListState.currentTask.value);
  }

  /// Данный метод отвечает за первичное наполнение листа с историческими событиями
  initHistory(Task? task) {
    if (task != null) {
      historyEventRepository
          .getHistoryEvent(
              //TODO: изменить метод получения значения?
              authController.authState.authString.value!, authController.authState.serverAddress.value!, task)
          .whenComplete(() => null)
          .then((value) => historyEventList = value);
    }
  }

  /// Лист с историческими событиями по наряду
  List<HistoryEvent> historyEventList = List.of({});

  /// Метод для добавления комментария по наряду
  addComment(String comment, bool isAlarm, Task task) {
        if (comment.length > 0) {
      HistoryEventRepository().addNewComment( authController.authState.authString.value!, authController.authState.serverAddress.value!, task, comment, isAlarm);
    }
    update();
  }

  /// Добавлеяем новый коммент с проверкой аварии(для кнопки проверка аварии)
  addNewCrashComment(Task task) {
    // TODO генерировать правильный комментарий
    String comment =  'Проверка аварии *111*1234#';
    bool isAlarm = false;

    HistoryEventRepository().addNewComment( authController.authState.authString.value!, authController.authState.serverAddress.value!, task, comment, isAlarm);
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

  /// Храним статус фокуса, для отображения кнопки отправить
  var onTextFieldFocused = false;

  /// Назначаем статус при onChangeFocus
  setOnTextFieldFocused(bool isFocused) {
    onTextFieldFocused = isFocused;
    update();
  }

  /// Получаем статус фокуса
  getOnTextFieldFocused() {
    return onTextFieldFocused;
  }

  /// Храним коммент для перехода в него
  var selectedComment;

  /// Указываем какой коммент выбираем
  setCurrentComment(HistoryEvent historyEvent) {
    selectedComment = historyEvent;
  }
}
