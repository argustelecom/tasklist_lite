import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/graphql/graphql_service.dart';
import 'package:tasklist_lite/tasklist/model/notify.dart';
import 'package:tasklist_lite/tasklist/task_remote_client.dart';

import 'model/task.dart';

/// Получает информацию о  задачах сотрудника по переданному basicAuth.
/// Использует graphQL для получения информации

class NotifyRemoteClient {

  static const String thirdPartyApiAddress = "/argus/graphql/support-service-thirdparty";

  late GraphQLService _graphQLService;

  NotifyRemoteClient(String basicAuth, String serverAddress) {
    String urlForThirdParty = serverAddress + thirdPartyApiAddress;
    String webSocketUrlForThirdParty = serverAddress + thirdPartyApiAddress;
    this._graphQLService = GraphQLService(
        basicAuth: basicAuth,
        url: urlForThirdParty,
        webSocketUrl: webSocketUrlForThirdParty);
  }

  Future<List<Notify>> getNotify() async {
    // #TODO изменить генерацию запроса
    // TODO подумать про изменение схемы graphql (что бы был доступен вызов myTasks() и myTasks(day))
    String myNotify = '''
 { notify{
  id
  time
  date
  taskId
  text
  number
  numberId
  isExported
  task {
   ${TaskRemoteClient.taskGraphqlQuery}
 }
}
 }
''';
     // TODO Единообразный вызов вместе с Task_remote_client
    Future<QueryResult> queryResultFuture =
        _graphQLService.query(myNotify);
    List<Notify> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.hasException) {
        checkError(value.exception!);
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["notify"]).forEach((element) {
        result.add(Notify.fromJson(element));
      });
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }

  // TODO необходимо вынести в отдельный класс
  //  используется в TaskRemoteClient, ObjectAttachRemote, NotifyRemoteClient, AuthRemoteClient
  void checkError(OperationException operationException) {
    if (operationException.linkException is ServerException) {
      throw Exception("Сервер недоступен");
    }
    if (operationException.linkException is HttpLinkParserException) {
      throw Exception("Не авторизован");
    }
    if (operationException.graphqlErrors.isNotEmpty) {
      List errors = operationException.graphqlErrors
          .map((e) => e.message)
          .map((e) => _parseExceptionMessage(e))
          .toList();
      throw Exception(errors.toString());
    }
    throw Exception("Неожиданная ошибка");
  }

  String _parseExceptionMessage(String message) {
    // учитывая пробел
    return message.substring(message.indexOf(':') + 2);
  }
}
