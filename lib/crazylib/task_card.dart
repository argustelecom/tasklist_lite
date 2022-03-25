import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/due_date_label.dart';
import 'package:tasklist_lite/crazylib/location_button.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/task_page.dart';
import '../tasklist/fixture/task_fixtures.dart';
import 'crazy_highlight.dart';

/// визуальное представление задачи в списке задач
class TaskCard extends StatelessWidget {
  final Task task;

  static const double taskCardElevation = 2;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return GetBuilder<TaskListController>(
      builder: (taskListController) {
        // размеры сознательно здесь не заданы, чтобы можно было масштабировать карточку снаружи, по размерам parent`а
        return Card(
          color: (task.isClosed ? Color(0xFFE5E4E4) : themeData.cardColor),
          elevation: taskCardElevation,
          // без обертывания строки в IntrinsicHeight, не получилось увидеть VerticalDivider
          // https://stackoverflow.com/questions/49388281/flutter-vertical-divider-and-horizontal-divider
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      taskListController.taskListState.currentTask.value = task;
                      GetDelegate routerDelegate = Get.find();
                      routerDelegate.toNamed(TaskPage.routeName,
                          arguments: this.task);
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, top: 12, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // обеспечит подсветку текста, введенного в строку поиска, и присутствующего среди названий заадач
                              CrazyHighlight(
                                // если есть номер заявки оператора, отображаем его. Если нет, отображаем номер из Аргуса
                                // при этом, если показали номер Аргуса, не показываем его ниже (см. соответсна ниже)
                                text: task.flexibleAttribs[TaskFixtures
                                            .foreignOrderIdFlexAttrName]
                                        ?.toString() ??
                                    task.name,
                                term: taskListController.searchText,
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              CrazyHighlight(
                                text: task.flexibleAttribs[
                                            TaskFixtures.objectNameFlexAttrName]
                                        ?.toString() ??
                                    "",
                                term: taskListController.searchText,
                                width: MediaQuery.of(context).size.width * 0.3,
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CrazyHighlight(
                                text: task.flexibleAttribs[TaskFixtures
                                            .foreignOrderIdFlexAttrName] !=
                                        null
                                    ? task.name
                                    : "",
                                term: taskListController.searchText,
                              ),
                              CrazyHighlight(
                                text: task.flexibleAttribs[TaskFixtures
                                            .orderOperatorNameFlexAttrName]
                                        ?.toString() ??
                                    "",
                                width: MediaQuery.of(context).size.width * 0.3,
                                term: taskListController.searchText,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 4, left: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              DueDateLabel(
                                dueDate: task.getDueDateFullText(),
                                isOverdue: task.isTaskOverdue(),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16, bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CrazyHighlight(
                                  text: task.getAddressDescription(),
                                  term: taskListController.searchText),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: VerticalDivider(),
                ),
                LocationButton(task: task)
              ],
            ),
          ),
        );
      },
    );
  }
}
