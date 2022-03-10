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

  /// Список контактов руководителей
  List<Contact>? contactChiefList;

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
      this.contactChiefList});

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

  /// Имя сотрудника в формате "табельный_номер-Фамилия И.О."
  String getWorkerNameWithTabNo() {
    final name = StringBuffer();
    if (tabNumber != null) {
      name.write("$tabNumber-");
    }
    name.write(family);
    if (workerName != null) {
      name.write(" ");
      name.write(workerName!.substring(0, 1));
      name.write(".");
      if (surname != null) {
        name.write(surname!.substring(0, 1));
        name.write(".");
      }
    }
    return name.toString();
  }

  /// для возможности сохранения в shared preferences
  /// См. про именованные и фабричные конструкторы в дарте, https://www.freecodecamp.org/news/constructors-in-dart/
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    dynamic rawSecurityRoles = json['securityRoles'];
    dynamic rawSecurityRoleNames = json['securityRoleNames'];
    dynamic rawContacts = json['chiefContact'];
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
        contactChiefList:
            rawContacts != null && (rawContacts as List).isNotEmpty
                ? (rawContacts as List).map((e) => Contact.fromJson(e)).toList()
                : List.of({}));
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
    data['contactChefList'] = this.contactChiefList;
    return data;
  }
}

/// Контакт, содержит имя и номер телефона
class Contact {
  String name;
  String? phoneNum;

  Contact({required this.name, this.phoneNum});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(name: json['name'], phoneNum: json['phoneNum']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phoneNum'] = this.phoneNum;
    return data;
  }
}
