import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/graphql/graphql_service.dart';

import 'model/task.dart';

/// Получает информацию о  задачах сотрудника по переданному basicAuth.
/// Использует graphQL для получения информации

class TaskRemoteClient {

  static const String thirdPartyApiAddress = "/argus/graphql/support-service-thirdparty";

  /// Получение простоя IdleTime
  static const String idleTimeQuery = '''    
    id
    reason
    beginTime
    endTime ''';
 /// Получение "легкого" Task, без истории
  static const String taskGraphqlQuery = '''id
  name
  desc
  processTypeName
  taskType
  dueDate
  assignee
  address
  addressComment
  createDate
  isVisit
  isPlanned
  isOutdoor
  isClosed
  latitude
  longitude
  flexibleAttribute {
     key
     value
  }
  idleTimePeriod {
    $idleTimeQuery
  }
  ''';

  late GraphQLService _graphQLService;

  TaskRemoteClient(String basicAuth, String serverAddress) {
    String urlForThirdParty = serverAddress + thirdPartyApiAddress;
    String webSocketUrlForThirdParty = serverAddress + thirdPartyApiAddress;
    this._graphQLService = GraphQLService(
        basicAuth: basicAuth,
        url: urlForThirdParty,
        webSocketUrl: webSocketUrlForThirdParty);
  }

  Future<List<Task>> getOpenedTasks() async {
    // #TODO изменить генерацию запроса
    // TODO подумать про изменение схемы graphql (что бы был доступен вызов myTasks() и myTasks(day))
    String myOpenedTasksQuery = '''
 {  myOpenedTasks {
    $taskGraphqlQuery
 }
 }
''';
    return getTasks(myOpenedTasksQuery, "myOpenedTasks");

  }

  Future<List<Task>> geClosedTasks(DateTime day) async {
    String date = DateFormat('dd.mm.yyyy').format(day);
    String myClosedTasksQuery = '''
 {  
   myClosedTasks(day: "$date") {
    $taskGraphqlQuery
   }
 }''';

   return getTasks(myClosedTasksQuery, "myClosedTasks");
  }

  Future<List<Task>> getTasks  (String queryString, String queryName) async {
    Future<QueryResult> queryResultFuture =
    _graphQLService.query(queryString);
    List<Task> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер не доступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Неавторизован");
        }
        throw Exception("Неожиданная ошибка");
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["$queryName"]).forEach((element) {
        result.add(Task.fromJson(element));
      });
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }
}
