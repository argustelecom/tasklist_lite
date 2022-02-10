import 'dart:collection';

class UserInfo {
  /// Имя учетной записи. Отображается в top_user_bar сверху
  String userName;

  /// Домашний регион пользвателя. Отображается в top_user_bar
  String homeRegionName;

  /// Общая информация Профиля работника.
  final String systemAttrGroup = "Общая информация";

  /// Имя работника
  String? workerName;

  /// Фамилия работника
  String family;

  /// Отчество работника
  String? surname;

  /// Табельный номер
  String? tabNumber;

  /// Основной участок
  String? mainWorksite;

  /// Почтовый адрес
  String? email;

  /// Должность
  String? workerAppoint;

  /// Гибкие атрибуты информация об руководителе
  LinkedHashMap<String, Object?>? flexibleAttribs;

  /// Права доступа пользователя (строковые human-readable id)
  List<String> securityRoles;

  /// Права доступа пользователя (caption`ы в кириллической нотации)
  List<String> securityRoleNames;

  UserInfo(
      {required this.userName,
      required this.homeRegionName,
      required this.securityRoles,
      required this.securityRoleNames,
      required this.family,
      this.workerName,
      this.surname,
      this.email,
      this.mainWorksite,
      this.tabNumber,
      this.workerAppoint,
      this.flexibleAttribs});

  /// Строка ФИО в равернутом виде. Например: Иванов Иван Иванович
  String getFullWorkerName() {
    if (workerName != null) {
      if (surname != null) {
        return "$family $workerName $surname";
      } else {
        return "$family $workerName";
      }
    } else
      return family;
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
        "ФИО": getFullWorkerName(),
        "Табельный номер": tabNumber,
        "Почтовый адрес": email,
        "Должность": workerAppoint,
        "Основной участок": mainWorksite,
      }));
    } else if (flexibleAttribs != null) {
      flexibleAttribs?.forEach((key, value) {
        if (key.startsWith("$group/"))
          attrValues.addAll({key.substring(key.indexOf("/") + 1): value});
      });
    }
    return attrValues;
  }

  /// для возможности сохранения в shared preferences
  /// См. про именованные и фабричные конструкторы в дарте, https://www.freecodecamp.org/news/constructors-in-dart/
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    dynamic rawSecurityRoles = json['securityRoles'];
    dynamic rawSecurityRoleNames = json['securityRoleNames'];
    return UserInfo(
        userName: json['userName'],
        homeRegionName: json['homeRegionName'],
        securityRoles:
            // если список пуст, дарт не может догадаться, к какому типу кастить dynamic, получаем
            // Expected a value of type 'List<String>', but got one of type 'List<dynamic>'
            rawSecurityRoles != null && (rawSecurityRoles as List).isNotEmpty
                // кстати, ту же ошибку получим, если кастить как (rawSecurityRoles as List<String>), надо именно через метод .cast<String>()
                ? rawSecurityRoles.cast<String>()
                : List.of({}),
        securityRoleNames: rawSecurityRoleNames != null &&
                (rawSecurityRoleNames as List).isNotEmpty
            ? rawSecurityRoleNames.cast<String>()
            : List.of({}),
        family: json['family'],
        workerName: json['workerName'],
        surname: json['surname'],
        email: json['email'],
        mainWorksite: json['mainWorksite'],
        tabNumber: json['tabNumber'],
        workerAppoint: json['workerAppoint'],
        flexibleAttribs: LinkedHashMap<String, Object?>.fromIterable(
            json['flexibleAttribute'],
            key: (e) => e["key"],
            value: (e) => e["value"]));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['homeRegionName'] = this.homeRegionName;
    data['securityRoles'] = this.securityRoles;
    data['securityRoleNames'] = this.securityRoleNames;
    data['family'] = this.family;
    data['workerName'] = this.workerName;
    data['surname'] = this.surname;
    data['email'] = this.email;
    data['mainWorksite'] = this.mainWorksite;
    data['tabNumber'] = this.tabNumber;
    data['workerAppoint'] = this.workerAppoint;
    data['flexibleAttribute'] = this.flexibleAttribs;
    return data;
  }
}
