import 'package:async/async.dart' show StreamGroup;
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/core/exceptions.dart';
import 'package:tasklist_lite/core/graphql/graphql_service.dart';
import 'package:tasklist_lite/core/state/current_auth_info.dart';
import 'package:tasklist_lite/domain/entities/comment.dart';
import 'package:tasklist_lite/domain/entities/idle_time.dart';
import 'package:tasklist_lite/domain/entities/work.dart';

import '../../domain/entities/close_code.dart';
import '../../domain/entities/mark.dart';
import '../../domain/entities/task.dart';
import '../../presentation/state/application_state.dart';

/// Получает информацию о  задачах сотрудника по переданному basicAuth.
/// Использует graphQL для получения информации

class TaskRemoteClient {
  static const String thirdPartyApiAddress =
      "/graphql/support-service-thirdparty";
  static const String thirdPartyWebsocketApiAddress =
      "/graphql/support-service-thirdparty/ws";

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
  scheduledDate
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
  ApplicationState applicationState = Get.find();

  static const String _httpProtoPrefix = "http://";
  static const String _httpsProtoPrefix = "https://";
  static const String _wsProtoPrefix = "ws://";
  static const String _wssProtoPrefix = "wss://";

  // kostd, 29.07.2022: тут с вебсокетами имеется странный момент, связанный с аутентифиацией.
  // Первый реквест (handshake) для вебсокетов -- вполне себе обычный http с особыми заголовками.
  // Логичным было бы для Basic-аутентификации просто добавить обычный header Authorization: Basic...
  // (он у нас есть и хранится в currentAuthInfo.getCurrentAuthString()).
  // Казалось бы, это можно сделать через concat с AuthLink, как это делаем для httpLink в GraphQLService
  // Или через custom`ный link, как обсуждается в
  // https://stackoverflow.com/questions/67195275/how-can-i-add-customised-header-on-http-request-for-authentication-when-using-fl
  // Или даже пробросив SocketClientConfig с соответствующими headers в конструктор WebSocketLink (см. опять же GraphQLService).
  // Но тут неожиданное -- похоже, graphql-фреймворк осознанно закрывает программисту возможность управлять заголовками
  // для websocket handshake. Например, если пробрасывать заголовки через SocketCLientConfig, то в браузере это не будет
  // работать (см. соообщение "The headers on the web are not supported", которое пишется в  в  platform_html.dart/defaultConnectPlatform())
  // (На эту тему см.  WebSocketLink doesn't add headers from AuthLink #411
  // https://github.com/zino-hofmann/graphql-flutter/issues/411?ysclid=l4zntly92s856417132?ysclid=l4zntly92s856417132
  // см. также It’s not possible to provide custom headers when creating WebSocket connection in browser.
  // https://github.com/apollographql/graphql-subscriptions/blob/master/.designs/authorization.md )
  // Передаваемые  двумя другими способами header`ы также подавляются фреймворком. В итоге, единственный рабочий способ --
  // это подсунуть credentials websocket-фреймворку прямо в uri, как предлагается в
  // https://websockets.readthedocs.io/en/stable/topics/authentication.html#machine-to-machine-authentication
  // При этом, как и написано, будет именно Basic. То есть, фреймворк разберет uri, добавит нужный нам header
  // (КД лично проверил это в developer tools), а в рексвест пойдет uri уже без credentials. Почему так странно -- фиг его
  // поймет. Можно лишь отметить, что разработчики graphql_flutter кивают по этому вопросу в сторону нижележащего фреймворка
  // apollo
  // #TODO[НК]: Сейчас КД задал _wsAuthString константой. То есть для подключения по вебсокету будут игнорироваться credentials,
  //  введенные пользователем, и вместо этого будут использоваться забитые хардкодом. Это надо переделать. Получается, нужно maintain`ить
  // строчку вида "login@password" так же, как сейчас maintain`им значение в currentAuthInfo.getCurrentAuthString() (заполнять в том же
  // месте логина, так же хранить и доставать).

  static const String _wsAuthString = "developer:developer@";

  TaskRemoteClient() {
    CurrentAuthInfo currentAuthInfo = Get.find();
    String urlForThirdParty =
        currentAuthInfo.getCurrentServerAddress() + thirdPartyApiAddress;
    // для вебсокетов подменим протокол в url, если он был явно указан.
    // #TODO[НК]: а если протокол не был явно указан?
    String webSocketUrlPrefix = currentAuthInfo
            .getCurrentServerAddress()
            .toLowerCase()
            .startsWith(_httpProtoPrefix)
        ? _wsProtoPrefix +
            _wsAuthString +
            currentAuthInfo
                .getCurrentServerAddress()
                .substring(_httpProtoPrefix.length)
        : currentAuthInfo
                .getCurrentServerAddress()
                .toLowerCase()
                .startsWith(_httpsProtoPrefix)
            ? _wssProtoPrefix +
                _wsAuthString +
                currentAuthInfo
                    .getCurrentServerAddress()
                    .substring(_httpsProtoPrefix.length)
            : _wsAuthString + currentAuthInfo.getCurrentServerAddress();
    String webSocketUrlForThirdParty =
        // в итоге после всех преобразований должно получиться что-то вроде
        // "ws://developer:developer@192.168.100.47:8080/argus/graphql/support-service-thirdparty/ws";
        webSocketUrlPrefix + thirdPartyWebsocketApiAddress;

    this._graphQLService = GraphQLService(
        basicAuth: currentAuthInfo.getCurrentAuthString(),
        url: urlForThirdParty,
        webSocketUrl: webSocketUrlForThirdParty);
  }

