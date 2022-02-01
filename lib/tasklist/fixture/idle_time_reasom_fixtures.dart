import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';

class IdleTimeReasonFixtures {
  List<String> firstIdleTimeReasonFixture = List.of({"Нерабочее время"});
  List<String> secondIdleTimeReasonFixture =
      List.of({"Дорожная обстановка", "Клиент недоступен"});
  List<String> thirdIdleTimeReasonFixture = List.of({
    "Нерабочее время",
    "Дорожная обстановка",
    "Клиент недоступен",
    "Доступ к объекту ограничен",
    "Временное электроснабжение",
    "Форс-мажор"
  });

  List<String> getIdleTimeReasons(CurrentTaskFixture currentTaskFixture) {
    if (currentTaskFixture == CurrentTaskFixture.firstFixture) {
      return firstIdleTimeReasonFixture;
    } else if (currentTaskFixture == CurrentTaskFixture.secondFixture) {
      return secondIdleTimeReasonFixture;
    } else if (currentTaskFixture == CurrentTaskFixture.thirdFixture) {
      return thirdIdleTimeReasonFixture;
    } else
      return new List.of({});
  }
}
