import 'package:flutter/material.dart';

import '../tasklist/model/task.dart';

/// вызывается в нескольких местах (как минимум, в карточке задачи в списке и на форме задачи)
/// нужен, чтобы не дублировать логику особого отображения КС(например, цвет)
class TaskDueDateLabel extends StatelessWidget {
  final Task task;
  TaskDueDateLabel({required this.task});

  @override
  Widget build(BuildContext context) {
    return Text(
      "КС: " + task.getDueDateFullText(),
      style: TextStyle(
          inherit: false,
          fontSize: 14,
          color: task.isOverdue() ? Colors.red : Colors.green),
      textAlign: TextAlign.left,
    );
  }
}
