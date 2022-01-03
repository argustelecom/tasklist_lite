import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:tasklist_lite/graphql/graphql_service.dart';

import 'model/task.dart';

/// #TODO: должен доставать задачки по Rest с помощью запросов graphQL, например, как это делается во flutter_movie
class TaskRemoteClient {
  static final String urlForTests = "https://www.fluttermovie.top/api/graphql";

  // #TODO: drop`em
  String _queryForTests = '''{
    __schema {
      types {
        name
      }
    }
  }''';

  final GraphQLService _graphQLService =
      // #TODO: нужны осмысленные значения url
      // #TODO: нужно пробрасывать параметры аутентификации
      GraphQLService(url: urlForTests, webSocketUrl: "");

  List<Task> getOpenedTasks() {
    const String myOpenedTasksQuery = '''{
   myOpenedTasks{
    id
    name
    desc
    processTypeName
    dueDate
    priority
    assignee
    objectName
    address
    createDate
    isVisit
    isPlanned
    isOutdoor
  }
}''';
    // #TODO: если это делать в момент запуска приложения, получается долго (сервер отвечает более 1с)
    // это должен быть push или graphql subscription или что-то вроде
    Future<QueryResult> queryResultFuture =
        _graphQLService.query(myOpenedTasksQuery);
    List<Task> result = List.of({});
    queryResultFuture.then((value) {
      result = value.data as List<Task>;
      print("************ " + value.data.toString());
    }, onError: (e) {
      print("!!!!!!!!!!!!!!!!!!111    " + e.toString());
    });
    return result;
  }

  // #TODO: пробросить дату
  List<Task> geClosedTasks() {
    const String myClosedTasksQuery = '''{
    myClosedTasks(day: "30.12.2021"){
    id
    name
    desc
    processTypeName
    dueDate
    priority
    assignee
    objectName
    address
    createDate
    isVisit
    isPlanned
    isOutdoor
  }
  }''';
    Future<QueryResult> queryResultFuture =
        _graphQLService.query(myClosedTasksQuery);
    List<Task> result = List.of({});
    queryResultFuture.then((value) {
      result = value.data as List<Task>;
      print("************ " + value.data.toString());
    }, onError: (e) {
      print("!!!!!!!!!!!!!!!!!!111    " + e.toString());
    });
    return result;
  }
}
