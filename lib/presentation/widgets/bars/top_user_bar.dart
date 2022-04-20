import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/presentation/controllers/auth_controller.dart';
import 'package:tasklist_lite/presentation/controllers/notification_controller.dart';
import 'package:tasklist_lite/presentation/pages/notifications_page.dart';
import 'package:tasklist_lite/presentation/pages/profile_page.dart';

class ProfileIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.account_circle_outlined),
        tooltip: "Профиль",
        onPressed: () {
          GetDelegate routerDelegate = Get.find();
          routerDelegate.toNamed(ProfilePage.routeName);
        });
  }
}

class UserInfoBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<AuthController>(builder: (authController) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              authController.authState.userInfo.value == null
                  ? ""
                  : authController.authState.userInfo.value!.userName + ",",
              key: ValueKey('$TopUserBar' + '_username')),
          Text(authController.authState.userInfo.value == null
              ? ""
              : authController.authState.userInfo.value!.homeRegionName),
        ],
      );
    });
  }
}

class NotificationsIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Вызваем NotificationController, чтобы взять у него инфу по наличию уведомлений
    return GetBuilder<NotificationController>(
        init: NotificationController(),
        builder: (notificationController) {
          return Padding(
            padding: EdgeInsets.only(top: 14),
            child: Stack(
              children: [
                Positioned(
                  child: IconButton(
                    iconSize: 36, //IconTheme.of(context).size ?? 24,
                    tooltip: 'Уведомления',
                    // Если есть, то колокольчик звонит, а если нет ...
                    icon: Icon(Icons.notifications_outlined),
                    onPressed: () {
                      GetDelegate routerDelegate = Get.find();
                      routerDelegate.toNamed(NotificationsPage.routeName);
                    },
                  ),
                ),
                notificationController.aliveNotifications.length != 0
                    ? Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${notificationController.aliveNotifications.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          );
        });
  }
}

class LogoutIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return IconButton(
        iconSize: IconTheme.of(context).size ?? 24,
        tooltip: 'Выход',
        icon: const Icon(Icons.exit_to_app_outlined),
        onPressed: () {
          authController.logout();
        },
      );
    });
  }
}

class TopUserBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
          child: AppBar(
            leading: ProfileIconButton(),
            titleSpacing: 0.0,
            toolbarHeight: 100,
            title: UserInfoBar(),
            actions: [
              NotificationsIconButton(),
            ],
          ));
    });
  }

  @override
  //  #TODO: почему bottom bar не требует указания preferred, а здесь нужно?
  // #TODO: не нравится, что ставится в компоненте, а не наследуется от дерева компонентов
  Size get preferredSize => const Size.fromHeight(80.0);
}
