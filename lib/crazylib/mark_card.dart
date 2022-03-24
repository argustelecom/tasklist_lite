import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/tasklist/model/mark.dart';

/// Карточка оценки
class MarkCard extends StatelessWidget {
  final Mark mark;

  ///Это максимальное кол-во строк для отображения.На страничке с историей ограничено до 10, на страничке с комментом до 1000 = неограничено по задумке
  final maxLines;

  MarkCard({Key? key, required this.mark, this.maxLines}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Card(
      shadowColor: Color(0x40000000),
      elevation: 10,
      margin: EdgeInsets.all(5),
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(bottom: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, top: 6),
                      child: Text("${mark.type}",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto')),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 6, right: 3),
                      child: Container(
                        child: Text(
                          "${mark.value}" + " балл.",
                          style:
                              TextStyle(fontSize: 14, color: Color(0xA6000000)),
                          maxLines: 10,
                        ),
                      ))
                ],
              )),
          Container(
              child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 9),
                child: Text(
                  "${mark.reason}",
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
                  padding: EdgeInsets.only(left: 10, bottom: 10),
                  child: Text("${mark.worker}",
                      style: const TextStyle(
                          fontSize: 12, color: Color(0x6000000A))),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(bottom: 5, right: 3),
                  child: Container(
                    child: Text(
                        "${DateFormat('dd.MM.yyyy HH:mm', "ru_RU").format(mark.createDate)}",
                        style: const TextStyle(
                            fontSize: 12, color: Color(0x80000000))),
                  ))
            ],
          )
        ],
      ),
    );
  }
}
