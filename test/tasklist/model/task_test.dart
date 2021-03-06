import 'dart:collection';

import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:test/test.dart';

void main() {
  group('model Task', () {
    test('Task.isOverdue() должен вернуть false, когда dueDate=null', () {
      Task task = Task(
          id: 1,
          biId: 1,
          name: 'task-1',
          dueDate: null,
          flexibleAttribs: LinkedHashMap());

      expect(task.isOverdue(), false);
    });

    test(
        'Task.isOverdue() должен вернуть false, когда dueDate наступает после текущего момента',
        () {
      DateTime dueDateForTask2 = DateTime.now().add(Duration(days: 2));
      Task task2 = Task(
          id: 2,
          biId: 2,
          name: 'task-2',
          dueDate: dueDateForTask2,
          flexibleAttribs: LinkedHashMap());

      expect(task2.isOverdue(), false);
    });

    test('Task.isOverdue() должен вернуть true, когда dueDate уже прошел', () {
      DateTime dueDateForTask = DateTime.now().add(Duration(days: -2));
      Task task3 = Task(
          id: 1,
          biId: 3,
          name: 'task-3',
          dueDate: dueDateForTask,
          flexibleAttribs: LinkedHashMap());

      expect(task3.isOverdue(), true);
    });
  });
}
