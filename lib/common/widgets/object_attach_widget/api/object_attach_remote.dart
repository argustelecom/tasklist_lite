import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:tasklist_lite/common/widgets/object_attach_widget/model/object_attach.dart';
import 'package:tasklist_lite/graphql/graphql_service.dart';


/// Получает информацию по вложениям объекта.
/// Использует graphQL для получения информации
class ObjectAttachRemote {

  static const String envApiAddress = "/argus/graphql/env";

  late GraphQLService _graphQLService;

  ObjectAttachRemote(String basicAuth, String serverAddress) {
    String urlForEnv = serverAddress + envApiAddress;
    String webSocketUrlForEnv = serverAddress + envApiAddress;
    this._graphQLService = GraphQLService(
        basicAuth: basicAuth,
        url: urlForEnv,
        webSocketUrl: webSocketUrlForEnv);
  }

  /// Получение вложения по уже известному идентификатору
  /// objectAttachId - идентификатор конкретного вложения
  Future<ObjectAttach> getObjectAttachById(int objectAttachId) async {
    String objectAttachByIdQuery = '''
     {
      objectAttachmentById(objectAttachmentId: $objectAttachId) {
        attachedToEntityId
        attachedToId
        createDate
        fileName
        sourceFileName
        readOnly
        md5
        attachType
        attachmentData
        tag
        remoteStoragePath
        deleteDate
      }
    }
    ''';
    // #TODO: если это делать в момент запуска приложения, получается долго (сервер отвечает более 1с)
    // это должен быть push или graphql subscription или что-то вроде
    Future<QueryResult> queryResultFuture =
    _graphQLService.query(objectAttachByIdQuery);
    late ObjectAttach result;
    await queryResultFuture.then((value) {
      if (value.hasException) {
        throw Exception(value.exception);
      }
      if (value.data == null) {
        throw Exception("value.data == null");
      }
      if (!value.isLoading) {
        result = ObjectAttach.fromJson(value.data!["objectAttachmentById"]);
        return result;
      }
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }

  /// Получение списка вложений для отдельновзятого объекта
  /// attachedToId - id объекта для которого возвращается список вложений
  Future<List<ObjectAttach>> getAttachmentsByObjectId(int attachedToId) async {
    String attachmentsByObjectId = '''
     {
      attachmentsByObjectId(attachedToId: $attachedToId) {
        attachedToEntityId
        attachedToId
        createDate
        fileName
        sourceFileName
        readOnly
        md5
        attachType
        attachmentData
        tag
        remoteStoragePath
        deleteDate
      }
    }
    ''';
    // #TODO: если это делать в момент запуска приложения, получается долго (сервер отвечает более 1с)
    // это должен быть push или graphql subscription или что-то вроде
    Future<QueryResult> queryResultFuture =
    _graphQLService.query(attachmentsByObjectId);
    List<ObjectAttach> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.hasException) {
        throw Exception(value.exception);
      }
      if (value.data == null) {
        throw Exception("value.data == null");
      }
      if (!value.isLoading) {
        List.from(value.data!["attachmentsByObjectId"]).forEach((element) {
          result.add(ObjectAttach.fromJson(element));
        });
      }
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }
}
