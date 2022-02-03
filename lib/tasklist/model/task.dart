import 'dart:collection';
import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:intl/intl.dart';

import 'idle_time.dart';

/// Представление о задаче
class Task {
  final String systemAttrGroup = "Общие сведения";

  final int id;

  /// "Номер"
  final String name;

  /// "Название"
  final String? desc;

  /// "Тип наряда"
  String? processTypeName;

  /// "Тип задачи"
  String? taskType;

  /// TODO задачи или этапа? нужен ли еще один параметр?
  /// "Контрольный срок"
  DateTime? dueDate;

  /// TODO: должен ли быть системным?
  ///int? priority;

  /// "Исполнители"
  String? assignee;

  /// TODO: телефон, контактное лицо нужны?

  /// TODO: должен ли быть системным?
  /// "Объект работ"
  ///String? objectName;

  /// "Адрес работ"
  String? address;

  /// "Адресное примечание"
  String? addressComment;

  /// "Широта"
  String? latitude;

  /// "Долгота"
  String? longitude;

  /// "Примечание"
  String? comment;

  /// "Дата создания задачи"
  DateTime? createDate;

  /// "Дата завершения задачи"
  DateTime? closeDate;

  /// "Задача завершена"
  bool isClosed;

  /// "Является задачей визита"
  bool isVisit;

  /// "Задача должна быть запланирована"
  bool isPlanned;

  /// "Является выездной задачей"
  bool isOutdoor;

  /// Гибкие атрибуты
  LinkedHashMap<String, Object?>? flexibleAttribs;

  /// Простой
  IdleTime? idleTime;

  // null safety: здесь null`ами не может быть только id, name (т.к. они обязательны) и булевы свойства (т.к. для них задан дефолт в дефолтном конструкторе)
  // что интересно, фигурные скобочки внутри объявления конструктора делают параметры именованными, их теперь можно задавать не по порядку, а по имени. Удобно.
  Task(
      {required this.id,
      required this.name,
      this.desc,
      this.processTypeName,
      this.taskType,
      this.dueDate,
      this.assignee,
      this.address,
      this.addressComment,
      this.latitude,
      this.longitude,
      this.comment,
      this.createDate,
      this.closeDate,
      this.isClosed = false,
      this.isVisit = false,
      this.isPlanned = false,
      this.isOutdoor = false,
      this.flexibleAttribs,
      this.idleTime});

  bool isOverdue() {
    return (dueDate != null) && (dueDate!.isBefore((DateTime.now())));
  }

  // возвращает абсолютную величину интервала от/до КC задачи
  Duration? getTimeLeftAbs() {
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

  String getTimeLeftText() {
    Duration? timeLeft = getTimeLeftAbs();
    if (timeLeft != null)
      return (isOverdue() ? "СКВ: " : "КВ: ") +
          prettyDuration(timeLeft,
              tersity: DurationTersity.minute,
              abbreviated: true,
              delimiter: " ",
              spacer: "",
              locale: RussianDurationLanguage());
    else
      return "";
  }

  String getDueDateShortText() {
    if (dueDate == null)
      return "";
    else if (dueDate!.day == DateTime.now().day)
      return DateFormat("HH:mm").format(dueDate!);
    else
      return DateFormat("d MMM HH:mm", "ru").format(dueDate!);
  }

  String getDueDateFullText() {
    if (dueDate == null)
      return "";
    else
      return DateFormat("dd.MM.yyyy HH:mm").format(dueDate!);
  }

  String getAddressDescription() {
    if (addressComment != null) return addressComment!;
    if (address != null) return address!;
    if (latitude != null && longitude != null)
      return "$latitude, $longitude";
    else
      return "";
  }

  // LinkedHashSet выбран намеренно, чтобы выводить группы в том порядке, в котором получили
  LinkedHashSet<String> getAttrGroups() {
    LinkedHashSet<String> attrGroups = new LinkedHashSet<String>();
    // Добавим системную группу
    attrGroups.add(systemAttrGroup);
    // Добавим группы гибких атрибутов
    if (flexibleAttribs != null) {
      flexibleAttribs?.keys.forEach((e) {
        attrGroups.add(e.substring(0, e.indexOf("/")));
      });
    }
    return attrGroups;
  }

  // LinkedHashMap выбран намеренно, чтобы выводить параметры в том порядке, в котором получили
  LinkedHashMap<String, Object?> getAttrValuesByGroup(String group) {
    LinkedHashMap<String, Object?> attrValues =
        new LinkedHashMap<String, Object?>();
    if (group.compareTo(systemAttrGroup) == 0) {
      attrValues.addAll(new LinkedHashMap.of({
        "Исполнители": assignee,
        "Адрес": address,
        "Адресное примечание": addressComment,
        "Широта": latitude,
        "Долгота": longitude,
        "Примечание": comment
      }));
    } else if (flexibleAttribs != null) {
      flexibleAttribs?.forEach((key, value) {
        if (key.startsWith("$group/"))
          attrValues.addAll({key.substring(key.indexOf("/") + 1): value});
      });
    }
    return attrValues;
  }
}
