/// Уведомление по задаче
class Notify {
  int id;

  /// "Время уведомления"
  String time;

  /// "Текст уведомления"
  String text;

  /// "Id задачи"
  int task;

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
}
