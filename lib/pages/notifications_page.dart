import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/crazylib/notification_card.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
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

  List <Task> taskstest = new TaskFixtures().thirdTaskFixture;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return GetBuilder<NotificationController>(
        init: NotificationController(),
        builder:(controller) {
      // Если нет уведомлений показываем сообщение, что не на что смотреть
      print(controller.aliveNotifications);
      if (controller.getNotification().length == 0) {
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
              child: Row(
                children: [
                  Text("Тут не на что смотреть", textAlign: TextAlign.center)
                ],
              ),
            ),
            );
            // bottomNavigationBar: BottomButtonBar());
      }

      else {
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
                height: 800,
                child:ListView(

                  shrinkWrap: true,
                  children: [
                    DateRow(date: DateTime.now()),
                    ListView.separated(
                      // Делаем разделитель
                      separatorBuilder: (BuildContext context, int index)  {
                        // Достаем плашку, когда дата следующего оповещения отличается от текущей
                        // Для корректной работы на вход ожидается отсортированный по дате список уведомлений
                        // #TODO: Надо сортировать список уведомлений на уровне контроллера
                        if (controller.getNotification()[index].date != controller.getNotification()[index+1].date){
                          return DateRow(date:controller.getNotification()[index+1].date);
                        }
                        // Если нет плашки, то выкладываем разделитель.
                        // Без него крашится, сделал пока бесцеветным-незаметным
                        return Divider(color: themeData.highlightColor);
                      },
                      shrinkWrap: true,
                      itemCount: controller.getNotification().length,
                      itemBuilder: (BuildContext context, int index) {
                        // если смахнуть в любую сторону уведомление, то считаем его прочитанным и оно из UI пропадает
                        return Dismissible(
                          key: UniqueKey(),
                          child: NotificationCard(
                              notify: controller.getNotification()[index],
                              task: taskstest[index],
                              taskPageRoutName: 'task'),
                          onDismissed: (direction) {
                            // Когда смахиваем уведомление, добавляем его в DeadNotifications и удаляем его из aliveNotifications.
                            // Возможно DeadNotifications пригодится в будущем для истории уведомлений
                            setState(() {
                              controller.addDeadNotifications(controller.getNotification()[index]);
                              controller.removeAliveNotification(controller.getNotification()[index]);
                            });
                          },
                        );

                      },
                    )
                  ],
                ),
              )


              ),
              );
      }
    }
      );

    }
  }
