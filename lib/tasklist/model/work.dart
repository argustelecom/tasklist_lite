import 'package:tasklist_lite/tasklist/model/worker.dart';

/// Работа
class Work {
  /// Тип работы
  WorkType workType;

  /// Отметки о работе
  List<WorkDetail>? workDetail;

  /// Признак "Не требуется"
  bool notRequired;

  Work({required this.workType, this.workDetail, this.notRequired = false});
}

/// Отметка о работе
class WorkDetail {
  /// ID отметки о работе
  int id;

  /// Объем работ
  double amount;

  /// Исполнители и начисленные баллы
  Map<Worker, double> workerMarks;

  /// Время отметки
  DateTime date;

  WorkDetail(
      {required this.id,
      required this.amount,
      required this.workerMarks,
      required this.date});
}

/// Тип работы
class WorkType {
  /// ID типа работ
  int id;

  /// Название типа работ
  String name;

  /// Единица измерения
  String? units;

  /// Количество баллов за единицу работ
  double marks;

  WorkType(
      {required this.id, required this.name, this.units, required this.marks});
}
