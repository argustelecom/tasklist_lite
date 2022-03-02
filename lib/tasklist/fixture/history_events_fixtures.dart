import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/history_event.dart';

import '../model/task.dart';

class HistoryEventsFixtures {
  static List<HistoryEvent> firstHistoryEventFixture = List.of({
    new HistoryEvent(
        person: "Кошкин Т.",
        type: "Комментарий",
        content: "Взяли в работу. Выезжаем",
        date: DateTime.now(),
        isAlarm: true),
    new HistoryEvent(
        person: "Собакевич П.",
        type: "Вложение",
        content: "фото_объекта.jpg",
        date: DateTime.now().subtract(Duration(days: 1)),
        isAlarm: false),
    new HistoryEvent(
        person: "Собакевич П.",
        type: "Комментарий",
        content: "Юстировка БС 2321. взять с собой лопату ",
        date: DateTime.now().subtract(Duration(days: 1)),
        isAlarm: true),
    new HistoryEvent(
        person: "RT_TTMS_USER",
        type: "Уведомление",
        content:
            " АВР-T2-15870316;Участок Неизвестные объекты О2О подписался на задачу "
            "Регистрация наряда О2О по уведомлениям: ИнформированиеЗадача: Регистрация наряда О2О; "
            "Участок:Неизвестные объекты О2О;Название: ?; "
            "Время отсчета контрольного срока: 31.10.2021 18:42 (+05:00); Сдвиг: 2229 час. 12 мин.; Примечание: ?;  ",
        date: DateTime.now().subtract(Duration(days: 2)),
        isAlarm: false),
  });

  static List<HistoryEvent> secondHistoryEventFixture = List.of({
    new HistoryEvent(
        person: "Канарейкин И.",
        type: "Комментарий",
        content: "Принято",
        date: DateTime.now(),
        isAlarm: true),
    new HistoryEvent(
        person: "Дроздов Д.",
        type: "Вложение",
        content: "схема_проезда.jpg",
        date: DateTime.now().subtract(Duration(days: 1)),
        isAlarm: false),
    new HistoryEvent(
        person: "Дроздов Д.",
        type: "Комментарий",
        content: "Пятый поворот у третей сосны",
        date: DateTime.now().subtract(Duration(days: 1)),
        isAlarm: true),
    new HistoryEvent(
        person: "RT_TTMS_USER",
        type: "Уведомление",
        content:
            " АВР-T2-15870316;Участок Неизвестные объекты О2О подписался на задачу "
            "Регистрация наряда О2О по уведомлениям: ИнформированиеЗадача: Регистрация наряда О2О; "
            "Участок:Неизвестные объекты О2О;Название: ?; "
            "Время отсчета контрольного срока: 31.10.2021 18:42 (+05:00); Сдвиг: 2229 час. 12 мин.; Примечание: ?;  ",
        date: DateTime.now().subtract(Duration(days: 2)),
        isAlarm: false),
  });

  static List<HistoryEvent> thirdHistoryEventFixture = List.of({
    new HistoryEvent(
        person: "Мышкин В.",
        type: "Вложение",
        content: "фото_антенны.jpg",
        date: DateTime.now(),
        isAlarm: true),
    new HistoryEvent(
        person: "Мышкин В.",
        type: "Вложение",
        content: "фото_БС_2764>.jpg",
        date: DateTime.now().subtract(Duration(days: 1)),
        isAlarm: false),
    new HistoryEvent(
        person: "Хомяк Е.",
        type: "Комментарий",
        content: "Просьба предоставить фото с объекта",
        date: DateTime.now().subtract(Duration(days: 1)),
        isAlarm: true),
    new HistoryEvent(
        person: "RT_TTMS_USER",
        type: "Уведомление",
        content: " Участок Неизвестные объекты О2О подписался на задачу "
            "Регистрация наряда О2О по уведомлениям: ИнформированиеЗадача: Регистрация наряда О2О; "
            "Участок:Неизвестные объекты О2О;Название: ?; "
            "Время отсчета контрольного срока: 31.10.2021 18:42 (+05:00); Сдвиг: 2229 час. 12 мин.; Примечание: ?;  ",
        date: DateTime.now().subtract(Duration(days: 2)),
        isAlarm: false),
  });

  /// Метод получения событий по наряду. На вход передаем задачу, по которой хотим получить события
  List<HistoryEvent> getHistoryEvents(Task task) {
    if (task == TaskFixtures.firstTask) {
      return firstHistoryEventFixture;
    } else if (task == TaskFixtures.secondTask) {
      return secondHistoryEventFixture;
    } else {
      return thirdHistoryEventFixture;
    }
  }
}
