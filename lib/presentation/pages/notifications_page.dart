import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/presentation/controllers/notification_controller.dart';
import 'package:tasklist_lite/presentation/pages/task_page.dart';
import 'package:tasklist_lite/presentation/widgets/cards/notification_card.dart';
import 'package:tasklist_lite/presentation/widgets/date_row.dart';
import 'package:tasklist_lite/presentation/widgets/reflowing_scaffold.dart';

import '../controllers/tasklist_controller.dart';

class NotificationsPage extends StatefulWidget {
  static const String routeName = 'Notifications';

  NotificationsPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    TaskListController taskListController = Get.find();

    return GetBuilder<NotificationController>(
        init: NotificationController(),
        builder: (controller) {
          if (controller.haveNotifications()) {
            return ReflowingScaffold(
              appBar: AppBar(
                title: new Text("Уведомления"),
                leading: IconButton(
                  icon: Icon(Icons.chevron_left_outlined),
                  onPressed: () {
                    GetDelegate routerDelegate = Get.find();
                    routerDelegate.popRoute();
                  },
                ),
              ),
              body: Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                  child: SingleChildScrollView(
                    // width: MediaQuery.of(context).size.width,
                    physics: ScrollPhysics(),
                    child: Column(
                      children: [
                        DateRow(date: controller.getNotifications()[0].date),
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          // Делаем разделитель
                          separatorBuilder: (BuildContext context, int index) {
                            // Достаем плашку, когда дата следующего оповещения отличается от текущей
                            // Для корректной работы на вход ожидается отсортированный по дате список уведомлений
                            if (DateFormat('dd MMMM yyyy', "ru_RU").format(
                                    controller
                                        .getNotifications()[index]
                                        .date) !=
                                DateFormat('dd MMMM yyyy', "ru_RU").format(
                                    controller
                                        .getNotifications()[index + 1]
                                        .date)) {
                              return DateRow(
                                  date: controller
                                      .getNotifications()[index + 1]
                                      .date);
                            }
                            // Если нет плашки, то выкладываем разделитель.
                            // Без него крашится, сделал пока бесцеветным-незаметным
                            return Divider(
                              color: themeData.highlightColor,
                              height: 0,
                            );
                          },
                          shrinkWrap: true,
                          itemCount: controller.getNotifications().length,
                          itemBuilder: (BuildContext context, int index) {
                            // если смахнуть в любую сторону уведомление, то считаем его прочитанным и оно из UI пропадает
                            return Dismissible(
                              key: UniqueKey(),
                              child: NotificationCard(
                                  onTap: () {
                                    // taskListController.findCurrentTask(controller.getNotifications()[index].task);
                                    taskListController
                                            .taskListState.currentTask.value =
                                        controller
                                            .getNotifications()[index]
                                            .task;
                                    GetDelegate routerDelegate = Get.find();
                                    routerDelegate.toNamed(
                                      TaskPage.routeName,
                                      arguments: taskListController
                                          .taskListState.currentTask.value,
                                    );
                                  },
                                  notify: controller.getNotifications()[index],
                                  task: controller
                                      .getNotifications()[index]
                                      .task),
                              onDismissed: (direction) {
                                // Когда смахиваем уведомление, добавляем его в DeadNotifications и удаляем его из aliveNotifications.
                                // Возможно DeadNotifications пригодится в будущем для истории уведомлений
                                setState(() {
                                  controller.addDeadNotification(
                                      controller.getNotifications()[index]);
                                  controller.removeAliveNotification(
                                      controller.getNotifications()[index]);
                                });
                              },
                            );
                          },
                        )
                      ],
                    ),
                  )),
            );
            // Если нет уведомлений показываем сообщение, что не на что смотреть
          } else {
            return ReflowingScaffold(
              appBar: AppBar(
                title: new Text("Уведомления"),
                leading: IconButton(
                  icon: Icon(Icons.chevron_left_outlined),
                  onPressed: () {
                    GetDelegate routerDelegate = Get.find();
                    routerDelegate.popRoute();
                  },
                ),
              ),
              body: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 32),
                  child: Text("У Вас нет непрочитанных уведомлений",
                      textAlign: TextAlign.left)),
            );
          }
        });
  }
}
