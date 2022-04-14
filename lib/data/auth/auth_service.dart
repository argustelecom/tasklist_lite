import 'package:get/get.dart';
import 'package:tasklist_lite/core/state/current_app_info.dart';
import 'package:tasklist_lite/data/fixture/auth_fixtures.dart';
import 'package:tasklist_lite/domain/entities/user_info.dart';

import 'auth_remote_client.dart';

class AuthService extends GetxService {
  Future<UserInfo> login() async {
    CurrentAppInfo currentAppInfo = Get.find();
    if (!currentAppInfo.isAppInDemonstrationMode()) {
      AuthRemoteClient authRemoteClient = AuthRemoteClient();
      return await authRemoteClient.getUserInfo();
    } else {
      // в деморежиме аутентификация состоит в подсовывании данных из фикстуры в контроллер
      return AuthFixture.authFixture;
    }
  }
}
