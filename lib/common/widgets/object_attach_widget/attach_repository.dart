import 'package:get/get.dart';
import 'api/object_attach_remote.dart';
import 'model/object_attach.dart';


/// интерфейс репозитория
/// тут д.б. подключение датасурсов и соответственно запрос по сети всех имеющихся
/// вложений для объекта
class AttachRepository extends GetxService{

  /// Заглушка на отправку OA
  void sendObjectAttaches(List<ObjectAttach> objAttachList) async{
    //TODO: implement me, bNtch
  }

  /// Заглушка на операцию удаления аттача
  void deleteObjectAttach(ObjectAttach objectAttach) async{
    //TODO: implement me, bNtch
  }

  /// Получение конкретного аттача (известен ID), создает временный файл в системе содержит путь до него в рамках системе
  Future<ObjectAttach?> getObjectAttach(String basicAuth, String serverAddress, ObjectAttach objectAttach) async{
    ObjectAttachRemote objectAttachRemote =
    ObjectAttachRemote(basicAuth, serverAddress);
    Future<ObjectAttach> result = objectAttachRemote.getObjectAttachById(objectAttach.id);
    return result;
  }

  /// Получение списка аттачей для известному id объекта
  Future<List<ObjectAttach>> getAttachmentsByObjectId(String basicAuth, String serverAddress, int objectId) async{
    ObjectAttachRemote objectAttachRemote =
    ObjectAttachRemote(basicAuth, serverAddress);
    Future<List<ObjectAttach>> result = objectAttachRemote.getAttachmentsByObjectId(objectId);
    return result;
  }

}

