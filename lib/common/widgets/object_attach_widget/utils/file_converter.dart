import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tasklist_lite/state/auth_controller.dart';

import '../model/object_attach.dart';

class FileConverter {

  AuthController authController = Get.find();

  /// Конвертация файла(dart:io) в объект для отправки на бэкенд
  ObjectAttach fileToObjectAttach(File file, int objectId){
    return ObjectAttach(id: -1, objectId: objectId, fileName: file.path, filePath: file.path,
        attachmentData:base64.encode(file.readAsBytesSync()) ,createDate: DateTime.now(), workerName: authController.authState.userInfo.value!.workerName??"Неизвестен");
  }

  /// Конвертация файла изображения(dart:io) в объект для отправки на бэкенд
  Future<ObjectAttach> fileXToObjectAttach(XFile xFile, int objectId) async {
    Uint8List fileData = await xFile.readAsBytes();
    return ObjectAttach(id:-1 , objectId: objectId, fileName:xFile.name, filePath:xFile.path,
        attachmentData:base64.encode(fileData), createDate: DateTime.now(), workerName: authController.authState.userInfo.value!.workerName??"Неизвестен");
  }

  /// Конвертация Base64 -> Файл. Сохранение во временном каталоге, возвращает путь до файла
  Future<String> _createFileFromString(ObjectAttach objectAttach) async {
    Uint8List bytes = base64.decode(objectAttach.attachmentData);
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File(
        "$tempPath/" + objectAttach.fileName);
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Конвертация Файл -> Base64. Для передачи через GraphQL
  Future<String> _createStringFromFile(String path) async {
    File file = File(path);
    List<int> fileBytes = file.readAsBytesSync();
    return base64Encode(fileBytes);
  }
}