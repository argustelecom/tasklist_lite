/// Оценка работника
class Mark {
  /// Причина начисления/списания баллов
  String reason;

  /// Время начисления/списания баллов
  DateTime createDate;

  /// Количество баллов
  String value;

  /// Сотрудник
  String worker;

  /// Тип
  String type;

  Mark(
      {required this.reason,
      required this.value,
      required this.createDate,
      required this.worker,
      required this.type});

  factory Mark.fromJson(Map<String, dynamic> json) {
    return Mark(
        reason: json['reason'],
        value: json['value'],
        createDate: DateTime.parse(json['createDate']),
        worker: json['worker'],
        type: json['type']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reason'] = this.reason;
    data['value'] = this.value;
    data['worker'] = this.worker;
    data['type'] = this.type;
    data['createDate'] = this.createDate.toString();
    return data;
  }
}
