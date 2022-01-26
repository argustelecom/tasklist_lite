import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/pages/login_page.dart';
import 'package:tasklist_lite/pages/notifications_page.dart';
import 'package:tasklist_lite/state/auth_controller.dart';
import 'package:tasklist_lite/state/notification_controller.dart';

class TopUserBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<AuthController>(builder: (authController) {
      return Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
          child: AppBar(
            leading: Icon(Icons.account_circle_outlined),
            titleSpacing: 0.0,
            toolbarHeight: 100,
            title: Column(
              children: [
                Text(authController.userInfo == null
                    ? ""
                    : authController.userInfo!.userName + ","),
                Text(authController.userInfo == null
                    ? ""
                    : authController.userInfo!.homeRegionName),
              ],
            ),
            actions: [
              // Вызваем NotificationController, чтобы взять у него инфу по наличию уведомлений
              GetBuilder<NotificationController>(
                  init: NotificationController(),
                  builder: (notificationController) {
                    return IconButton(
                      iconSize: 36, //IconTheme.of(context).size ?? 24,
                      tooltip: 'Уведомления',
                      // Если есть, то колокольчик звонит, а если нет ...
                      icon: Icon(notificationController.haveNotification()
                          ? Icons.notifications_active
                          : Icons.notifications_outlined),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, NotificationsPage.routeName);
                      },
                    );
                  }),
              IconButton(
                iconSize: IconTheme.of(context).size ?? 24,
                tooltip: 'Выход',
                icon: const Icon(Icons.exit_to_app_outlined),
                onPressed: () {
                  authController.logout();
                  Navigator.pushNamed(context, LoginPage.routeName);
                },
              ),
            ],
          ));
    });
  }

  @override
  //  #TODO: почему bottom bar не требует указания preferred, а здесь нужно?
  // #TODO: не нравится, что ставится в компоненте, а не наследуется от дерева компонентов
  Size get preferredSize => const Size.fromHeight(80.0);
}
