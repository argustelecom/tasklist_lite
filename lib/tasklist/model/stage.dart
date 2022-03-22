/// Представление об этапе
class Stage {
  /// Наименование этапа
  final String name;

  /// Порядковый номер этапа
  /// в нарядах О2О АВР и РР их 4:
  /// 1-Назначение наряда бригаде, 2-Выезд на объект, 3-Прибытие на объект, 4-Выполнение работ
  final int number;

  /// Является ли этап последним?
  final bool isLast;

  /// Контрольный срок этапа
  final DateTime? dueDate;

  Stage(
      {required this.name,
      required this.number,
      required this.isLast,
      this.dueDate});

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      name: json['name'],
      number: json['number'],
      isLast: json['isLast'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['number'] = this.number;
    data['isLast'] = this.isLast;
    data['endDate'] = this.dueDate != null ? this.dueDate.toString() : null;
    return data;
  }
}
