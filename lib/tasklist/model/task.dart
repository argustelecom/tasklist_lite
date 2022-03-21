import 'dart:collection';
import 'dart:convert';

import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/tasklist/model/stage.dart';
import 'package:tasklist_lite/tasklist/model/work.dart';
import 'package:tasklist_lite/tasklist/model/worker.dart';

import 'idle_time.dart';

/// Представление о задаче
class Task {
  final String systemAttrGroup = "Общие сведения";

  final int id;

  /// "Номер"
  final String name;

  /// Этап наряда
  Stage? stage;

  //используем в кнопке проверка аварии
  /// Внешний номер объекта в наряде
  String? ttmsId;

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
  List<Worker> assignee = <Worker>[];

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
  Map<String, Object?> flexibleAttribs = LinkedHashMap();

  /// Простой
  List<IdleTime>? idleTimeList = <IdleTime>[];

  /// Работы
  List<Work>? works = <Work>[];

  // null safety: здесь null`ами не может быть только id, name (т.к. они обязательны) и булевы свойства (т.к. для них задан дефолт в дефолтном конструкторе)
  // что интересно, фигурные скобочки внутри объявления конструктора делают параметры именованными, их теперь можно задавать не по порядку, а по имени. Удобно.
  Task(
      {required this.id,
      required this.name,
      this.stage,
      this.desc,
      this.ttmsId,
      this.processTypeName,
      this.taskType,
      this.dueDate,
      required this.assignee,
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
      required this.flexibleAttribs,
      this.idleTimeList,
      this.works});

  String getAssigneeListToText(List<Worker> workers) {
    return workers.map((e) => e.getWorkerShortName()).join(', ');
  }

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
    flexibleAttribs.keys.forEach((e) {
      attrGroups.add(e.substring(0, e.indexOf("/")));
    });
    return attrGroups;
  }

  // LinkedHashMap выбран намеренно, чтобы выводить параметры в том порядке, в котором получили
  LinkedHashMap<String, Object?> getAttrValuesByGroup(String group) {
    LinkedHashMap<String, Object?> attrValues =
        new LinkedHashMap<String, Object?>();
    if (group.compareTo(systemAttrGroup) == 0) {
      attrValues.addAll(new LinkedHashMap.of({
        "Исполнители": getAssigneeListToText(assignee),
        "Адрес": address,
        "Адресное примечание": addressComment,
        "Широта": latitude,
        "Долгота": longitude,
        "Примечание": comment
      }));
    } else
      flexibleAttribs.forEach((key, value) {
        if (key.startsWith("$group/"))
          attrValues.addAll({key.substring(key.indexOf("/") + 1): value});
      });
    return attrValues;
  }

  IdleTime? getCurrentIdleTime() {
    if (idleTimeList != null && idleTimeList!.isNotEmpty) {
      return idleTimeList!.firstWhere((e) => !e.isCompleted(), orElse: null);
    } else
      return null;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    Task task = Task(
        id: int.parse(json['id']),
        name: json['name'],
        desc: json['desc'],
        processTypeName: json['processTypeName'],
        taskType: json['taskType'],
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        address: json['address'],
        addressComment: json['addressComment'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        comment: json['comment'],
        createDate: json['createDate'] != null
            ? DateTime.parse(json['createDate'])
            : null,
        closeDate: json['closeDate'] != null
            ? DateTime.parse(json['closeDate'])
            : null,
        isClosed: json['isClosed'],
        isVisit: json['isVisit'],
        isPlanned: json['isPlanned'],
        isOutdoor: json['isOutdoor'],

        // TODO
        flexibleAttribs: LinkedHashMap<String, Object?>.fromIterable(
            json['flexibleAttribute'],
            key: (e) => e["key"],
            value: (e) => e["value"]),
        idleTimeList:
            json['idleTime'] != null && (json['idleTime'] as List).isNotEmpty
                ? (json['idleTime']).map((e) => IdleTime.fromJson(e)).toList()
                : List.of({}),
        assignee: List<Worker>.from((json['assignee']).map((e) => Worker.fromJson(e)).toList()));
    return task;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['desc'] = this.desc;
    data['processTypeName'] = this.processTypeName;
    data['taskType'] = this.taskType;
    data['dueDate'] = this.dueDate != null ? this.dueDate.toString() : null;
    data['address'] = this.address;
    data['addressComment'] = this.addressComment;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['comment'] = this.comment;
    data['createDate'] =
        this.createDate != null ? this.createDate.toString() : null;
    data['closeDate'] =
        this.closeDate != null ? this.closeDate.toString() : null;
    data['isClosed'] = this.isClosed;
    data['isVisit'] = this.isVisit;
    data['isPlanned'] = this.isPlanned;
    data['isOutdoor'] = this.isOutdoor;
    data['flexibleAttribute'] = jsonEncode(this.flexibleAttribs);
    data['idleTimeList'] = jsonEncode(this.idleTimeList);
    data['assignee'] = jsonEncode(this.assignee);
    return data;
  }
}
