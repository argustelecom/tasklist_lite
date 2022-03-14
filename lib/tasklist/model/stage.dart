/// Представление об этапе
class Stage {
  /// Наименование этапа
  final String name;

  /// Номер этапа
  late final int number;

  /// Является ли этап последним?
  final bool isLast;

  /// Контрольное время по этапу
  final DateTime dueDate;

  Stage(
      {required this.name,
      required this.number,
      required this.isLast,
      required this.dueDate});
}
