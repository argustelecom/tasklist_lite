import 'package:tasklist_lite/domain/entities/user_info.dart';

class AuthFixture {
  static final UserInfo authFixture = UserInfo(
      userName: "VLG_BOGDANOVA",
      homeRegionName: "Вологодская обл.",
      // #TODO: подглядеть на сервере реальные значения
      securityRoles: List.of({'winterdrift', 'burnout'}),
      securityRoleNames: List.of({'ходить бочком', 'помогать всем'}),
      family: "Богданова",
      workerName: "Каролина",
      surname: "Георгиевна",
      email: "k.g.bogdanova@rt.ru",
      mainWorksite: "Участок О2О Курган",
      tabNumber: "12345987-22",
      workerAppoint: "Инженер электросвязи",
      contactChiefList: new List.of(({contact1, contact2})));

  static final Contact contact1 = Contact(
      name: 'Бедрин Алексей Сергеевич',
      phoneNum: '+79211112475, +79003002010 200001232 +7-123-23123123',
      email: 'a.bedrin@mail.net');

  static final Contact contact2 = Contact(
      name: 'Сом Георгий Сергеевич',
      phoneNum: '+7921223322',
      email: 'georg.som@mail.net');
}
