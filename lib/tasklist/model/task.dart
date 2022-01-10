/// Представление о задаче
class Task {
  final int id;

  /// "Номер"
  final String name;

  /// "Название"
  final String? desc;

  /// "Тип наряда"
  String? processTypeName;

  /// #TODO: тип поля и правильная нотация
  String? dueDate;

  int? priority;

  /// "кому назначено"
  String? assignee;

  /// "объект работ"
  String? objectName;

  /// "адрес работ"
  String? address;

  /// "примечание"
  String? comment;

  String? createDate;

  /// "задача визита"
  bool isVisit;

  /// "задача должна быть запланирована"
  bool isPlanned;

  /// "задача выезда"
  bool isOutdoor;

  // null safety: здесь null`ами не может быть только id, name (т.к. они обязательны) и булевы свойства (т.к. для них задан дефолт в дефолтном конструкторе)
  // что интересно, фигурные скобочки внутри объявления конструктора делают параметры именованными, их теперь можно задавать не по порядку, а по имени. Удобно.
  Task(
      {required this.id,
      required this.name,
      this.desc,
      this.processTypeName,
      this.dueDate,
      this.priority,
      this.assignee,
      this.objectName,
      this.address,
      this.comment,
      this.createDate,
      this.isVisit = false,
      this.isPlanned = false,
      this.isOutdoor = false});
}
