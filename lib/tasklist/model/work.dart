import 'dart:convert';

import 'package:tasklist_lite/tasklist/model/worker.dart';

/// Работа
class Work {
  /// Тип работы
  WorkType workType;

  /// Отметки о работе
  List<WorkDetail>? workDetail;

  /// Признак "Не требуется"
  bool notRequired;

  /// Статус
  String? status;

  Work(
      {required this.workType,
      this.workDetail,
      this.notRequired = false,
      this.status});

  factory Work.fromJson(Map<String, dynamic> json) {
    Work work = Work(
        workType: WorkType.fromJson(json['workType']),
        workDetail: json['workDetail'] != null
            ? List<WorkDetail>.from((json['workDetail'])
                .map((e) => WorkDetail.fromJson(e))
                .toList())
            : null,
        notRequired: json['status'] != null ? json['status'] == 'CANCELED' : false,
        status: json['status']);
    return work;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['workType'] = this.workType.toJson();
    data['workDetail'] = this.workDetail != null
        ? this.workDetail!.map((e) => e.toJson()).toList()
        : null;
    data['notRequired'] = this.notRequired;
    data['status'] = this.status;
    return data;
  }
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

  factory WorkDetail.fromJson(Map<String, dynamic> json) {
    WorkDetail workDetail = WorkDetail(
      id: int.parse(json['id']),
      amount: json['amount'] != null ? json['amount'] : 0,
      workerMarks: Map<Worker, double>.fromIterable(json['workerMarks'],
          key: (e) => Worker.fromJson(e['worker']), value: (e) => e['mark']),
      date: DateTime.parse(json['date']),
    );
    return workDetail;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id.toString();
    data['amount'] = this.amount;
    data['workerMarks'] =
        this.workerMarks.entries.map((e) => toMapJson(e)).toList();
    data['date'] = this.date.toString();
    return data;
  }

  Map<String, Object?> toMapJson(MapEntry mapEntry) {
    Map<String, Object?> map = Map();
    map.putIfAbsent("__typename", () => "workerMarks");
    map.putIfAbsent("worker", () => (mapEntry.key as Worker).toJson());
    map.putIfAbsent("mark", () => mapEntry.value);
    return map;
  }
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

  factory WorkType.fromJson(Map<String, dynamic> json) {
    WorkType workType = WorkType(
      id: int.parse(json['id']),
      name: json['name'],
      units: json['units'] != null ? json['units'] : null,
      //на тестах может быть null
      marks: json['marks'] != null ? json['marks'] : 0,
    );
    return workType;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id.toString();
    data['name'] = this.name;
    data['units'] = this.units;
    data['marks'] = this.marks;
    return data;
  }
}
