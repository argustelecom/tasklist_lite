import 'package:get/get.dart';
import 'package:tasklist_lite/data/fixture/auth_fixtures.dart';
import 'package:tasklist_lite/domain/entities/user_info.dart';

import 'auth_remote_client.dart';

class AuthService extends GetxService {
  Future<UserInfo> login(
      String basicAuth, String serverAddress, bool inDemonstrationMode) async {
    if (!inDemonstrationMode) {
      AuthRemoteClient authRemoteClient =
          AuthRemoteClient(basicAuth, serverAddress);
      return await authRemoteClient.getUserInfo();
    } else {
      // в деморежиме аутентификация состоит в подсовывании данных из фикстуры в контроллер
      return AuthFixture.authFixture;
    }
  }
}
