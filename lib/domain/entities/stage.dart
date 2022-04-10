import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:intl/intl.dart';

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

  String getDueDateFullText() {
    if (dueDate == null)
      return "";
    else
      return DateFormat("dd.MM.yyyy HH:mm").format(dueDate!);
  }

  bool isStageOverdue() {
    return (dueDate != null) && (dueDate!.isBefore((DateTime.now())));
  }

  // возвращает абсолютную величину интервала от/до КC этапа
  Duration? getTimeLeftStage() {
    if (dueDate != null) {
      if (dueDate!.isAfter(DateTime.now())) {
        return new Duration(
            milliseconds: dueDate!.millisecondsSinceEpoch -
                DateTime.now().millisecondsSinceEpoch);
      } else
        return new Duration(
            milliseconds: DateTime.now().millisecondsSinceEpoch -
                dueDate!.millisecondsSinceEpoch);
    } else
      return null;
  }

  // Возвращаем КВ по этапу
  String getTimeLeftStageText() {
    Duration? timeLeft = getTimeLeftStage();
    if (timeLeft != null)
      return (isStageOverdue() ? "СКВ: " : "КВ: ") +
          prettyDuration(timeLeft,
              tersity: DurationTersity.minute,
              abbreviated: true,
              delimiter: " ",
              spacer: "",
              locale: RussianDurationLanguage());
    else
      return "";
  }

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
