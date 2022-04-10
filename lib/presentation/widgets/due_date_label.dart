import 'package:flutter/material.dart';

/// вызывается в нескольких местах (как минимум, в карточке задачи в списке и на форме задачи)
/// нужен, чтобы не дублировать логику особого отображения КС(например, цвет)
class DueDateLabel extends StatelessWidget {
  final String dueDate;
  final bool isOverdue;

  DueDateLabel({required this.dueDate, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    return Text(
      "КС: " + dueDate,
      style: TextStyle(
          inherit: false,
          fontSize: 14,
          color: isOverdue ? Colors.red : Colors.green),
      textAlign: TextAlign.left,
    );
  }
}
