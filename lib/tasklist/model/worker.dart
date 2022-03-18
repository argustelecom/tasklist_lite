/// Работник
class Worker {
  /// ID работника
  int id;

  /// Фамилия работника
  String family;

  /// Имя работника
  String? name;

  /// Отчество работника
  String? surname;

  /// Табельный номер
  String? tabNumber;

  /// Название оновного участка
  String? mainWorksite;

  Worker(
      {required this.id,
      required this.family,
      this.name,
      this.surname,
      this.mainWorksite,
      this.tabNumber});

  /// Имя работника в формате "Фамилия И.О."
  String getWorkerShortName() {
    final result = StringBuffer();
    result.write(family);
    if (name != null) {
      result.write(" ");
      result.write(name!.substring(0, 1));
      result.write(".");
      if (surname != null) {
        result.write(surname!.substring(0, 1));
        result.write(".");
      }
    }
    return result.toString();
  }

  /// Имя работника в формате "табельный_номер- Фамилия И.О."
  String getWorkerShortNameWithTabNo() {
    final result = StringBuffer();
    if (tabNumber != null) {
      result.write("$tabNumber- ");
    }
    result.write(family);
    if (name != null) {
      result.write(" ");
      result.write(name!.substring(0, 1));
      result.write(".");
      if (surname != null) {
        result.write(surname!.substring(0, 1));
        result.write(".");
      }
    }
    return result.toString();
  }
}
