import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/pages/comment_page.dart';

/// Это карточка исторического события, данные карточки используем на task_page
/// для представления исторических событий на соответсвующей вкладке
class HistoryEventCard extends StatelessWidget {
 ///Это комментарий который передаем в карточку для отображения
  final comment;
  ///Это максимальное кол-во строк для отображения.На страничке с историей ограничено до 10, на страничке с комментом до 1000 = неограничено по задумке
  final maxLines;

  HistoryEventCard({Key? key, required this.comment, this.maxLines}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16, top: 8),
                  child: Text("${comment.person}",
                      style: TextStyle(
                        fontSize: 14,
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, right: 8),
                child: Icon(
                  comment.isAlarm ? Icons.notifications_active : null,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 8, right: 16),
                  child: Container(
                    child: Text(
                      "${comment.type}",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 10,
                    ),
                  ))
            ],
          ),
          Container( child: Align(
            alignment: Alignment.topLeft,
            child:
            Padding(
                padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                child: Text(
                  "${comment.content}",
                  style: const TextStyle(fontSize: 14),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                )),
          )),

          Padding(
            padding: EdgeInsets.only(right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                    "${DateFormat('dd.MM.yyyy HH:mm', "ru_RU").format(comment.date)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
