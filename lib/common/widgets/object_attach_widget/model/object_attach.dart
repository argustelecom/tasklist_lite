import 'dart:convert';
import 'dart:typed_data';

/// Файл-вложение. Должен быть строго ассоциирован/связан с объектом, к которому
/// это вложение выполняется.
/// Для одного объекта может быть множество вложений.
class ObjectAttach{

  /// Идентификатор самого аттача (для удаления)
  int id;

  /// id объекта, к которому мы хотим привязать наш attach
  int objectId;

  /// Имя файла
  String fileName;

  /// Исходный путь к файлу (непонятно зачем он нужен на бэкенде, но пусть будет)
  String filePath;

  /// Содержание файла. По факту это Blob пережатый в Base64, так как QraphQL не
  /// может в кошерный блоб (информация передается посредством JSON)
  /// TODO: необходимо переделать передачу файла на более подходящую технологию
  String attachmentData;

  /// Дата добавления файла
  DateTime createDate;

  /// Сотрудник, добавивший файл
  String workerName;

  ObjectAttach({required this.id, required this.objectId, required this.fileName, required this.filePath,
      required this.attachmentData, required this.createDate, required this.workerName});

  /// Возвращает содержимое файла в виде последовательности байт
  Uint8List attachmentDataAsBytes() {
    Uint8List bytes = base64.decode(this.attachmentData);
    return bytes;
  }

  factory ObjectAttach.fromJson(Map<String, dynamic> json) {
    return ObjectAttach(id: json['attachedToEntityId'],
        objectId: json['attachedToId'],
        fileName: json['fileName'],
        filePath: json['sourceFileName'],
        attachmentData: json['attachmentData'],
        createDate: DateTime.parse(json['createDate']),
        workerName: json['workerName'] == null ? "Неизвестно" : json['workerName']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attachedToEntityId'] = this.id;
    data['attachedToId'] = this.objectId;
    data['fileName'] = this.fileName;
    data['sourceFileName'] = this.filePath;
    data['createDate'] = this.createDate;
    data['workerName'] = this.workerName;

    return data;
  }
}
