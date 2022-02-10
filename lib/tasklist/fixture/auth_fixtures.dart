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
      flexibleAttribs: new LinkedHashMap.of({
          "Контакты руководителя/Ваш руководитель": "Бедрин Алексей Сергеевич",
          "Контакты руководителя/Контактный телефон руководителя": "+79219991222"
          }));
}
