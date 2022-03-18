import 'dart:async';

import 'package:get/get.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';
import 'package:tasklist_lite/state/auth_controller.dart';

import '../tasklist/history_events_repository.dart';
import '../tasklist/model/history_event.dart';
import '../tasklist/model/task.dart';
import 'auth_state.dart';

class HistoryEventController extends GetxController {
  /// Ищем нужные нам штуки
  HistoryEventRepository historyEventRepository = Get.find();
  TaskListController taskListController = Get.find();
  AuthController authController = Get.find();
  AuthState authState = Get.find();

  /// Лист с историческими событиями по наряду
  List<HistoryEvent> historyEventList = List.of({});

  /// Подписка на комментарии
  StreamSubscription? commentSubscription;

  /// Метод переподписки, скидывает старый стрим и слушает новый
  StreamSubscription resubscribe(
      StreamSubscription? streamSubscription,
      Stream<List<HistoryEvent>> stream,
      void onData(List<HistoryEvent> event)) {
    streamSubscription?.cancel();
    return stream.listen(onData);
  }

  /// Инициализируем список событий
  @override
  void onInit() {
    super.onInit();

    commentSubscription = resubscribe(
        commentSubscription,
        historyEventRepository.streamComments(
            authState.authString.value!,
            authState.serverAddress.value!,
            taskListController.taskListState.currentTask.value), (event) {
      List<HistoryEvent> comments = event;
      this.historyEventList = comments;
    });
    update();
  }

  /// Сбрасываем стрим
  @override
  void onClose() {
    commentSubscription?.cancel();
    super.onClose();
  }

  /// Метод для добавления комментария по наряду
  addComment(String comment, bool isAlarm, Task task) {
    /// Лист с регулярными выражениями для определения стилей вводимого текста
    List<RegExp> patterns = List.of({
      new RegExp(r'\*(.*?)\*'),
      new RegExp(r'~(.*?)~'),
      new RegExp(r'_(.*?)\_')
    });

    /// Заменяем спецсимволы на HTML теги перед отправкой коммента
    for (RegExp pattern in patterns) {
      Iterable<Match> matches = pattern.allMatches(comment);
      if (pattern == patterns[0]) {
        for (Match m in matches) {
          var formatText = m[0]!.replaceFirst("*", "<b>");
          comment =
              comment.replaceAll(pattern, formatText.replaceFirst("*", "</b>"));
        }
      } else if (pattern == patterns[1]) {
        for (Match m in matches) {
          var formatText = m[0]!.replaceFirst('~', '<del>');
          comment = comment.replaceAll(
              pattern, formatText.replaceFirst('~', '</del>'));
        }
      } else if (pattern == patterns[2]) {
        for (Match m in matches) {
          var formatText = m[0]!.replaceFirst('_', '<i>');
          comment =
              comment.replaceAll(pattern, formatText.replaceFirst('_', "</i>"));
        }
      }
    }

    if (comment.length > 0) {
      HistoryEventRepository().addNewComment(
          authController.authState.authString.value!,
          authController.authState.serverAddress.value!,
          task,
          comment,
          isAlarm);
      // TODO: Костыль для корректного постороеня UI т.к. пока не реализованы подписки.
      // При добавлении нового коммента он улетает на сервер и дополнительно добавляется в список в контроллере для отображения
      historyEventList.add(HistoryEvent(
          type: "Комментарий",
          person: "Вы",
          date: DateTime.now(),
          isAlarm: isAlarm,
          content: comment));
    }
    update();
  }

  /// Добавлеяем новый коммент с проверкой аварии(для кнопки проверка аварии)
  addNewCrashComment(Task task) {
    // TODO генерировать правильный комментарий
    String comment =
        '#203*${taskListController.taskListState.currentTask.value!.ttmsId}#';
    bool isAlarm = false;

    HistoryEventRepository().addNewComment(
        authController.authState.authString.value!,
        authController.authState.serverAddress.value!,
        task,
        comment,
        isAlarm);
    // TODO: тут такой же костыль - исправить когда будут subscriptions
    historyEventList.add(HistoryEvent(
        type: "Комментарий",
        person: "Вы",
        date: DateTime.now(),
        isAlarm: isAlarm,
        content: comment));
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
