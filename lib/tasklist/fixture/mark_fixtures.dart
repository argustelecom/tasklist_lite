import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/mark.dart';

class MarkFixtures {
  static final mark_1 = new Mark(
      id: 1,
      task: TaskFixtures.firstTask,
      name:
          "Неcвоевременное выполнение производственного задания (нарушение срока выполнения заявки по вине сотрудника)",
      value: "2",
      date: DateTime.now(),
      worker: "Иванов. И. И.",
      type: "Списание");
  static final mark_2 = new Mark(
      id: 2,
      task: TaskFixtures.firstTask,
      name:
          "Нарушение правил внутреннего трудового распорядка и производсвтенной дисциплины",
      value: "5",
      date: DateTime.now(),
      worker: "Иванов. И. И.",
      type: "Списание");
  static final mark_3 = new Mark(
      id: 3,
      task: TaskFixtures.firstTask,
      name: "Выполнение работ",
      value: "1",
      date: DateTime.now(),
      worker: "Иванов. И. И.",
      type: "Начисление");

  List<Mark> markFixture = List.of({mark_1, mark_2, mark_3});

  List<Mark> getMarks() {
    return markFixture;
  }
}
