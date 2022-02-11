import 'dart:collection';

import 'package:tasklist_lite/tasklist/model/user_info.dart';

class AuthFixture {
  static final UserInfo authFixture = UserInfo(
      userName: "VLG_BOGDANOVA",
      homeRegionName: "Вологодская обл.",
      // #TODO: подглядеть на сервере реальные значения
      securityRoles: List.of({'winterdrift', 'burnout'}),
      securityRoleNames: List.of({'ходить бочком', 'жечь резину'}),
      family: "Богданова",
      workerName: "Каролина",
      surname: "Георгиевна",
      email: "k.g.bogdanova@rt.ru",
      mainWorksite: "Участок О2О Курган",
      tabNumber: "12345987-22",
      workerAppoint: "Инженер электросвязи",
      contactChiefList: new List.of(({contact1, contact2})));

  static final Contact contact1 =
      Contact(name: 'Бедрин Алексей Сергеевич', phoneNum: '+79211112475');

  static final Contact contact2 =
      Contact(name: 'Сом Георгий Сергеевич', phoneNum: '+7921223322');
}
