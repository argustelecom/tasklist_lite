import 'package:flutter/material.dart';
import 'package:tasklist_lite/domain/entities/notify.dart';
import 'package:tasklist_lite/domain/entities/task.dart';

/// Визуальное представление уведомления

class NotificationCard extends StatelessWidget {
  final Notify notify;
  final Task task;
  final VoidCallback onTap;

  const NotificationCard(
      {Key? key, required this.notify, required this.task, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: EdgeInsets.only(left: 12, top: 4, right: 12, bottom: 4),
            child: Column(
              children: [
                Text(notify.time,
                    style: TextStyle(fontStyle: FontStyle.italic)),
                Padding(
                  //Кликабельная ссылка на таск. Такой странный паддинг нужен чтобы не было мисклика когда раскрываешь ExpansionTile
                  padding: EdgeInsets.only(right: 100),
                  child: GestureDetector(
                    child:
                        Text(task.name, style: TextStyle(color: Colors.blue)),
                    onTap: onTap,
                  ),
                ),
                Text(notify.text)
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        ));
  }
}
