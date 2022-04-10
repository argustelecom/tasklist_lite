import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task.dart';
import '../controllers/tasklist_controller.dart';

/// Вывод строки Параметр: Значение для версии 1.0
/// Тут мы не используем группы, они нам не нужны
/// ListView.separated выбран для реализации кнопки показать все
class AttribValue extends StatelessWidget {
  final Task? task;
  final TaskListController taskListController = Get.find();

  AttribValue({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    if (task != null) {
      LinkedHashMap<String, Object?> attributes = task!.getAttrValuesByTask();
      return ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) {
            if (attributes.keys.elementAt(index) == 'Примечание' &&
                attributes.values.elementAt(index).toString().length > 200) {
              return TextButton(
                  child: taskListController.maxLinesCommentary == 3
                      ? Text("прочитать полностью ↓",
                          style: TextStyle(fontWeight: FontWeight.w100))
                      : Text("скрыть ↑",
                          style: TextStyle(fontWeight: FontWeight.w100)),
                  onPressed: () {
                    taskListController.maxLinesCommentary == 3
                        ? taskListController.maxLinesCommentary = 500
                        : taskListController.maxLinesCommentary = 3;
                  });
            } else if (attributes.keys.elementAt(index) ==
                    'Адресное примечание' &&
                attributes.values.elementAt(index).toString().length > 200) {
              return TextButton(
                  child: taskListController.maxLinesAddressCommentary == 3
                      ? Text("прочитать полностью ↓",
                          style: TextStyle(fontWeight: FontWeight.w100))
                      : Text("скрыть ↑",
                          style: TextStyle(fontWeight: FontWeight.w100)),
                  onPressed: () {
                    taskListController.maxLinesAddressCommentary == 3
                        ? taskListController.maxLinesAddressCommentary = 500
                        : taskListController.maxLinesAddressCommentary = 3;
                  });
            }
            return Divider(
                height: 0, thickness: 0, color: themeData.highlightColor);
          },
          itemCount: attributes.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(children: [
              Row(children: [
                Expanded(
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: RichText(
                            maxLines:
                                attributes.keys.elementAt(index) == 'Примечание'
                                    ? taskListController.maxLinesCommentary
                                    : attributes.keys.elementAt(index) ==
                                            'Адресное примечание'
                                        ? taskListController
                                            .maxLinesAddressCommentary
                                        : 3,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Color(0xFF646363),
                                    fontWeight: FontWeight.normal),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          "${attributes.keys.elementAt(index)}:   "),
                                  TextSpan(
                                      text: attributes.values
                                                  .elementAt(index) ==
                                              null
                                          ? ""
                                          : (attributes.values
                                                      .elementAt(index)
                                                      .runtimeType ==
                                                  DateTime
                                              ? DateFormat("dd.MM.yyyy HH:mm")
                                                  .format(DateTime.parse(
                                                      attributes.values
                                                          .elementAt(index)
                                                          .toString()))
                                              : attributes.values
                                                  .elementAt(index)
                                                  .toString()),
                                      style: TextStyle(color: Colors.black))
                                ]))))
              ]),
            ]);
          });
    } else {
      return Container();
    }
  }
}
