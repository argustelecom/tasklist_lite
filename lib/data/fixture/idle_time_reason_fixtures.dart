import 'package:tasklist_lite/domain/entities/idle_time.dart';

class IdleTimeReasonFixtures {
  static final idleTimeReason_1 =
      new IdleTimeReason(id: 1, name: "Нерабочее время");
  static final idleTimeReason_2 =
      new IdleTimeReason(id: 2, name: "Дорожная обстановка");
  static final idleTimeReason_3 =
      new IdleTimeReason(id: 3, name: "Клиент недоступен");
  static final idleTimeReason_4 =
      new IdleTimeReason(id: 4, name: "Доступ к объекту ограничен");
  static final idleTimeReason_5 =
      new IdleTimeReason(id: 5, name: "Временное электроснабжение");
  static final idleTimeReason_6 = new IdleTimeReason(id: 6, name: "Форс-мажор");

  List<IdleTimeReason> idleTimeReasonFixture = List.of({
    idleTimeReason_1,
    idleTimeReason_2,
    idleTimeReason_3,
    idleTimeReason_4,
    idleTimeReason_5,
    idleTimeReason_6
  });

  List<IdleTimeReason> getIdleTimeReasons() {
    return idleTimeReasonFixture;
  }
}
