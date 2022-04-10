import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:tasklist_lite/core/graphql/graphql_service.dart';
import 'package:tasklist_lite/domain/entities/user_info.dart';

/// Получает информацию о сотруднике по переданному basicAuth.
/// Использует graphQL для получения информации

class AuthRemoteClient {
  static const String envApiAddress = "/argus/graphql/env";

  late GraphQLService _graphQLService;

  AuthRemoteClient(String basicAuth, String serverAddress) {
    String urlForEnv = serverAddress + envApiAddress;
    String webSocketUrlForEnv = serverAddress + envApiAddress;
    this._graphQLService = GraphQLService(
        basicAuth: basicAuth, url: urlForEnv, webSocketUrl: webSocketUrlForEnv);
  }

  Future<UserInfo> getUserInfo() async {
    String whoAmI = '''
 {   whoami{
    userName
    homeRegionName
    securityRoles
    securityRoleNames
    workerName
    family
    surname
    tabNumber
    mainWorksite
    email
    workerAppoint
    chiefContact {
      name
      phoneNum
      email
    }
  }
 }
''';
    // Используем late так как инициализация происходит await whenComplete
    // TODO Единообразный вызов вместе с Task_remote_client
    late UserInfo result;
    Future<QueryResult> queryResultFuture = _graphQLService.query(whoAmI);
    await queryResultFuture.whenComplete(() => null).then((value) {
      if (value.hasException) {
        checkError(value.exception!);
      }
      if (value.data == null) {
        throw Exception("Ошибка получения данных о профиле пользователя");
      }
      if (!value.isLoading) {
        result = UserInfo.fromJson(value.data!["whoami"]);
        return result;
      }
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
