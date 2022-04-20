import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/presentation/controllers/tasklist_controller.dart';

import '../attribValue.dart';
import '../butttons/location_button.dart';
import '../due_date_label.dart';

/// Вкладка сведения для taskPage
class SummaryTab extends StatelessWidget {
  TaskListController taskListController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 12, right: 12, bottom: 12,top: 8),
      child: Card(
          child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                children: [
                  Row(children: [
// Выводим наряд закрыт, если он закрыт 0_0
                    if (taskListController.taskListState.currentTask.value !=
                            null &&
                        taskListController
                            .taskListState.currentTask.value!.isClosed)
                      Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Text("Наряд закрыт",
                              style: TextStyle(fontWeight: FontWeight.bold))),
//Это тут для того, чтобы наряды ТО у нас не падали т.к. у них нет этапа
                    if (taskListController
                            .taskListState.currentTask.value?.stage !=
                        null)
                      Column(
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                              child: Row(children: [
                                Text(
                                    "${taskListController.taskListState.currentTask.value!.stage!.name}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ])),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Row(children: [
                              DueDateLabel(
                                  task: taskListController.taskListState.currentTask.value!,)
                            ]),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Row(children: [
                              Text(
                                "${taskListController.taskListState.currentTask.value!.stage!.getTimeLeftStageText()}",
                                style: TextStyle(
                                    color: taskListController.taskListState
                                            .currentTask.value!.stage!
                                            .getTimeLeftStageText()
                                            .contains('СКВ')
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: 14),
                              ),
                            ]),
                          ),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
//Выводим статус для плановых работ
                    if (taskListController
                            .taskListState.currentTask.value?.isClosed != true && taskListController
                        .taskListState.currentTask.value?.isPlanned != false)
                      Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Text("Техническое обслуживание",
                              style: TextStyle(fontWeight: FontWeight.bold))),
//Клизма
                    LocationButton(
                        task:
                            taskListController.taskListState.currentTask.value)
                  ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
//Прогресс бар для этапов
                  if (taskListController
                          .taskListState.currentTask.value?.stage !=
                      null)
                    Row(children: [
// Первый этап
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(
                                left: 12, right: 4, bottom: 5, top: 12),
                            child: LinearProgressIndicator(
                              value: taskListController
                                  .taskListState.currentTask.value!
                                  .getStageProgressStatus(
                                      1,
                                      taskListController.taskListState
                                          .currentTask.value!.stage!),
                              color: Colors.yellow.shade700,
                              minHeight: 12,
                              backgroundColor: Colors.yellow.shade200,
                            )),
                      ),
// Второй этап
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(
                                left: 4, right: 4, bottom: 5, top: 12),
                            child: LinearProgressIndicator(
                              value: taskListController
                                  .taskListState.currentTask.value!
                                  .getStageProgressStatus(
                                      2,
                                      taskListController.taskListState
                                          .currentTask.value!.stage!),
                              color: Colors.yellow.shade700,
                              minHeight: 12,
                              backgroundColor: Colors.yellow.shade200,
                            )),
                      ),
// Третий этап
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(
                                left: 4, right: 4, bottom: 5, top: 12),
                            child: LinearProgressIndicator(
                              value: taskListController
                                  .taskListState.currentTask.value!
                                  .getStageProgressStatus(
                                      3,
                                      taskListController.taskListState
                                          .currentTask.value!.stage!),
                              color: Colors.yellow.shade700,
                              minHeight: 12,
                              backgroundColor: Colors.yellow.shade200,
                            )),
                      ),
// Четвертый этап
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(
                                left: 4, right: 12, bottom: 5, top: 12),
                            child: LinearProgressIndicator(
                              value: taskListController
                                  .taskListState.currentTask.value!
                                  .getStageProgressStatus(
                                      4,
                                      taskListController.taskListState
                                          .currentTask.value!.stage!),
                              color: Colors.yellow.shade700,
                              minHeight: 12,
                              backgroundColor: Colors.yellow.shade200,
                            )),
                      ),
                    ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                  Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: LimitedBox(
                          maxHeight: 20000,
                          child: AttribValue(
                            task: taskListController
                                .taskListState.currentTask.value,
                          ))),
                ],
              ))),
    );
  }
}
