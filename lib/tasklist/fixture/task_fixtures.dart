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

  List<Task> firstTaskFixtureAdditionalTasks =
      List.of({new Task(id: 10, name: "Ленинский 117 Минск диодный мост")});

  List<Task> secondTaskFixture = List.of({
    new Task(id: 2, name: "Papa Johns Ветеранов заказ 111"),
    new Task(id: 3, name: "Papa Johns 111 доставка Зины Портновой 15")
  });

  List<Task> secondTTaskFixtureAdditionalTasks = List.of({
    new Task(id: 11, name: "Pizza Hut Ветеранов заказ 15"),
    new Task(id: 12, name: "Pizza Hut доствка Ленинский 144")
  });

  List<Task> thirdTaskFixture = List.of({
    new Task(id: 4, name: "АВР-177195 Хувайдулоева 2"),
    new Task(id: 5, name: "АВР-181100 Набиева 167"),
    new Task(id: 6, name: "АВР-180438 Ленина 107"),
    new Task(id: 7, name: "АВР-233343 Московский пр. 2"),
    new Task(id: 8, name: "АВР-213211 Ветеранов 167"),
    new Task(id: 9, name: "АВР-322432 Ленина 55")
  });

  List<Task> thirdTaskFixtureAdditionalTasks = List.of({
    new Task(id: 13, name: "АВР-233112 Московский 146"),
    new Task(id: 14, name: "АВР-233254 Ленина 116"),
  });

  List<Task> getTasks(CurrentTaskFixture currentTaskFixture) {
    if (currentTaskFixture == CurrentTaskFixture.firstFixture) {
      // чтобы возвращалась не сама фикстура, а ее копия (иначе можем случайно потом изменить)
      return List.of(firstTaskFixture);
    } else if (currentTaskFixture == CurrentTaskFixture.secondFixture) {
      return List.of(secondTaskFixture);
    } else if (currentTaskFixture == CurrentTaskFixture.thirdFixture) {
      return List.of(thirdTaskFixture);
    } else
      return new List.of({});
  }

  ///***************************************************************************
  /// периодически подает список с разным набором задач, чтобы была возможность
  /// протестировать клиентскую часть без подписок graphql
  Stream<List<Task>> streamTasks(CurrentTaskFixture currentTaskFixture) async* {
    while (true) {
      List<Task> tasks = getTasks(currentTaskFixture);
      // по четным минутам в возвращаемое значение подмешиваем additional задачи
      if (DateTime.now().minute.isEven) {
        if (currentTaskFixture == CurrentTaskFixture.firstFixture) {
          tasks.addAll(firstTaskFixtureAdditionalTasks);
        } else if (currentTaskFixture == CurrentTaskFixture.secondFixture) {
          tasks.addAll(secondTTaskFixtureAdditionalTasks);
        } else {
          tasks.addAll(thirdTaskFixtureAdditionalTasks);
        }
      }
      yield tasks;

      await Future.delayed(Duration(seconds: 10));
    }
  }
}
