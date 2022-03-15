import 'package:get/get.dart';
import 'package:tasklist_lite/auth/auth_remote_client.dart';
import 'package:tasklist_lite/tasklist/fixture/auth_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/user_info.dart';

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
