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
    String whoIAm = '''
 {   whoiam{
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
    chefContact {
      name
      phoneNum
    }
  }
 }
''';
    // Используем late так как инициализация происходит await whenComplete
    late UserInfo result;
    try {
      Future<QueryResult> queryResultFuture = _graphQLService.query(whoIAm);
      await queryResultFuture.whenComplete(() => null).then((value) {
        if (value.hasException) {
          // need catch 401 error
          throw Exception(value.exception);
        }
        if (value.data == null) {
          throw Exception("value.data == null");
        }
        if (!value.isLoading) {
          result = UserInfo.fromJson(value.data!["whoiam"]);
          return result;
        }
      }, onError: (e) {
        throw Exception(" onError " + e.toString());
      });
    } catch (e) {
      throw new Exception("AuthRemoteClient.getUserInfo:  " + e.toString());
    }
    return result;
  }
}
