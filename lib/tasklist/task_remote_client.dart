import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/graphql/graphql_service.dart';
import 'package:tasklist_lite/tasklist/model/comment.dart';
import 'package:tasklist_lite/tasklist/model/idle_time.dart';
import 'package:tasklist_lite/tasklist/model/work.dart';

import 'model/close_code.dart';
import 'model/mark.dart';
import 'model/task.dart';

/// Получает информацию о  задачах сотрудника по переданному basicAuth.
/// Использует graphQL для получения информации

class TaskRemoteClient {
  static const String thirdPartyApiAddress =
      "/argus/graphql/support-service-thirdparty";

  /// Причина простоя IdleTimeReason
  static const String idleTimeReasonQuery = '''
    id
    name
    ''';

  /// Получение простоя IdleTime
  static const String idleTimeQuery = '''    
    id
    reason{
       $idleTimeReasonQuery
    }
    beginTime
    endTime ''';

  /// Причина простоя IdleTimeReason
  static const String closeCodeQuery = '''
    id
    objectName
    ''';

  /// Получение назначенных сотрудников
  static const String workerQuery = '''    
      id
      family
      name
      surname
      tabNumber
      mainWorksite ''';

  // Comment
  static const String commentQuery = '''
    person
    title
    text
    date
    type
    important
   ''';
  //Work
  static const String workQuery = '''
  status
  workType {
        id
        name
        units
        marks
      }
      workDetail {
        id
        amount
        date
        workerMarks {
          worker {
            $workerQuery
          }
          mark
        }
      } ''';

  // Mark
  static const String markQuery = '''
    reason
    createDate
    worker
    value
    type
   ''';

