import 'dart:convert';
import 'dart:html';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'file_manager.dart';
import '../model/object_attach.dart';

class FileManagerWeb extends FileManager {
  Future<void> downloadFile(ObjectAttach objectAttach, BuildContext context) async {
    final content = objectAttach.attachmentData;
    final anchor = AnchorElement(
        href: "data:application/octet-stream;charset=utf-16le;base64,$content")
      ..setAttribute("download", objectAttach.fileName)
      ..click();
  }

  Future<List<ObjectAttach>?> pickFiles(int attachedToId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        // допустимые расширения выбираемых файлов
        // TODO: нужно вынести во входные параметры виджета
        allowedExtensions: ['doc', 'docx',  'xls', 'xlsx', 'pdf', 'txt', 'log']);

    if (result != null) {
      return result.files.map((file) => webFileToObjectAttach(file, attachedToId)).toList();
    }
    else
      return null;
  }

  ObjectAttach webFileToObjectAttach(PlatformFile file, int attachedToId){
    return ObjectAttach(id: -1, objectId: attachedToId, fileName: file.name, filePath: "",
        attachmentData:base64.encode(file.bytes!.toList()) ,createDate: DateTime.now(), workerName: authController.userInfo!.workerName??"Неизвестен");
  }

}

FileManager getManager() => FileManagerWeb();