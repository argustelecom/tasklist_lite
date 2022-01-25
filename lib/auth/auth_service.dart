import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/tasklist/fixture/auth_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/user_info.dart';

class AuthService extends GetxService {
  UserInfo login({bool inDemonstrationMode = false}) {
    if (!inDemonstrationMode) {
      // #TODO: аутентификация путем выполнения graphql query whoami
      throw FlutterError("not implemented!!!");
    } else {
      // в деморежиме аутентификация состоит в подсовывании данных из фикстуры в контроллер
      return AuthFixture.authFixture;
    }
  }
}
