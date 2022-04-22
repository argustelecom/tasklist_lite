import 'package:flutter/material.dart';
import 'package:tasklist_lite/domain/entities/task.dart';

/// вызывается в нескольких местах (как минимум, в карточке задачи в списке и на форме задачи)
/// нужен, чтобы не дублировать логику особого отображения КС(например, цвет)
class DueDateLabel extends StatelessWidget {
  final Task task;
  final bool forStage;

  DueDateLabel({required this.task, required this.forStage});

  @override
  Widget build(BuildContext context) {
      return Text(
        "КС: " +
            "${forStage ? task.stage!.getDueDateFullText() : task.getDueDateFullText()}",
        style: TextStyle(
            inherit: false,
            fontSize: 14,
            color: task.isTaskOverdue() ? Colors.red : Colors.green),
        textAlign: TextAlign.left,
      );
  }
}
