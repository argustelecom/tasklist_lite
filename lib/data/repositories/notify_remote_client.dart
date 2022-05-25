import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:tasklist_lite/core/graphql/graphql_service.dart';
import 'package:tasklist_lite/core/state/current_auth_info.dart';
import 'package:tasklist_lite/data/repositories/task_remote_client.dart';
import 'package:tasklist_lite/domain/entities/notify.dart';
import 'package:async/async.dart' show StreamGroup;
import 'package:tasklist_lite/presentation/state/application_state.dart';

/// Получает информацию о  задачах сотрудника по переданному basicAuth.
/// Использует graphQL для получения информации

class NotifyRemoteClient {
  static const String thirdPartyApiAddress =
      "/argus/graphql/support-service-thirdparty";

  late GraphQLService _graphQLService;
  ApplicationState applicationState = Get.find();

  NotifyRemoteClient() {
    CurrentAuthInfo currentAuthInfo = Get.find();
    String urlForThirdParty =
        currentAuthInfo.getCurrentServerAddress() + thirdPartyApiAddress;
    String webSocketUrlForThirdParty =
        currentAuthInfo.getCurrentServerAddress() + thirdPartyApiAddress;
    this._graphQLService = GraphQLService(
        basicAuth: currentAuthInfo.getCurrentAuthString(),
        url: urlForThirdParty,
        webSocketUrl: webSocketUrlForThirdParty);
  }

  Stream<List<Notify>> streamNotify() async* {
    yield* StreamGroup.merge(List.of({
      Stream.fromFuture(getNotify()),
      Stream.periodic(
        applicationState.refreshInterval.value,
        (computationCount) {
          return getNotify();
        },
      ).asyncMap((event) async => await event)
    }));
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
    Future<QueryResult> queryResultFuture = _graphQLService.query(myNotify);
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
