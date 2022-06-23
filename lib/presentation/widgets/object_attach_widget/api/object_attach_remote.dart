import 'dart:collection';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:tasklist_lite/core/graphql/graphql_service.dart';
import 'package:tasklist_lite/presentation/widgets/object_attach_widget/model/object_attach.dart';
import 'package:tasklist_lite/core/exceptions.dart';

/// Получает информацию по вложениям объекта.
/// Использует graphQL для получения информации
class ObjectAttachRemote {
  static const String envApiAddress = "/graphql/env";

  static const String objectAttachQuery = '''objectAttachmentId
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
        worker {
          id
          family
          name
          surname
          tabNumber
         
        }''';

  late GraphQLService _graphQLService;

  ObjectAttachRemote(String basicAuth, String serverAddress) {
    String urlForEnv = serverAddress + envApiAddress;
    String webSocketUrlForEnv = serverAddress + envApiAddress;
    this._graphQLService = GraphQLService(
        basicAuth: basicAuth, url: urlForEnv, webSocketUrl: webSocketUrlForEnv);
  }

  /// Получение вложения по уже известному идентификатору
  /// objectAttachId - идентификатор конкретного вложения
  Future<ObjectAttach> getObjectAttachById(int objectAttachId) async {
    String objectAttachByIdQuery = '''
     {
      objectAttachmentById(objectAttachmentId: $objectAttachId) {
        $objectAttachQuery
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
        checkError(value.exception!);
      }
      if (!value.isLoading) {
        result = ObjectAttach.fromJson(value.data!["objectAttachmentById"]);
        return result;
      }
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return result;
  }

  /// Получение списка вложений для отдельновзятого объекта
  /// attachedToId - id объекта для которого возвращается список вложений
  Future<List<ObjectAttach>> getAttachmentsByObjectId(int attachedToId) async {
    String attachmentsByObjectId = '''
     {
      attachmentsByObjectId(attachedToId: $attachedToId) {
        $objectAttachQuery
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
        checkError(value.exception!);
      }
      if (!value.isLoading) {
        List.from(value.data!["attachmentsByObjectId"]).forEach((element) {
          result.add(ObjectAttach.fromJson(element));
        });
      }
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return result;
  }

  /// Добавление отдельного вложения
  /// Всегда возвращает null
  Future addObjectAttach(ObjectAttach objectAttach) async {
    String objectAttachJson = objectAttach.toAddMutation();

    String addObjectAttach = '''
     mutation{
      addAttachment(objectAttachment: $objectAttachJson) {
        $objectAttachQuery
      }
    }
    ''';
    Future<QueryResult> queryResultFuture =
        _graphQLService.mutate(addObjectAttach);
    late ObjectAttach result;
    await queryResultFuture.then((value) {
      if (value.hasException) {
        checkError(value.exception!);
      }
      if (value.data == null) {
        throw Exception("value.data == null");
      }
      if (!value.isLoading) {
        if (value.data!["addAttachment"] == null) {
          return null;
        }
        result = ObjectAttach.fromJson(value.data!["addAttachment"]);
        return result;
      }
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return result;
  }

  /// Добавление списка объектов
  /// Всегда возвращает пустой List
  Future addObjectAttachList(List<ObjectAttach> objectAttachList) async {
    String objectAttachJson = IterableBase.iterableToFullString(
        objectAttachList.map((e) => e.toAddMutation()), '[', ']');
    String addObjectAttach = '''
     mutation{
      addAttachmentList(objectAttachmentList: $objectAttachJson) {
       $objectAttachQuery
      }
    }
    ''';
    Future<QueryResult> queryResultFuture =
        _graphQLService.mutate(addObjectAttach);
    List<ObjectAttach> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.hasException) {
        checkError(value.exception!);
      }
      if (value.data == null) {
        throw Exception("value.data == null");
      }
      if (!value.isLoading) {
        if (value.data!["addAttachmentList"] == null) {
          return result;
        }
        List.from(value.data!["addAttachmentList"]).forEach((element) {
          result.add(ObjectAttach.fromJson(element));
        });
      }
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return result;
  }

  /// Всегда возвращает null
  Future deleteObjectAttachById(int objectAttachId) async {
    String deleteObjectAttachById = '''
     mutation{
      deleteObjectAttachById(objectAttachmentId: $objectAttachId) {
       $objectAttachQuery
      }
    }
    ''';
    Future<QueryResult> queryResultFuture =
        _graphQLService.mutate(deleteObjectAttachById);
    late ObjectAttach? result;
    await queryResultFuture.then((value) {
      if (value.hasException) {
        checkError(value.exception!);
      }
      if (value.data == null) {
        throw Exception("value.data == null");
      }
      if (!value.isLoading) {
        if (value.data!["deleteObjectAttachById"] == null) {
          result = null;
          return result;
        } else {
          result = ObjectAttach.fromJson(value.data!["deleteObjectAttachById"]);
          return result;
        }
      }
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return result;
  }

  // TODO необходимо вынести в отдельный класс
  //  используется в TaskRemoteClient, ObjectAttachRemote, NotifyRemoteClient, AuthRemoteClient
  void checkError(OperationException operationException) {
    if (operationException.linkException is ServerException) {
      throw ExternalException("Сервер недоступен");
    }
    if (operationException.linkException is HttpLinkParserException) {
      throw ExternalException("Не авторизован");
    }
    if (operationException.graphqlErrors.isNotEmpty) {
      List errors = operationException.graphqlErrors
          .map((e) => e.message)
          .map((e) => _parseExceptionMessage(e))
          .toList();
      throw ExternalException(errors.join("\n"));
    }
    throw ExternalException("Неожиданная ошибка");
  }

  String _parseExceptionMessage(String message) {
    // учитывая пробел
    return message.substring(message.indexOf(':') + 2);
  }
}
