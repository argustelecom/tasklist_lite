import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/graphql/graphql_service.dart';

import 'model/task.dart';

/// #TODO: должен доставать задачки по Rest с помощью запросов graphQL, например, как это делается во flutter_movie
class TaskRemoteClient {
  // #TODO: избавиться от хардкода
  static final String urlForTests = "http://localhost:8080/argus/graphql/support-service-thirdparty";
  static final String webSocketUrlForTests = "http://localhost:8080/argus/graphql/support-service-thirdparty";

  final GraphQLService _graphQLService =
      // #TODO: нужны осмысленные значения url
      // #TODO: нужно пробрасывать параметры аутентификации
      GraphQLService(url: urlForTests, webSocketUrl: webSocketUrlForTests);

  Future<List<Task>> getOpenedTasks() async{
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
      if (value.data == null) {
        print("value.data == null ");
        return result;
      }
      if (value.isLoading) {
        print("value.isLoading ");
        return result;
      }
     List.from( value.data!["myOpenedTasks"]).forEach((element) {
        result.add(Task.fromJson(element));
      });
    }, onError: (e) {
      print("Error: " + e.toString());
    });
    //print("result open   " + result.toString());
    return result;
  }

  // #TODO: пробросить дату
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
    // это должен быть push или graphql subscription или что-то вроде
    Future<QueryResult> queryResultFuture =
    _graphQLService.query(myClosedTasksQuery);
    List<Task> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.data == null) {
        print("value.data == null ");
        return result;
      }
      if (value.isLoading) {
        print("value.isLoading ");
        return result;
      }
      List.from( value.data!["myClosedTasks"]).forEach((element) {
        result.add(Task.fromJson(element));
      });
    }, onError: (e) {
      print("Error: " + e.toString());
    });
    //print("result open   " + result.toString());
    return result;
  }
}