  /// Получение "легкого" Task, без истории
  static const String taskGraphqlQuery = '''id
  biId
  name
  desc
  processTypeName
  taskType
  dueDate
  address
  addressComment
  createDate
  closeDate
  isVisit
  isPlanned
  isOutdoor
  isClosed
  latitude
  longitude
  commentary
  ttmsId
  flexibleAttribute {
     key
     value
  }
  idleTimePeriod {
    $idleTimeQuery
  }
  assignee {
    $workerQuery
  }
  works{
  $workQuery
  }
  stage {
      name
      number
      isLast
      dueDate
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

  Future<List<Task>> getClosedTasks(DateTime day) async {
    String date = DateFormat('dd.MM.yyyy').format(day);
    String myClosedTasksQuery = '''
 {  
   myClosedTasks(day: "$date") {
    $taskGraphqlQuery
   }
 }''';

    return getTasks(myClosedTasksQuery, "myClosedTasks");
  }

  Future<List<Task>> getTasks(String queryString, String queryName) async {
    Future<QueryResult> queryResultFuture = _graphQLService.query(queryString);
    List<Task> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер недоступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Не авторизован");
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

  Future<List<IdleTimeReason>> getIdleTimeReason() async {
    String getIdleTimeReasonQuery = '''
 {  idleTimeReason {
   $idleTimeReasonQuery
 }
 }
''';
    Future<QueryResult> queryResultFuture =
        _graphQLService.query(getIdleTimeReasonQuery);
    List<IdleTimeReason> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер недоступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Не авторизован");
        }
        throw Exception("Неожиданная ошибка");
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["idleTimeReason"]).forEach((element) {
        result.add(IdleTimeReason.fromJson(element));
      });
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }

  Future<IdleTime?> registerIdle(int taskInstanceId, int reasonId,
      DateTime beginTime, DateTime? endTime) async {
    String beginTimeStr = DateFormat('dd.MM.yyyy HH:mm:ss').format(beginTime);
    String endTimeStr = '';
    if (endTime != null) {
      endTimeStr = DateFormat('dd.MM.yyyy HH:mm:ss').format(endTime);
    }
    String registerIdleQuery = '''
 mutation {  
   registerIdleTime(
    taskInstanceId:"$taskInstanceId",
    reasonId:"$reasonId",
    beginTime:"$beginTimeStr",
    endTime:"$endTimeStr"){
       $idleTimeQuery
    }
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(registerIdleQuery);
    late IdleTime result;
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер недоступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Не авторизован");
        }
        throw Exception("Неожиданная ошибка");
      }
      if (value.data == null || value.data!["registerIdleTime"] == null) {
        return null;
      }
      result = IdleTime.fromJson(value.data!["registerIdleTime"]);
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }

  Future<IdleTime?> finishIdle(
      int taskInstanceId, DateTime beginTime, DateTime endTime) async {
    String beginTimeStr = DateFormat('dd.MM.yyyy HH:mm:ss').format(beginTime);
    String endTimeStr = DateFormat('dd.MM.yyyy HH:mm:ss').format(endTime);

    String finishIdleQuery = '''
 mutation {  
   finishIdleTime(
    taskInstanceId:"$taskInstanceId",
    beginTime:"$beginTimeStr",
    endTime:"$endTimeStr"){
       $idleTimeQuery
    }
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(finishIdleQuery);
    late IdleTime result;
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер недоступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Не авторизован");
        }
        throw Exception("Неожиданная ошибка");
      }
      if (value.data == null || value.data!["finishIdleTime"] == null) {
        return null;
      }
      result = IdleTime.fromJson(value.data!["finishIdleTime"]);
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }

  Future<List<Comment>> getCommentByTask(int taskId) async {
    String getCommentByTaskQuery = '''
 {  getCommentByTask (taskId:"$taskId") {
   $commentQuery
 }
 }
''';
    Future<QueryResult> queryResultFuture =
        _graphQLService.query(getCommentByTaskQuery);
    List<Comment> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер недоступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Не авторизован");
        }
        throw Exception("Неожиданная ошибка");
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["getCommentByTask"]).forEach((element) {
        result.add(Comment.fromJson(element));
      });
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }

  Future<Comment?> addComment(
      int taskInstanceId, String text, bool important) async {
    String addCommentQuery = '''
 mutation {  
   addComment(
    taskInstanceId:"$taskInstanceId",
    text:"$text",
    important: $important ){
       $commentQuery
    }
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(addCommentQuery);
    Comment? result = null;
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер недоступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Не авторизован");
        }
        throw Exception("Неожиданная ошибка");
      }
      if (value.data == null || value.data!["addComment"] == null) {
        return null;
      }
      //пока мутации всегда возвращает null. но возможность получать пока оставим
      result = Comment.fromJson(value.data!["addComment"]);
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }

  Future<bool?> endStage(int taskInstanceId) async {
    String endStageQuery = '''
 mutation {  
   endStage(
    taskInstanceId:"$taskInstanceId")
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(endStageQuery);
    late String result;
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер недоступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Не авторизован");
        }
        throw Exception("Неожиданная ошибка");
      }
      if (value.data == null) {
        return null;
      }
      result = value.data!["endStage"];
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    if (result == "true") {
      return true;
    }
    return false;
  }

  Future<bool?> closeOrder(int taskInstanceId, int closeCodeId) async {
    String closeOrderQuery = '''
 mutation {  
   closeOrder(
    taskInstanceId:"$taskInstanceId", closeCodeId:"$closeCodeId")
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(closeOrderQuery);
    late String result;
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер недоступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Не авторизован");
        }
        throw Exception("Неожиданная ошибка");
      }
      if (value.data == null) {
        return null;
      }
      result = value.data!["closeOrder"];
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    if (result == "true") {
      return true;
    }
    return false;
  }

  Future<List<CloseCode>> getCloseCodes() async {
    String getCloseCodes = '''
 {  closeCode {
   $closeCodeQuery
 }
 }
''';
    Future<QueryResult> queryResultFuture =
        _graphQLService.query(getCloseCodes);
    List<CloseCode> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер недоступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Не авторизован");
        }
        throw Exception("Неожиданная ошибка");
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["closeCode"]).forEach((element) {
        result.add(CloseCode.fromJson(element));
      });
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }

  Future<List<Mark>> getMarks(int taskId) async {
    String getMarksQuery = '''
 {  getMarks (taskId:"$taskId") {
   $markQuery
 }
 }
''';
    Future<QueryResult> queryResultFuture =
        _graphQLService.query(getMarksQuery);
    List<Mark> result = List.of({});
    await queryResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер недоступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Не авторизован");
        }
        throw Exception("Неожиданная ошибка");
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["getMarks"]).forEach((element) {
        result.add(Mark.fromJson(element));
      });
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }

  Future<Work> registerWorkDetail(int taskInstanceId, int workTypeId,
      bool notRequired, double? amount, List<int>? workers) async {
    String? workersString = workers != null ? workers.toString() : null;
    String registerWorkDetailQuery = '''
 mutation {  
   registerWorkDetail(
    taskInstanceId:"$taskInstanceId", 
    workTypeId: $workTypeId,
    notRequired: $notRequired,
    amount: $amount,
    workers:  $workersString) {
    $workQuery
    }
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(registerWorkDetailQuery);
    late Work result;
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер недоступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Не авторизован");
        }
        throw Exception("Неожиданная ошибка");
      }
      if (value.data == null) {
        throw Exception("Work is null");
      }
      result = Work.fromJson(value.data!["registerWorkDetail"]);
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }

  Future<Work?> deleteWorkDetail(int taskInstanceId, int workDetailId) async {
    String deleteWorkDetailQuery = '''
 mutation {  
   deleteWorkDetail(
    taskInstanceId: "$taskInstanceId", 
    workDetailId: $workDetailId)
    {
    $workQuery
    }
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(deleteWorkDetailQuery);
    late Work? result;
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        // need catch 401 error
        if (value.exception?.linkException is ServerException) {
          throw Exception("Сервер недоступен");
        }
        if (value.exception?.linkException is HttpLinkParserException) {
          throw Exception("Не авторизован");
        }
        throw Exception("Неожиданная ошибка");
      }
      if (value.data == null) {
        return null;
      }
      result = Work.fromJson(value.data!["deleteWorkDetail"]);
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }
}
