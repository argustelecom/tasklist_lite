import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tasklist_lite/tasklist/model/notify.dart';

/// визуальное представление уведомления на странице уведомлений
/// #TODO: также используется и в старой карусели в AlternativeTaskListPage, но никто даже не смотрел, как оно там выглядит
class NotificationCard extends StatelessWidget {
  final Notify notify;
  //final String taskPageRoutName;
  const NotificationCard ({Key? key, required this.notify })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    // размеры сознательно здесь не заданы, чтобы можно было масштабировать карточку снаружи, по размерам parent`а
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.98,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: ExpansionTile(
          title: Text(notify.time, style: TextStyle(fontStyle: FontStyle.italic)) ,
          subtitle: Text(notify.number),
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
