import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/tasklist/model/mark.dart';

/// Карточка оценки
class MarkCard extends StatelessWidget {
  final Mark mark;
  ///Это максимальное кол-во строк для отображения.На страничке с историей ограничено до 10, на страничке с комментом до 1000 = неограничено по задумке
  final maxLines;

  MarkCard({Key? key, required this.mark, this.maxLines})
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
                  child: Text("${mark.type}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 8, right: 16),
                  child: Container(
                    child: Text(
                      "${mark.value}" + " балл.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 10,
                    ),
                  ))
            ],
          ),
          Container(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                    padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                    child: Text(
                      "${mark.name}",
                      style: const TextStyle(fontSize: 14),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                    )),
              )),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16, top: 8),
                child: Text(
                    "${mark.worker}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: 8, right: 16),
                child: Container(
                  child: Text(
                      "${DateFormat('dd.MM.yyyy HH:mm', "ru_RU").format(mark.date)}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ))
          ],
        )
        ],
      ),
    );
  }
}
