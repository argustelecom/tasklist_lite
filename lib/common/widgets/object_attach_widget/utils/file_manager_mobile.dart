import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tasklist_lite/common/widgets/object_attach_widget/utils/file_manager.dart';

import '../model/object_attach.dart';

class FileManagerMobile extends FileManager {
  Future<void> downloadFile(ObjectAttach objectAttach, BuildContext context) async {
    String fileTmpPath = await _createFileFromString(objectAttach!, context);
    OpenFile.open(fileTmpPath);
  }

  Future<String> _createFileFromString(ObjectAttach objectAttach, BuildContext context) async {
    Uint8List bytes = base64.decode(objectAttach.attachmentData);
    Directory? tempDir = await getExternalStorageDirectory();

    String? path = await FilesystemPicker.open(
      title: 'Сохранить в папку',
      context: context,
      rootDirectory: tempDir!,
      fsType: FilesystemType.folder,
      pickText: 'Сохранить сюда',
      folderIconColor: Colors.amber,
      requestPermission: () async =>
      await Permission.storage.request().isGranted,
    );

    File file = File("$path/" + objectAttach.fileName);
    await file.writeAsBytes(bytes);
    return file.path;
  }
}

FileManager getManager() => FileManagerMobile();


