import 'package:tasklist_lite/tasklist/model/task.dart';

/// Оценка работника
class Mark {
  /// ID оценки
  int id;

  /// Причина начисления/списания баллов
  String name;

  /// Время начисления/списания баллов
  DateTime date;

  /// Количество баллов
  String value;

  /// "Id задачи"
  Task task;

  /// Сотрудник
  String worker;

  /// Тип
  String type;

  Mark(
      {required this.id,
      required this.task,
      required this.name,
      required this.value,
      required this.date,
      required this.worker,
      required this.type});
}
