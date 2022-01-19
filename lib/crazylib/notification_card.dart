import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tasklist_lite/tasklist/model/notify.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';

/// Визуальное представление уведомления

class NotificationCard extends StatelessWidget {
  final Notify notify;
  final String taskPageRouteName;
  final Task task;

  const NotificationCard ({Key? key, required this.notify, required this.task, required this.taskPageRouteName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        child: ExpansionTile(
          title: Text(notify.time, style: TextStyle(fontStyle: FontStyle.italic)) ,
          subtitle: Padding(
            //Кликабельная ссылка на таск. Такой странный паддинг нужен чтобы не было мисклика когда раскрываешь ExpansionTile
            padding: EdgeInsets.only(right: 150),
             child : GestureDetector(
               child: Text(task.name, style: TextStyle(
                color: Colors.blue
                )
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  this.taskPageRouteName,
                  arguments: this.task,
                );
              },
            ),
            ),
          children: [
            ListTile(
                title: Text(notify.text)
            )
          ],
        ),

        decoration: BoxDecoration(
            color: themeData.cardColor,
            shape: BoxShape.rectangle)

    ),
    );
  }
}
