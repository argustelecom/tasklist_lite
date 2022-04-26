import 'package:get/get.dart';
import 'package:tasklist_lite/presentation/controllers/auth_controller.dart';
import 'package:tasklist_lite/presentation/state/application_state.dart';

import 'api/object_attach_remote.dart';
import 'model/object_attach.dart';

/// интерфейс репозитория
/// тут д.б. подключение датасурсов и соответственно запрос по сети всех имеющихся
/// вложений для объекта
class AttachRepository extends GetxService {
  AuthController authController = Get.find();
  ApplicationState state = Get.find();

  late String basicAuth = authController.authState.authString.value!;

  //late String basicAuth = "Basic ZGV2ZWxvcGVyOmRldmVsb3Blcg==";
  late String serverAddress = authController.authState.serverAddress.value!;

  Future<void> sendObjectAttaches(List<ObjectAttach> objAttachList) async {
    ObjectAttachRemote objectAttachRemote =
        ObjectAttachRemote(basicAuth, serverAddress);
    await objectAttachRemote.addObjectAttachList(objAttachList);
  }

  Future<void> deleteObjectAttach(ObjectAttach objectAttach) async {
    ObjectAttachRemote objectAttachRemote =
        ObjectAttachRemote(basicAuth, serverAddress);
    await objectAttachRemote.deleteObjectAttachById(objectAttach.id);
  }

  /// Получение конкретного аттача (известен ID), создает временный файл в системе содержит путь до него в рамках системе
  Future<ObjectAttach> getObjectAttach(ObjectAttach objectAttach) async {
    ObjectAttachRemote objectAttachRemote =
        ObjectAttachRemote(basicAuth, serverAddress);
    Future<ObjectAttach> result =
        objectAttachRemote.getObjectAttachById(objectAttach.id);
    return result;
  }

  /// Получение списка аттачей для известному id объекта
  Future<List<ObjectAttach>> getAttachmentsByObjectId(int objectId) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем пустой список
    if (applicationState.inDemonstrationMode.value) {
      List<ObjectAttach> result = List.of({});
      return result;
    }
    ObjectAttachRemote objectAttachRemote =
        ObjectAttachRemote(basicAuth, serverAddress);
    Future<List<ObjectAttach>> result =
        objectAttachRemote.getAttachmentsByObjectId(objectId);
    return result;
  }
}
