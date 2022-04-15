import 'dart:collection';

import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:tasklist_lite/domain/entities/stage.dart';
import 'package:tasklist_lite/domain/entities/work.dart';
import 'package:tasklist_lite/domain/entities/worker.dart';

import 'idle_time.dart';

/// Представление о задаче
class Task {
  final String systemAttrGroup = "Общие сведения";

  final int id;

  /// "Номер"
  final String name;

  /// Этап задачи
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

  /// "Контрольный срок задачи"
  DateTime? dueDate;

  /// TODO: должен ли быть системным?
  ///int? priority;

  /// "Исполнители"
  List<Worker> assignee = <Worker>[];

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
  String? commentary;

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

  /// "Плановое время окончание работы.(Только для ТО/плановых работ)"
  DateTime? scheduledDate;

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
      this.commentary,
      this.createDate,
      this.closeDate,
      this.isClosed = false,
      this.isVisit = false,
      this.isPlanned = false,
      this.isOutdoor = false,
      this.scheduledDate,
      required this.flexibleAttribs,
      this.idleTimeList,
      this.works});

  String getAssigneeListToText(bool withTabNo) {
    return withTabNo
        ? assignee.map((e) => e.getWorkerShortNameWithTabNo()).join(', ')
        : assignee.map((e) => e.getWorkerShortName()).join(', ');
  }

  bool isTaskOverdue() {
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
      return (isTaskOverdue() ? "СКВ: " : "КВ: ") +
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

  String getScheduledDateFulltext(){
    if (scheduledDate == null)
      return "";
    else
      return DateFormat("dd.MM.yyyy HH:mm").format(scheduledDate!);
  }

  String getCreateDateFulltext(){
    if (createDate == null)
      return "";
    else
      return DateFormat("dd.MM.yyyy HH:mm").format(createDate!);
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

  // TODO: Используется в закрытии наряда. НИ надо будет поправить потом?
  // LinkedHashMap выбран намеренно, чтобы выводить параметры в том порядке, в котором получили
  LinkedHashMap<String, Object?> getAttrValuesByGroup(String group) {
    LinkedHashMap<String, Object?> attrValues =
        new LinkedHashMap<String, Object?>();
    if (group.compareTo(systemAttrGroup) == 0) {
      attrValues.addAll(new LinkedHashMap.of({
        "Исполнители": getAssigneeListToText(false),
        "Адрес": address,
        "Адресное примечание": addressComment,
        "Широта": latitude,
        "Долгота": longitude,
        "Примечание": commentary
      }));
    } else
      flexibleAttribs.forEach((key, value) {
        if (key.startsWith("$group/"))
          attrValues.addAll({key.substring(key.indexOf("/") + 1): value});
      });
    return attrValues;
  }

  /// Получаем атрибуты для вкладки сведения
  LinkedHashMap<String, Object?> getAttrValuesByTask() {
    LinkedHashMap<String, Object?> attrValues =
        new LinkedHashMap<String, Object?>();
    attrValues.addAll(new LinkedHashMap.of({
      "Наименование": flexibleAttribs["Объект/Название"],
      "ID заявки оператора": flexibleAttribs["Наряд/ID заявки оператора"],
      "Адресное примечание": addressComment,
      "Оператор": flexibleAttribs["Наряд/Оператор"],
      "Договор": flexibleAttribs["Наряд/Договор"],
      "Примечание": commentary,
      "Представитель заказчика": flexibleAttribs["Представитель заказчика"],
      "Исполнители": getAssigneeListToText(false),
      "Приоритет": flexibleAttribs["Наряд/Приоритет"],
      "Кластер": flexibleAttribs["Кластер"],
    }));
    return attrValues;
  }

  /// Получаем состояние для прогрессбариков
  getStageProgressStatus(int num, Stage stage) {
    if (isClosed) {
      return 1;
    }
    var _stageNumber = stage.number.toInt();
    if (num < _stageNumber) {
      return 1;
    } else if (num == stage.number) {
      return 0.73;
    } else {
      return 0;
    }
  }

  IdleTime? getCurrentIdleTime() {
    IdleTime? idleTime;
    if (idleTimeList != null && idleTimeList!.isNotEmpty) {
      try {
        idleTime = idleTimeList!.firstWhere((e) => !e.isCompleted());
      } on StateError catch (e) {
        Logger log = Logger(this.runtimeType.toString());
        log.warning("В задаче отсутствуют открытые простои", e);
      }
    }
    return idleTime;
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
        commentary: json['commentary'],
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
        scheduledDate: json['scheduledDate']!= null ? DateTime.parse(json['scheduledDate']) : null,
        ttmsId: json['ttmsId'],

        // TODO
        flexibleAttribs: LinkedHashMap<String, Object?>.fromIterable(
            json['flexibleAttribute'],
            key: (e) => e["key"],
            value: (e) => e["value"]),
        idleTimeList: json['idleTimePeriod'] != null
            ? List<IdleTime>.from((json['idleTimePeriod'])
                .map((e) => IdleTime.fromJson(e))
                .toList())
            : null,
        stage: json['stage'] != null ? Stage.fromJson(json['stage']) : null,
        assignee: List<Worker>.from(
            (json['assignee']).map((e) => Worker.fromJson(e)).toList()),
        works: json['works'] != null
            ? List<Work>.from(
                (json['works']).map((e) => Work.fromJson(e)).toList())
            : null);
    return task;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id.toString();
    data['name'] = this.name;
    data['desc'] = this.desc;
    data['processTypeName'] = this.processTypeName;
    data['taskType'] = this.taskType;
    data['dueDate'] = this.dueDate != null ? this.dueDate.toString() : null;
    data['address'] = this.address;
    data['addressComment'] = this.addressComment;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['comment'] = this.commentary;
    data['createDate'] =
        this.createDate != null ? this.createDate.toString() : null;
    data['closeDate'] =
        this.closeDate != null ? this.closeDate.toString() : null;
    data['isClosed'] = this.isClosed;
    data['isVisit'] = this.isVisit;
    data['isPlanned'] = this.isPlanned;
    data['isOutdoor'] = this.isOutdoor;
    data['ttmsId'] = this.ttmsId;
    data['scheduledDate'] = this.scheduledDate != null ? this.scheduledDate.toString() : null;
    data['flexibleAttribute'] =
        this.flexibleAttribs.entries.map((e) => toMapJson(e)).toList();
    data['idleTimePeriod'] = this.idleTimeList != null
        ? this.idleTimeList!.map((e) => e.toJson()).toList()
        : null;
    data['stage'] = this.stage != null ? this.stage!.toJson() : null;
    data['assignee'] = this.assignee.map((e) => e.toJson()).toList();
    data['works'] =
        this.works != null ? this.works!.map((e) => e.toJson()).toList() : null;
    return data;
  }

  Map<String, Object?> toMapJson(MapEntry mapEntry) {
    Map<String, Object?> map = Map();
    map.putIfAbsent("__typename", () => "FlexibleAttribute");
    map.putIfAbsent("key", () => mapEntry.key.toString());
    map.putIfAbsent("value", () => mapEntry.value);
    return map;
  }
}