  Stream<List<Task>> streamOpenedTasks() async* {
    // #TODO[НК]: здесь должна быть проверка условия по настройке subscriptionsEnabled
    if (1 == 1) {
      // режим подписок включен, подписываемся
      yield* subscribeOnOpenedTasks();
    } else {
      // режим query, то есть периодически вызываем query и возвращаем результат,
      // используя тот же "потоковый" подход, что и при подписках.
      yield* StreamGroup.merge(List.of({
        Stream.fromFuture(getOpenedTasks()),
        Stream.periodic(
          applicationState.refreshInterval.value,
          (computationCount) {
            return getOpenedTasks();
          },
        ).asyncMap((event) async => await event)
      }));
    }
  }

  Stream<List<Task>> subscribeOnOpenedTasks() {
    String queryString = '''
    subscription {
      myOpenedTasksSubscription {
      $taskGraphqlQuery
    }
    }''';
    return _graphQLService.subscribe(queryString).map((event) {
      if (event.hasException) {
        checkError(event.exception!);
      }
      List<Task> result = List.of({});
      if (event.data == null) {
        return result;
      }
      List.from(event.data!["myOpenedTasksSubscription"]).forEach((element) {
        result.add(Task.fromJson(element));
      });

      return result;
    });
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

  Stream<List<Task>> streamClosedTasks(DateTime day) async* {
    // #TODO[НК]: здесь должна быть проверка условия по настройке subscriptionsEnabled
    if (1 == 1) {
      // режим подписок включен, подписываемся
      yield* subscribeOnClosedTasks(day);
    } else {
      // режим query, то есть периодически вызываем query и возвращаем результат,
      // используя тот же "потоковый" подход, что и при подписках.

      yield* StreamGroup.merge(List.of({
        Stream.fromFuture(getClosedTasks(day)),
        Stream.periodic(
          applicationState.refreshInterval.value,
          (computationCount) {
            return getClosedTasks(day);
          },
        ).asyncMap((event) async => await event)
      }));
    }
  }

  Stream<List<Task>> subscribeOnClosedTasks(DateTime day) {
    String date = DateFormat('dd.MM.yyyy').format(day);
    String queryString = '''
 subscription {  
   myClosedTasksSubscription(day: "$date") {
    $taskGraphqlQuery
   }
 }''';
    // #TODO[НК]: устранить дублирование кода (@see subscribeOnOpenedTasks)
    return _graphQLService.subscribe(queryString).map((event) {
      if (event.hasException) {
        checkError(event.exception!);
      }
      List<Task> result = List.of({});
      if (event.data == null) {
        return result;
      }
      List.from(event.data!["myClosedTasksSubscription"]).forEach((element) {
        result.add(Task.fromJson(element));
      });

      return result;
    });
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

//  возвращает Stream, состоящий из результатов переодического вызова
//   graphql query на сервере.
  Stream<List<Comment>> streamComments(Task task) async* {
    // здесь yeld* обозначает "рекурсивный" возврат значения,
    // то есть как будто бы мы говорим, что за нас будет возвращать
    // значение функция, которую мы укажем. В этом случае ожидается,
    // что функция будет возвращать Stream.
    // Нас бы полностью устроил Stream.periodic, но вот беда -- сразу
    // после подписки он сначала выполняет ожидание, и только потом,
    // спустя период, возвращает значение. А нам надо вернуть значение
    // сразу после подписки, а потом уже регулярно через период. Поэтому
    // мержим здесь два потока, один из котороых -- просто future с результатом
    // вызова операции.
    yield* StreamGroup.merge(List.of({
      Stream.fromFuture(getCommentByTask(task.id)),
      Stream.periodic(
        applicationState.refreshInterval.value,
        (computationCount) {
          return getCommentByTask(task.id);
        },
        // #TODO: нет, не понимаю, как это рааботает. Но НК обязательно разберется.
        // https://stackoverflow.com/questions/57559823/how-to-call-async-functions-in-stream-periodic
      ).asyncMap((event) async => await event)
    }));
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

//  возвращает Stream c баллами, состоящий из результатов переодического вызова
//   graphql query на сервере.
  Stream<List<Mark>> streamMarks(Task task) async* {
    yield* StreamGroup.merge(List.of({
      Stream.fromFuture(getMarks(task.id)),
      Stream.periodic(
        applicationState.refreshInterval.value,
        (computationCount) {
          return getMarks(task.id);
        },
      ).asyncMap((event) async => await event)
    }));
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
