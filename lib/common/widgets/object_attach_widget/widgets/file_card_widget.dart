import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/common/widgets/object_attach_widget/model/object_attach.dart';
import 'package:tasklist_lite/common/widgets/object_attach_widget/object_attach_controller.dart';


class FileCardWidget extends StatelessWidget {
  final ObjectAttach objectAttach;

  FileCardWidget(this.objectAttach);

  ObjectAttachController objectAttachController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: objectAttachController.ignoring,
      child: GestureDetector(
          onTap: () {
            // тут получение полной версии прикрепленного аттача с СП
            // через контроллер
            objectAttachController.downloadFile(objectAttach, context);
          },
          child: Card(
            borderOnForeground: true,
            margin: EdgeInsets.all(10),
            shadowColor: Colors.blueGrey,
            elevation: 10,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        flex: 2,
                        child: SizedBox(
                          width: 120,
                          height: 140,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.memory((objectAttach.attachmentDataAsBytes()))
                           ,
                          ),
                        )
                    ),
                    Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 15),
                                      text: objectAttach.fileName)),
                              RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 15),
                                      text: DateFormat("dd.MM.yyyy HH:mm", "ru_RU")
                                          .format(objectAttach.createDate)
                                          .toString())),
                              RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 15),
                                      text: objectAttach.workerName)),
                            ],
                          ),
                        )),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                          mini: true,
                          onPressed: () {
                            objectAttachController.deleteAttach(objectAttach);
                          },
                          child: Icon(Icons.delete),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }
}