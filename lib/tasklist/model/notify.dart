import 'package:tasklist_lite/tasklist/model/task.dart';

/// Уведомление по задаче
class Notify {
  int id;

  /// "Время уведомления"
  String time;

  /// "Текст уведомления"
  String text;

  /// "Id задачи"
  Task task;

  /// "Номер задачи"
  String number;

  /// Дата оповещения
  DateTime date;

  /// "Прочитано уведомление"
  bool isReaded;

  Notify(
      {required this.id,
        required this.time,
        required this.text,
        required this.task,
        required this.number,
        required this.date,
        this.isReaded = false
        });

  factory Notify.fromJson(Map<String, dynamic> json) {
    dynamic rawAttributes = json['flexibleAttribute'];
    return Notify(
      id: int.parse(json['id']) ,
      time: json['time'],
      text: json['text'],
      number: json['number'],
      date: DateTime.parse(json['date']),
      // TODO FIX ME фактически проверяют отправлено ли уведомление или нет
      isReaded: json['isExported'] != null ? json['isExported']:false,
      task: Task.fromJson(json['task'])
    );

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id.toString();
    data['time'] = this.time;
    data['text'] = this.text;
    data['number'] = this.number;
    data['date'] = this.date.toString();
    data['isReaded'] = this.isReaded ;
    data['task'] = this.task;
    return data;
  }

}
