class ObjectAttach{

  /// Идентификатор самого аттача (для удаления)
  int id;

  /// id произвольного объекта, к которому мы хотим привязать наш attach
  int objectId;

  /// Имя файла
  String fileName;

  /// Исходный путь к файлу
  String filePath;

  /// Дата добавления файла
  DateTime createDate;

  /// Сотрудник, добавивший файл
  String workerName;

  ObjectAttach(this.id, this.objectId, this.fileName, this.filePath,
      this.createDate, this.workerName);
}