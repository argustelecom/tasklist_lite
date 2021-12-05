import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';

/// визуальное представление задачи в карусели задач
// #TODO: согласовать визуальные требования к карточке с аналитиками и сделать ее красивенькой
class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    // размеры сознательно здесь не заданы, чтобы можно было масштабировать карточку снаружи, по размерам parent`а
    // // #TODO: опять же, margins
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: themeData.colorScheme.primaryVariant,
      ),
      child: Text(task.name),
    );
  }
}
