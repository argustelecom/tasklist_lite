import 'package:tasklist_lite/tasklist/model/user_info.dart';

class AuthFixture {
  static final UserInfo authFixture = UserInfo(
      userName: "VLG_BOGDANOVA",
      homeRegionName: "Вологодская обл.",
      // #TODO: подглядеть на сервере реальные значения
      securityRoles: List.of({'winterdrift', 'burnout'}),
      securityRoleNames: List.of({'ходить бочком', 'жечь резину'}));
}
