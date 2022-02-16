import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/notify.dart';

/// Служба, возвращающая набор нотификаций
class NotificationFixtures {
  static List<Notify> firstNotifyFixture = List.of({
    new Notify(
        id: 1,
        time: "17.00",
        text: "Назначена задача АВР-123564",
        date: DateTime.now(),
        task: TaskFixtures.firstTask,
        number: 'АВР-123564'),
    new Notify(
        id: 1,
        time: "16.00",
        text: "Назначена задача АВР-123564",
        date: DateTime.now(),
        task: TaskFixtures.secondTask,
        number: 'АВР-123564'),
    new Notify(
        id: 2,
        time: "15.00",
        text: "Назначена задача АВР-78945646",
        date: DateTime.now().subtract(Duration(days: 1)),
        task: TaskFixtures.thirdTask,
        number: 'АВР-78945646'),
    new Notify(
        id: 2,
        time: "14.00",
        text: "Назначена задача АВР-78945646",
        date: DateTime.now().subtract(Duration(days: 1)),
        task: TaskFixtures.fourthTask,
        number: 'АВР-78945646'),
    new Notify(
        id: 3,
        time: "12.00",
        text:
            "Осталось 30 минут до окончания этапа работ по наряду АВР-25836974(45-33)",
        date: DateTime.now().subtract(Duration(days: 2)),
        task: TaskFixtures.fifthTask,
        number: 'АВР-25836974')
  });

  //Тестовая фикстура, чтобы проверить, что фикстуры переключаются
  static List<Notify> test = List.of({
    new Notify(
        id: 1,
        time: "Тест успешен, фикстура изменилась",
        text: "Назначена задача АВР-123564",
        date: DateTime.now(),
        task: TaskFixtures.firstTask,
        number: 'АВР-123564'),
  });

  /// Метод для получения фикстуры уведомлений
  List<Notify> getNotify() {
    return firstNotifyFixture;
  }

  ///Запускаем стрим, который дает список открытых уведомлений
  Stream<List<Notify>> streamOpenedNotification() async* {
    List<Notify> notifies = getNotify();

    yield notifies;

    await Future.delayed(Duration(seconds: 10));
  }
}
