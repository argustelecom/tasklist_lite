import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/graphql/graphql_service.dart';

import 'model/task.dart';

/// Получает информацию о  задачах сотрудника по переданному basicAuth.
/// Использует graphQL для получения информации

class TaskRemoteClient {

  static const String thirdPartyApiAddress = "/argus/graphql/support-service-thirdparty";

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
    id
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
    flexibleAttribute{
      key
      value
    }

 }
 }
''';
    // #TODO: если это делать в момент запуска приложения, получается долго (сервер отвечает более 1с)
    // это должен быть push или graphql subscription или что-то вроде
    Future<QueryResult> queryResultFuture =
        _graphQLService.query(myOpenedTasksQuery);
    List<Task> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.hasException) {
        throw Exception(value.exception);
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["myOpenedTasks"]).forEach((element) {
        result.add(Task.fromJson(element));
      });
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }

  Future<List<Task>> geClosedTasks(DateTime day) async {
    String date = DateFormat('dd.mm.yyyy').format(day);
    String myClosedTasksQuery = '''
 {  
   myClosedTasks(day: "$date") {
    id
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
    flexibleAttribute{
      key
      value
    }
   }
 }''';

    Future<QueryResult> queryResultFuture =
        _graphQLService.query(myClosedTasksQuery);
    List<Task> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.hasException) {
        throw Exception(value.exception);
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["myClosedTasks"]).forEach((element) {
        result.add(Task.fromJson(element));
      });
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }
}
