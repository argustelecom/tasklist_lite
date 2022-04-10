import 'package:tasklist_lite/data/fixture/task_fixtures.dart';
import 'package:tasklist_lite/domain/entities/comment.dart';

import '../../domain/entities/task.dart';

class CommentsFixtures {
  static List<Comment> firstCommentFixture = List.of({
    new Comment(
        person: "Кошкин Т.",
        type: "Комментарий",
        content: "Взяли в работу. Выезжаем",
        date: DateTime.now(),
        isAlarm: true),
    new Comment(
        person: "Собакевич П.",
        type: "Вложение",
        content: "фото_объекта.jpg",
        date: DateTime.now().subtract(Duration(days: 1)),
        isAlarm: false),
    new Comment(
        person: "Собакевич П.",
        type: "Комментарий",
        content: "Юстировка БС 2321. взять с собой лопату ",
        date: DateTime.now().subtract(Duration(days: 1)),
        isAlarm: true),
    new Comment(
        person: "RT_TTMS_USER",
        type: "Уведомление",
        content:
            " АВР-T2-15870316;Участок Неизвестные объекты О2О подписался на задачу "
            "Регистрация наряда О2О по уведомлениям: ИнформированиеЗадача: Регистрация наряда О2О; "
            "Участок:Неизвестные объекты О2О;Название: ?; "
            "Время отсчета контрольного срока: 31.10.2021 18:42 (+05:00); Сдвиг: 2229 час. 12 мин.; Примечание: ?;  ",
        date: DateTime.now().subtract(Duration(days: 2)),
        isAlarm: false),
    new Comment(
        person: "RT_TTMS_USER",
        type: "Уведомление",
        content: """                <div>Follow<a class='sup'><sup>pl</sup></a> 
                  Below hr
                    <b>Bold<b>
                <h1>what was sent down to you from your Lord</h1>, 
                and do not follow other guardians apart from Him. Little do 
                <span class='h'>you remind yourselves</span><a class='f'><sup f=2437>1</sup></a></div>
                """,
        date: DateTime.now().subtract(Duration(days: 2)),
        isAlarm: false),
  });

  static List<Comment> secondCommentFixture = List.of({
    new Comment(
        person: "Канарейкин И.",
        type: "Комментарий",
        content: "Принято",
        date: DateTime.now(),
        isAlarm: true),
    new Comment(
        person: "Дроздов Д.",
        type: "Вложение",
        content: "схема_проезда.jpg",
        date: DateTime.now().subtract(Duration(days: 1)),
        isAlarm: false),
    new Comment(
        person: "Дроздов Д.",
        type: "Комментарий",
        content: "Пятый поворот у третей сосны",
        date: DateTime.now().subtract(Duration(days: 1)),
        isAlarm: true),
    new Comment(
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

  static List<Comment> thirdCommentFixture = List.of({
    new Comment(
        person: "Мышкин В.",
        type: "Вложение",
        content: "фото_антенны.jpg",
        date: DateTime.now(),
        isAlarm: true),
    new Comment(
        person: "Мышкин В.",
        type: "Вложение",
        content: "фото_БС_2764>.jpg",
        date: DateTime.now().subtract(Duration(days: 1)),
        isAlarm: false),
    new Comment(
        person: "Хомяк Е.",
        type: "Комментарий",
        content: "Просьба предоставить фото с объекта",
        date: DateTime.now().subtract(Duration(days: 1)),
        isAlarm: true),
    new Comment(
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
  List<Comment> getComments(Task? task) {
    if (task == TaskFixtures.firstTask) {
      return firstCommentFixture;
    } else if (task == TaskFixtures.secondTask) {
      return secondCommentFixture;
    } else {
      return thirdCommentFixture;
    }
  }

  ///Запускаем стрим, который дает список комментов
  Stream<List<Comment>> streamComments(Task? task) async* {
    List<Comment> notifies = getComments(task);

    yield notifies;

    await Future.delayed(Duration(seconds: 10));
  }
}
