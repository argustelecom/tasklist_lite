import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/core/exceptions.dart';
import 'package:tasklist_lite/core/graphql/graphql_service.dart';
import 'package:tasklist_lite/domain/entities/comment.dart';
import 'package:tasklist_lite/domain/entities/idle_time.dart';
import 'package:tasklist_lite/domain/entities/work.dart';

import '../../domain/entities/close_code.dart';
import '../../domain/entities/mark.dart';
import '../../domain/entities/task.dart';

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
        checkError(value.exception!);
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["$queryName"]).forEach((element) {
        result.add(Task.fromJson(element));
      });
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
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
        checkError(value.exception!);
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["idleTimeReason"]).forEach((element) {
        result.add(IdleTimeReason.fromJson(element));
      });
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return result;
  }

  Future<Task> registerIdle(int taskInstanceId, int reasonId,
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
       $taskGraphqlQuery
    }
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(registerIdleQuery);
    late Task result;
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        checkError(value.exception!);
      }
      if (value.data == null || value.data!["registerIdleTime"] == null) {
        throw ExternalException(
            "Получен некорректный ответ сервера, результат выполнения операции не найден");
      }
      result = Task.fromJson(value.data!["registerIdleTime"]);
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return result;
  }

  Future<Task> finishIdle(
      int taskInstanceId, DateTime beginTime, DateTime endTime) async {
    String beginTimeStr = DateFormat('dd.MM.yyyy HH:mm:ss').format(beginTime);
    String endTimeStr = DateFormat('dd.MM.yyyy HH:mm:ss').format(endTime);

    String finishIdleQuery = '''
 mutation {  
   finishIdleTime(
    taskInstanceId:"$taskInstanceId",
    beginTime:"$beginTimeStr",
    endTime:"$endTimeStr"){
       $taskGraphqlQuery
    }
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(finishIdleQuery);
    late Task result;
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        checkError(value.exception!);
      }
      if (value.data == null || value.data!["finishIdleTime"] == null) {
        throw ExternalException(
            "Получен некорректный ответ сервера, результат выполнения операции не найден");
      }
      result = Task.fromJson(value.data!["finishIdleTime"]);
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
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
        checkError(value.exception!);
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["getCommentByTask"]).forEach((element) {
        result.add(Comment.fromJson(element));
      });
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
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
        checkError(value.exception!);
      }
      if (value.data == null || value.data!["addComment"] == null) {
        return null;
      }
      //пока мутации всегда возвращает null. но возможность получать пока оставим
      result = Comment.fromJson(value.data!["addComment"]);
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return result;
  }

  Future<Task> endStage(int taskInstanceId) async {
    String endStageQuery = '''
 mutation {  
   endStage(
    taskInstanceId:"$taskInstanceId"){
       $taskGraphqlQuery
    }
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(endStageQuery);
    late Task result;
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        checkError(value.exception!);
      }
      if (value.data == null || value.data!["endStage"] == null) {
        throw ExternalException(
            "Получен некорректный ответ сервера, результат выполнения операции не найден");
      }
      result = Task.fromJson(value.data!["endStage"]);
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return result;
  }

  Future<Task> closeOrder(int taskInstanceId, int closeCodeId) async {
    String closeOrderQuery = '''
 mutation {  
   closeOrder(
    taskInstanceId:"$taskInstanceId",
    closeCodeId:"$closeCodeId"){
       $taskGraphqlQuery
    }
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(closeOrderQuery);
    late Task result;
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        checkError(value.exception!);
      }
      if (value.data == null || value.data!["closeOrder"] == null) {
        throw ExternalException(
            "Получен некорректный ответ сервера, результат выполнения операции не найден");
      }
      result = Task.fromJson(value.data!["closeOrder"]);
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return result;
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
        checkError(value.exception!);
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["closeCode"]).forEach((element) {
        result.add(CloseCode.fromJson(element));
      });
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
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
        checkError(value.exception!);
      }
      if (value.data == null) {
        return result;
      }
      List.from(value.data!["getMarks"]).forEach((element) {
        result.add(Mark.fromJson(element));
      });
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
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
        checkError(value.exception!);
      }
      if (value.data == null) {
        throw ExternalException(
            "Получен некорректный ответ сервера, результат выполнения операции не найден");
      }
      result = Work.fromJson(value.data!["registerWorkDetail"]);
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return result;
  }

  Future<Work> deleteWorkDetail(int taskInstanceId, int workDetailId) async {
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
    late Work result;
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        checkError(value.exception!);
      }
      if (value.data == null) {
        throw ExternalException(
            "Получен некорректный ответ сервера, результат выполнения операции не найден");
      }
      result = Work.fromJson(value.data!["deleteWorkDetail"]);
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return result;
  }

  Future<bool?> readNotify(int notifyId) async {
    String readNotifyQuery = '''
 mutation {  
   readNotify(
    notifyId:"$notifyId")
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(readNotifyQuery);
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        checkError(value.exception!);
      }
      if (value.data == null || value.data!["readNotify"] == null) {
        return null;
      }
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return true;
  }

  Future<bool> markWorksNotRequired(
      int taskInstanceId, List<int> workTypes) async {
    String? workTypesString = workTypes.toString();
    String deleteWorkDetailQuery = '''
 mutation {  
   markWorksNotRequired(
    taskInstanceId: "$taskInstanceId", 
    workTypes: $workTypesString)
    {
    $workQuery
    }
 }''';

    Future<QueryResult> mutationResultFuture =
        _graphQLService.mutate(deleteWorkDetailQuery);
    await mutationResultFuture.then((value) {
      if (value.hasException) {
        checkError(value.exception!);
      }
      if (value.data == null) {
        throw ExternalException(
            "Получен некорректный ответ сервера, результат выполнения операции не найден");
      }
    }, onError: (e) {
      throw ExternalException("Ошибка обработки ответа: " + e.toString());
    });
    return true;
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
