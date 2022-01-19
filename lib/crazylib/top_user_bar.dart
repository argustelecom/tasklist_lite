import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/pages/notifications_page.dart';
import 'package:tasklist_lite/state/notification_controller.dart';

class TopUserBar extends StatelessWidget implements PreferredSizeWidget {

  @override
  Widget build(BuildContext context) {

    // Вызваем NotificationController, чтобы взять у него инфу по наличию уведомлений
    return GetBuilder<NotificationController>(
      init: NotificationController(),
      builder: (controller) {
        // Если есть, то колокольчик звонит, а если нет ...
        if (controller.haveNotification()){
          return Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 18),
              child: AppBar(
                leading: Icon(Icons.account_circle_outlined),
                titleSpacing: 0.0,
                toolbarHeight: 100,
                title: Column(
                  children: [Text("VLG_BOGDANOVA,"), Text("Вологодская обл.")],
                ),
                actions: [
                  IconButton(
                    iconSize: 36, //IconTheme.of(context).size ?? 24,
                    tooltip: 'Уведомления',
                    icon: const Icon(Icons.notifications_active),
                    onPressed: () {
                      Navigator.pushNamed(context, NotificationsPage.routeName);
                    },
                  ),
                  IconButton(
                    iconSize: IconTheme.of(context).size ?? 24,
                    tooltip: 'Выход',
                    icon: const Icon(Icons.exit_to_app_outlined),
                    onPressed: () {},
                  ),
                ],
              ));
        }
        else {
          return Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 18),
              child: AppBar(
                leading: Icon(Icons.account_circle_outlined),
                titleSpacing: 0.0,
                toolbarHeight: 100,
                title: Column(
                  children: [Text("VLG_BOGDANOVA,"), Text("Вологодская обл.")],
                ),
                actions: [
                  IconButton(
                    iconSize: 36, //IconTheme.of(context).size ?? 24,
                    tooltip: 'Уведомления',
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, NotificationsPage.routeName);
                    },
                  ),
                  IconButton(
                    iconSize: IconTheme.of(context).size ?? 24,
                    tooltip: 'Выход',
                    icon: const Icon(Icons.exit_to_app_outlined),
                    onPressed: () {},
                  ),
                ],
              ));
        }
      },
    );


  }

  @override
  //  #TODO: почему bottom bar не требует указания preferred, а здесь нужно?
  // #TODO: не нравится, что ставится в компоненте, а не наследуется от дерева компонентов
  Size get preferredSize => const Size.fromHeight(80.0);
}
