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
    // #TODO: если это делать в момент запуска приложения, получается долго (сервер отвечает более 1с)
    // это должен быть push или graphql subscription или что-то вроде
    Future<QueryResult> queryResultFuture =
        _graphQLService.query(myNotify);
    List<Notify> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.hasException) {
        throw Exception(value.exception);
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
}
