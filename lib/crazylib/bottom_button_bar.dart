import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/pages/reports_page.dart';
import 'package:tasklist_lite/pages/trunk_page.dart';

import '../pages/tasklist_page.dart';
import '../state/auth_controller.dart';

/// перечень всех пунктов меню в bottom_bar и в widescreen-slider`е
class MenuAction {
  final Widget icon;
  final String caption;
  final VoidCallback callback;

  MenuAction(
      {required this.icon, required this.caption, required this.callback});

  // в callback`ах не может использовать Navigator.pushNamed, т.к. здесь нет buildContext`а.
  // Но тут нас выручает Get с возможностью навигации без контекста
  static final List<MenuAction> mainActionList = List.of({
    MenuAction(
        icon: Image.asset("images/ibob_backpack_icon.png"),
        caption: "Рюкзак",
        callback: () {
          Get.toNamed(TrunkPage.routeName);
        }),
    MenuAction(
        icon: Icon(Icons.event_available_outlined),
        caption: "Список задач",
        // список задач имеет корневой маршрут "/". Это значит, что он уже был
        // по-любому открыт, и нам надо делать pop, а не push, чтобы попасть туда.
        callback: () {
          Get.until(
            (route) {
              return ((Get.currentRoute == "/") ||
                  (Get.currentRoute == "/" + TaskListPage.routeName));
            },
          );
        }),
    MenuAction(
        icon: Icon(Icons.insert_chart_outlined),
        caption: "Отчеты",
        callback: () {
          Get.toNamed(ReportsPage.routeName);
        }),
    MenuAction(
        icon: Icon(Icons.report_problem_outlined),
        caption: "Сообщить об ошибке",
        callback: () {}),
  });
}

///*******************************************************
/// **           Нижняя панель с кнопками               **
/// ******************************************************
///
/// -- используется почти на каждой странице
/// -- обеспечивает базовую навигацию приложения
/// -- если страница компонуется на широком экране, то эта
///   панель должна быть заменена на WideScreenNavigationDrawer
class BottomButtonBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<AuthController>(builder: (authController) {
      return authController.authState.isAuthenticated.value
          ? BottomAppBar(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: MenuAction.mainActionList
                      .map((e) => new IconButton(
                            // если не залогинились, доступны только настройки
                            // The icon is disabled if [onPressed] is null.
                            onPressed: e.callback,
                            icon: e.icon,
                            iconSize: IconTheme.of(context).size ?? 24,
                            tooltip: e.caption,
                          ))
                      .toList()))
          : Text("");
    });
  }
}
