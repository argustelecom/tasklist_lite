import 'dart:collection';

import 'package:tasklist_lite/domain/entities/task.dart';
import 'package:test/test.dart';

void main() {
  group('model Task', () {
    test('Task.isOverdue() должен вернуть false, когда dueDate=null', () {
      Task task = Task(
          id: 1,
          name: 'task-1',
          assignee: [],
          dueDate: null,
          flexibleAttribs: LinkedHashMap());

      expect(task.isTaskOverdue(), false);
    });

    test(
        'Task.isOverdue() должен вернуть false, когда dueDate наступает после текущего момента',
        () {
      DateTime dueDateForTask2 = DateTime.now().add(Duration(days: 2));
      Task task2 = Task(
          id: 2,
          name: 'task-2',
          assignee: [],
          dueDate: dueDateForTask2,
          flexibleAttribs: LinkedHashMap());

      expect(task2.isTaskOverdue(), false);
    });

    test('Task.isOverdue() должен вернуть true, когда dueDate уже прошел', () {
      DateTime dueDateForTask = DateTime.now().add(Duration(days: -2));
      Task task3 = Task(
          id: 1,
          name: 'task-3',
          assignee: [],
          dueDate: dueDateForTask,
          flexibleAttribs: LinkedHashMap());

      expect(task3.isTaskOverdue(), true);
    });
  });
}
