import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/crazylib/notification_card.dart';
import 'package:tasklist_lite/state/notification_controller.dart';
import 'package:tasklist_lite/crazylib/date_row.dart';

class NotificationsPage extends StatefulWidget {
  static const String routeName = 'Notifications';

  NotificationsPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  //Обновляем зависимости, в случае, если изменилась фикстура
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Get.isRegistered<NotificationController>()) {
      ApplicationState applicationState = ApplicationState.of(context);
      Get.delete<ApplicationState>();
      // #TODO: в ходе билда будет вызываться логика контроллера, которая вызовет repository, который, в свою очередь, хочет
      // актуальный экземпляр ApplicationState
      Get.put(applicationState);
      NotificationController notificationController = Get.find();
      notificationController.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

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
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                  child: SizedBox(
                    width: 600,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        DateRow(date: controller.getNotifications()[0].date),
                        ListView.separated(
                          // Делаем разделитель
                          separatorBuilder: (BuildContext context, int index) {
                            // Достаем плашку, когда дата следующего оповещения отличается от текущей
                            // Для корректной работы на вход ожидается отсортированный по дате список уведомлений
                            // #TODO: Надо сортировать список уведомлений на уровне контроллера
                            if (controller.getNotifications()[index].date !=
                                controller.getNotifications()[index + 1].date) {
                              return DateRow(
                                  date: controller
                                      .getNotifications()[index + 1]
                                      .date);
                            }
                            // Если нет плашки, то выкладываем разделитель.
                            // Без него крашится, сделал пока бесцеветным-незаметным
                            return Divider(color: themeData.highlightColor);
                          },
                          shrinkWrap: true,
                          itemCount: controller.getNotifications().length,
                          itemBuilder: (BuildContext context, int index) {
                            // если смахнуть в любую сторону уведомление, то считаем его прочитанным и оно из UI пропадает
                            return Dismissible(
                              key: UniqueKey(),
                              child: NotificationCard(
                                  notify: controller.getNotifications()[index],
                                  task: controller.getNotifications()[index].task,
                                  taskPageRouteName: 'task'),
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
                    Navigator.pop(context);
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
