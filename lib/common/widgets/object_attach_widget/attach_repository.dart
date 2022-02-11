import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import 'model/object_attach.dart';

/// интерфейс репозитория
/// тут д.б. подключение датасурсов и соответственно запрос по сети всех имеющихся
/// вложений для объекта
class AttachRepository{

  List<ObjectAttach> _objectAttachList = <ObjectAttach>[].obs;

  List<ObjectAttach> get objectAttachList => _objectAttachList;

  set objectAttachList(List<ObjectAttach> value) {
    _objectAttachList = value;
  }

  /// Заглушка на получение спискаOA, возвращает список аттачей с параметрами, но не сами файлы
  Future<List<ObjectAttach>> getObjectAttaches(int objectId,  bool isPreview) async{
    List<ObjectAttach> stubDataList = <ObjectAttach>[];
     return stubDataList;
  }

  /// Заглушка на отправку OA
  void sendObjectAttaches(List<ObjectAttach> objAttachList) async{
    //TODO: implement me, bNtch
    _objectAttachList.addAll(objAttachList);
  }

  /// Заглушка на операцию удаления аттача
  void deleteObjectAttach(ObjectAttach objectAttach) async{
    //TODO: implement me, bNtch
  }

  /// Заглушка на получение ОА, создает временный файл в системе содержит путь до него в рамках системе
  Future<ObjectAttach?> getObjectAttach(ObjectAttach objectAttach) async{
    //TODO: implement me, bNtch
    return null;
  }

}