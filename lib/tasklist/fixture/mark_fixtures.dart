import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/mark.dart';

import '../model/task.dart';

class MarkFixtures {
  static final mark_1 = new Mark(
      reason:
          "Неcвоевременное выполнение производственного задания (нарушение срока выполнения заявки по вине сотрудника)",
      value: "2",
      createDate: DateTime.now(),
      worker: "Иванов. И. И.",
      type: "Списание");
  static final mark_2 = new Mark(
      reason:
          "Нарушение правил внутреннего трудового распорядка и производсвтенной дисциплины",
      value: "5",
      createDate: DateTime.now(),
      worker: "Иванов. И. И.",
      type: "Списание");
  static final mark_3 = new Mark(
      reason: "Выполнение работ",
      value: "1",
      createDate: DateTime.now(),
      worker: "Иванов. И. И.",
      type: "Добавление");

  List<Mark> markFixture = List.of({mark_1, mark_2, mark_3});

  List<Mark> getMarks() {
    return markFixture;
  }

  ///Запускаем стрим, который дает список комментов
  Stream<List<Mark>> streamComments(Task? task) async* {
    List<Mark> marks = getMarks();

    yield marks;

    await Future.delayed(Duration(seconds: 10));
  }
}
