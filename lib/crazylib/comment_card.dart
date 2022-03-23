import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../state/auth_state.dart';

/// Это карточка исторического события, данные карточки используем на task_page
/// для представления исторических событий на соответсвующей вкладке
class CommentCard extends StatelessWidget {
  ///Это комментарий который передаем в карточку для отображения
  final comment;

  ///Это максимальное кол-во строк для отображения.На страничке с историей ограничено до 10, на страничке с комментом до 1000 = неограничено по задумке
  final maxLines;
  AuthState authState = Get.find();

  CommentCard({Key? key, required this.comment, this.maxLines})
      : super(key: key);

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
                  child: Text(
                      authState.userInfo.value!.getWorkerNameWithInitials() ==
                              comment.person
                          ? "Вы"
                          : "${comment.person}",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
          Container(
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Html(
                    data: comment.content,
                    style: {
                      "body": Style(
                          fontSize: FontSize(14.0),
                          maxLines: maxLines,
                          padding: EdgeInsets.only(left: 8, right: 8),
                          textOverflow: TextOverflow.ellipsis),
                    },
                    // TODO: Заполни тег лист
                    tagsList: Html.tags,
                  ))),
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
