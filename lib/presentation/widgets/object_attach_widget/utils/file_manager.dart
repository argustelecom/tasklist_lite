import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/presentation/controllers/auth_controller.dart';

import '../model/object_attach.dart';
import 'file_manager_stub.dart'
    if (dart.library.io) 'file_manager_mobile.dart'
    if (dart.library.js) 'file_manager_web.dart';

abstract class FileManager {
  AuthController authController = Get.find();

  static FileManager _instance = getManager();

  static FileManager get instance {
    return _instance;
  }

  Future<void> downloadFile(ObjectAttach objectAttach, BuildContext context);

  Future<List<ObjectAttach>?> pickFiles(int attachedToId);
}