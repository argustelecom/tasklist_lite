import 'dart:async';

import 'package:get/get.dart';
import 'package:tasklist_lite/presentation/controllers/auth_controller.dart';
import 'package:tasklist_lite/presentation/controllers/tasklist_controller.dart';
import 'package:tasklist_lite/presentation/state/tasklist_state.dart';

import '../../core/resubscribe.dart';
import '../../data/repositories/comments_repository.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/task.dart';
import '../state/application_state.dart';
import '../state/auth_state.dart';

class CommentController extends GetxController {
  /// Ищем нужные нам штуки
  CommentRepository commentRepository = Get.find();
  TaskListController taskListController = Get.find();
  AuthController authController = Get.find();
  AuthState authState = Get.find();

  /// Лист с историческими событиями по наряду
  List<Comment> commentList = List.of({});

  /// Подписка на комментарии
  StreamSubscription? commentSubscription;

  /// Инициализируем список событий
  @override
  void onInit() {
    super.onInit();

    taskListController.taskListState.initCompletedFuture.whenComplete(() {
      commentSubscription = resubscribe<List<Comment>>(
          commentSubscription,
          commentRepository.streamComments(
              taskListController.taskListState.currentTask.value), (event) {
        List<Comment> comments = event;
        this.commentList = comments;
      });
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
  addComment(String comment, bool isAlarm) {
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
      CommentRepository().addNewComment(
          taskListController.taskListState.currentTask.value, comment, isAlarm);
      // TODO: Костыль для корректного постороеня UI т.к. пока не реализованы подписки.
      // При добавлении нового коммента он улетает на сервер и дополнительно добавляется в список в контроллере для отображения
      commentList.add(Comment(
          type: "Комментарий",
          person: "Вы",
          date: DateTime.now(),
          isAlarm: isAlarm,
          content: comment));
    }
    update();
  }

//TODO: часть костылика для коммента с аттачем. Убрать позже.
  addAttachComment(String attachName) {
    commentList.add(Comment(
        type: "Вложение",
        person: "Вы",
        date: DateTime.now(),
        isAlarm: false,
        content:
            "${authState.userInfo.value!.getWorkerNameWithInitials()} добавил вложение $attachName"));
    CommentRepository().addNewComment(
        taskListController.taskListState.currentTask.value,
        "${authState.userInfo.value!.getWorkerNameWithInitials()} добавил вложение $attachName",
        false);
    update();
  }

  //TODO: часть костылика для коммента с аттачем. Убрать позже.
  addDeleteAttachComment(String attachName) {
    commentList.add(Comment(
        type: "Вложение",
        person: "Вы",
        date: DateTime.now(),
        isAlarm: false,
        content:
            "${authState.userInfo.value!.getWorkerNameWithInitials()} удалил вложение $attachName"));
    CommentRepository().addNewComment(
        taskListController.taskListState.currentTask.value,
        "${authState.userInfo.value!.getWorkerNameWithInitials()} удалил вложение $attachName",
        false);
    update();
  }

  /// Добавлеяем новый коммент с проверкой аварии(для кнопки проверка аварии)
  addNewCrashComment(Task task) {
    // TODO генерировать правильный комментарий
    String comment =
        '#203*${taskListController.taskListState.currentTask.value!.ttmsId}#';
    bool isAlarm = false;

    CommentRepository().addNewComment(task, comment, isAlarm);
    // TODO: тут такой же костыль - исправить когда будут subscriptions
    commentList.add(Comment(
        type: "Комментарий",
        person: "Вы",
        date: DateTime.now(),
        isAlarm: isAlarm,
        content: comment));
    update();
  }

  /// Метод для получения списка событий
  getComments() {
    commentList.sort((a, b) => a.date.compareTo(b.date));
    return commentList;
  }

  /// Признак нужно ли уведомление, когда оставляем комментарий(колокольчик)
  bool _isAlarmComment = false;

  bool get isAlarmComment => _isAlarmComment;

  set isAlarmComment(bool isAlarmComment) {
    _isAlarmComment = isAlarmComment;
    update();
  }

  /// Храним статус фокуса, для отображения кнопки отправить
  bool _onTextFieldFocused = false;

  bool get onTextFieldFocused => _onTextFieldFocused;

  set onTextFieldFocused(bool isFocused) {
    _onTextFieldFocused = isFocused;
    update();
  }

  /// Храним коммент для перехода в него
  late Comment _selectedComment;

  Comment get selectedComment => _selectedComment;

  set selectedComment(Comment historyEvent) {
    _selectedComment = historyEvent;
    update();
  }
}
