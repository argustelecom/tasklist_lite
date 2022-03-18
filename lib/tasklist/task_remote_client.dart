import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/graphql/graphql_service.dart';
import 'package:tasklist_lite/tasklist/model/history_event.dart';
import 'package:tasklist_lite/tasklist/model/idle_time.dart';
import 'package:tasklist_lite/tasklist/model/stage.dart';

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

  // Comment
  static const String commentQuery = '''
    person
    title
    text
    date
    type
    important
   ''';

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
  assignee
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

  Future<IdleTime?> registerIdle(int taskInstanceId,
      int reasonId, DateTime beginTime, DateTime? endTime) async {
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

  Future<IdleTime?> finishIdle(int taskInstanceId,
      DateTime beginTime, DateTime endTime) async {
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

  Future<List<HistoryEvent>> getCommentByTask(int taskId) async {
    String getCommentByTaskQuery = '''
 {  getCommentByTask (taskId:"$taskId") {
   $commentQuery
 }
 }
''';
    Future<QueryResult> queryResultFuture =
        _graphQLService.query(getCommentByTaskQuery);
    List<HistoryEvent> result = List.of({});
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
        result.add(HistoryEvent.fromJson(element));
      });
    }, onError: (e) {
      throw Exception(" onError " + e.toString());
    });
    return result;
  }

  Future<HistoryEvent?> addComment(
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
    HistoryEvent? result = null;
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
      result = HistoryEvent.fromJson(value.data!["addComment"]);
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

  Future<bool?> completeOrder(int taskInstanceId, int closeCodeId) async {
    String completeOrderQuery = '''
 mutation {  
   completeOrder(
    taskInstanceId:"$taskInstanceId", closeCodeId:"$closeCodeId")
 }''';

    Future<QueryResult> mutationResultFuture =
    _graphQLService.mutate(completeOrderQuery);
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
      result = value.data!["completeOrder"];
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
}
