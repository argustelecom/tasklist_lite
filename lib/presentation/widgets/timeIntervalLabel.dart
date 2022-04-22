import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class TimeIntervalLabel extends StatelessWidget{
  final Task task;

  TimeIntervalLabel({required this.task});

  @override
  Widget build(BuildContext context) {
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
  }


}