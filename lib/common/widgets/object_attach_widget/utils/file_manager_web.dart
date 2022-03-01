import 'package:flutter/widgets.dart';

import 'file_manager.dart';
import "dart:html" as htmlFile;

import '../model/object_attach.dart';

class FileManagerWeb extends FileManager {
  Future<void> downloadFile(ObjectAttach objectAttach, BuildContext context) async {
    final content = objectAttach.attachmentData;
    final anchor = htmlFile.AnchorElement(
        href: "data:application/octet-stream;charset=utf-16le;base64,$content")
      ..setAttribute("download", objectAttach.fileName)
      ..click();
  }
}

FileManager getManager() => FileManagerWeb();