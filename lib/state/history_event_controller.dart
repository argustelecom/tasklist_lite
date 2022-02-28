import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../tasklist/history_events_repository.dart';
import '../tasklist/model/history_event.dart';
import '../tasklist/model/task.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';

class HistoryEventController extends GetxController {
  /// Ищем нужные нам штуки
  HistoryEventRepository historyEventRepository = Get.find();
  TaskListController taskListController = Get.find();

  /// Инициализируем список событий
  @override
  void onInit() {
    initHistory(taskListController.getCurrentTask());
  }

  /// Данный метод отвечает за первичное наполнение листа с историческими событиями
  initHistory(Task? task) {
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
