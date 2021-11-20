import 'package:tasklist_lite/tasklist/model/task.dart';

/// идентификаторы возможных фикстур, используемых для отладки приложения, когда нет реальных удаленных данных
enum CurrentTaskFixture {
  /// первая, самая минималистичная фикстурка
  firstFixture,

  /// вторая пожирнее
  secondFixture,

  /// третья фикстурка для извращенцев
  thirdFixture,

  /// фикстура не выбрана, действует только полученный удаленно набор данных
  noneFixture
}

/// Служба, возвращающая набор задач по переданному идентификатору фикстуры
class TaskFixtures {
  // #TODO: в name должен быть скорее номер задачи, а указанное здесь должно быть в desc
  List<Task> firstTaskFixture = List.of(
      {new Task(id: 1, name: "Ленинский 107 Атлант замена компрессора")});

  List<Task> secondTaskFixture = List.of({
    new Task(id: 2, name: "Papa Johns Ветеранов заказ 111"),
    new Task(id: 3, name: "Papa Johns 111 доставка Зины Портновой 15")
  });

  List<Task> thirdTaskFixture = List.of({
    new Task(id: 4, name: "АВР-177195 Хувайдулоева 2"),
    new Task(id: 5, name: "АВР-181100 Набиева 167"),
    new Task(id: 6, name: "АВР-180438 Ленина 107")
  });

  List<Task> getTasks(CurrentTaskFixture currentTaskFixture) {
    if (currentTaskFixture == CurrentTaskFixture.firstFixture) {
      return firstTaskFixture;
    } else if (currentTaskFixture == CurrentTaskFixture.secondFixture) {
      return secondTaskFixture;
    } else if (currentTaskFixture == CurrentTaskFixture.thirdFixture) {
      return thirdTaskFixture;
    } else
      return new List.of({});
  }
}
