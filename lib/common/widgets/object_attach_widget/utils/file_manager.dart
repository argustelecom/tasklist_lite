import 'package:flutter/widgets.dart';

import 'file_manager_stub.dart'
if (dart.library.io) 'file_manager_mobile.dart'
if (dart.library.js) 'file_manager_web.dart';
import '../model/object_attach.dart';

abstract class FileManager {
  static FileManager _instance = getManager();

  static FileManager get instance {
    _instance ??= getManager();
    return _instance;
  }

  Future<void> downloadFile(ObjectAttach objectAttach, BuildContext context);
}