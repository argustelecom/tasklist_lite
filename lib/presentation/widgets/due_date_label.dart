import 'package:flutter/material.dart';
import 'package:tasklist_lite/domain/entities/task.dart';

/// вызывается в нескольких местах (как минимум, в карточке задачи в списке и на форме задачи)
/// нужен, чтобы не дублировать логику особого отображения КС(например, цвет)
class DueDateLabel extends StatelessWidget {
  final Task task;

  DueDateLabel({required this.task});

  @override
  Widget build(BuildContext context) {
    if (task.isPlanned == true) {
      return Text(
            "c " +
            task.getCreateDateFulltext() +
            " по " +
            task.getScheduledDateFulltext(),
        maxLines: 3,
        softWrap: true,
        style: TextStyle(
            inherit: false,
            fontSize: 14,
            color: task.isTaskOverdue() ? Colors.red : Colors.green),
        textAlign: TextAlign.left,
      );
    } else {
      return Text(
        "КС: " + task.getDueDateFullText(),
        style: TextStyle(
            inherit: false,
            fontSize: 14,
            color: task.isTaskOverdue() ? Colors.red : Colors.green),
        textAlign: TextAlign.left,
      );
    }
  }
}
