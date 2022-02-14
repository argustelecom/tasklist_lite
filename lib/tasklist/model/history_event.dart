import 'package:tasklist_lite/tasklist/model/task.dart';

/// Событие в истории
class HistoryEvent {
  ///Персона, которая сгенерировала событие
  final String person;

  /// Тип события(вижу что может быть коммент или файл, а может что-то еще?)
  final String type;

  ///С уведомлением или без? По умолчанию без
  final isAlarm;

  ///Какое-то содержимое события
  var content;

  /// Задача, к которой относится данное историческое событие
  Task task;

  ///Дата события
  final DateTime date;

  HistoryEvent(
      {required this.person,
      required this.type,
      required this.content,
      required this.date,
      required this.isAlarm,
      required this.task});
}
