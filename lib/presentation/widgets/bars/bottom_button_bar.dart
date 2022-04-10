import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:tasklist_lite/presentation/dialogs/error_dialog.dart';
import 'package:tasklist_lite/presentation/pages/reports_page.dart';
import 'package:tasklist_lite/presentation/pages/trunk_page.dart';

import '../../controllers/auth_controller.dart';

/// перечень всех пунктов меню в bottom_bar и в widescreen-slider`е
class MenuAction {
  final Widget? icon;
  final String? assetPath;
  final String caption;
  final VoidCallback callback;
  final String routeName;

  /// обязательно должен быть задан или icon или assetPath.
  /// Так пришлось делать, чтобы задавать цвет Asset`а внутри build,
  /// где есть buildContext. Потому что цвет из iconButton`а не меняет
  /// цвет иконки, если она задана через Asset.
  MenuAction(
      {this.icon,
      this.assetPath,
      required this.caption,
      required this.callback,
      required this.routeName});

  static final List<MenuAction> mainActionList = List.of({
    MenuAction(
        assetPath: "images/ibob_backpack_icon.png",
        caption: "Рюкзак",
        callback: () {
          GetDelegate routerDelegate = Get.find();
          routerDelegate.toNamed(TrunkPage.routeName);
        },
        routeName: "/" + TrunkPage.routeName),
    MenuAction(
        icon: Icon(Icons.event_available_outlined),
        caption: "Список задач",
        // список задач имеет корневой маршрут "/". Это значит, что он уже был
        // по-любому открыт, и нам надо делать pop, а не push, чтобы попасть туда.
        callback: () {
          GetDelegate routerDelegate = Get.find();
          routerDelegate.backUntil("/");
        },
        routeName: "/"),
    MenuAction(
        icon: Icon(Icons.insert_chart_outlined),
        caption: "Отчеты",
        callback: () {
          GetDelegate routerDelegate = Get.find();
          routerDelegate.toNamed(ReportsPage.routeName);
        },
        routeName: "/" + ReportsPage.routeName),
    MenuAction(
        icon: Icon(Icons.report_problem_outlined),
        caption: "Сообщить об ошибке",
        callback: () {
          showErrorReportDialog();
        },
        routeName: "/error"),
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
      Logger log = Logger(this.runtimeType.toString());
      GetDelegate routerDelegate = Get.find();
      return authController.authState.isAuthenticated.value
          ? BottomAppBar(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: MenuAction.mainActionList.map((e) {
                    return new IconButton(
                      onPressed: e.callback,
                      color: (routerDelegate.history.last.currentPage?.name ==
                              e.routeName)
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onPrimary,
                      icon: e.icon != null
                          ? e.icon!
                          : Image.asset(
                              e.assetPath!,
                              color: (routerDelegate
                                          .history.last.currentPage?.name ==
                                      e.routeName)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onPrimary,
                            ),
                      iconSize: IconTheme.of(context).size ?? 24,
                      tooltip: e.caption,
                    );
                  }).toList()))
          : Text("");
    });
  }
}
