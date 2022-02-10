import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/pages/settings_page.dart';
import 'package:tasklist_lite/state/auth_controller.dart';

/// перечень всех пунктов меню в bottom_bar и в widescreen-slider`е
class MenuAction {
  final IconData iconData;
  final String caption;
  final VoidCallback callback;

  static const settingsCaption = "Профиль";
  MenuAction(
      {required this.iconData, required this.caption, required this.callback});

  // в callback`ах не может использовать Navigator.pushNamed, т.к. здесь нет buildContext`а.
  // Но тут нас выручает Get с возможностью навигации без контекста
  static final List<MenuAction> mainActionList = List.of({
    MenuAction(
        iconData: Icons.backpack_outlined, caption: "Рюкзак", callback: () {}),
    MenuAction(
        iconData: Icons.event_available_outlined,
        caption: "Календарь",
        callback: () {}),
    MenuAction(
        iconData: Icons.insert_chart_outlined,
        caption: "Отчеты",
        callback: () {}),
    MenuAction(
        iconData: Icons.report_problem_outlined,
        caption: "Сообщить об ошибке",
        callback: () {}),
    MenuAction(
        iconData: Icons.settings_outlined,
        caption: settingsCaption,
        callback: () => {Get.toNamed(ProfilePage.routeName)}),
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
    return BottomAppBar(child: GetX<AuthController>(builder: (authController) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: MenuAction.mainActionList
              .map((e) => new IconButton(
                    // если не залогинились, доступны только настройки
                    // The icon is disabled if [onPressed] is null.
                    onPressed: authController.isAuthenticated ||
                            (e.caption == MenuAction.settingsCaption)
                        ? e.callback
                        : null,
                    icon: Icon(e.iconData),
                    iconSize: IconTheme.of(context).size ?? 24,
                    tooltip: e.caption,
                  ))
              .toList());
    }));
  }
}
