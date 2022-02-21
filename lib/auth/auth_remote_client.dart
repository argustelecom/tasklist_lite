
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:tasklist_lite/graphql/graphql_service.dart';
import 'package:tasklist_lite/tasklist/model/user_info.dart';

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
          throw Exception("Ошибка получения данных о профиле пользователя");
        }
        if (!value.isLoading) {
          result = UserInfo.fromJson(value.data!["whoami"]);
          return result;
        }
      });

    return result;
  }
}
