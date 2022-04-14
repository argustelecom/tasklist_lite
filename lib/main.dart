import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:tasklist_lite/core/custom_navigator_observer.dart';
import 'package:tasklist_lite/injector.dart';
import 'package:tasklist_lite/presentation/controllers/auth_controller.dart';
import 'package:tasklist_lite/presentation/dialogs/error_dialog.dart';
import 'package:tasklist_lite/presentation/pages/about_page.dart';
import 'package:tasklist_lite/presentation/pages/comment_page.dart';
import 'package:tasklist_lite/presentation/pages/help_page.dart';
import 'package:tasklist_lite/presentation/pages/login_page.dart';
import 'package:tasklist_lite/presentation/pages/notifications_page.dart';
import 'package:tasklist_lite/presentation/pages/profile_page.dart';
import 'package:tasklist_lite/presentation/pages/reports_page.dart';
import 'package:tasklist_lite/presentation/pages/support_page.dart';
import 'package:tasklist_lite/presentation/pages/task_page.dart';
import 'package:tasklist_lite/presentation/pages/tasklist_page.dart';
import 'package:tasklist_lite/presentation/pages/trunk_page.dart';
import 'package:tasklist_lite/presentation/state/application_state.dart';

import 'config/theme/tasklist_theme_data.dart';
import 'presentation/controllers/common_dropdown_controller.dart';

void main() {
  initializeDependencies();
  Get.put(Get.createDelegate(navigatorObservers: [
    CustomNavigatorObserver(
      onPop: (route, previousRoute) {
        // _DropdownRoute<String> является приватным, поэтому проверить здесь через is не можем
        // route.settings.name у _DropdownRoute<String> равен null, тоже прекрасно
        // но воля к костылям несокрушима, поэтому:
        if (route.runtimeType.toString().startsWith("_DropdownRoute")) {
          CommonDropdownController commonDropdownController = Get.find();
          commonDropdownController.someDropdownTapped = false;
        }
      },
    )
  ]));
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((event) {
    // Простейшая подготовка отчета об ошибке:
    // писать последние 100 event`ов
    // при нажатии кнопки отчета об ошибке отркывать отправку почты на figaro-support@argustelecom.ru
    // скидывать туда 100 последних записей в логе и стек исключения.
    final String delim = " ";
    String message = event.sequenceNumber.toString() +
        delim +
        event.time.toString() +
        delim +
        event.level.toString() +
        delim +
        "[" +
        event.loggerName +
        "]" +
        delim +
        event.message +
        delim +
        (event.stackTrace != null ? event.stackTrace.toString() : "") +
        delim +
        (event.error != null ? event.error.toString() : "");
    print(message);
    lastMessages.add(message);
    if (lastMessages.length > 100) {
      lastMessages.removeAt(0);
    }
  });
  Logger log = Logger("main.dart");
  log.info("Инициализация выполнена. Запускается приложение Фигаро.");
  runApp(MyApp());
}

// kostd, 11.03.2022: переехали на навигацию 2.0 (она же navigator 2.0, nav2 или router).
// Т.к. навигация 1.0 позволяла все, кроме restore маршрутов после f5 в браузере. А наша основная цель -- веб,
// поэтому нам совершенно необходимо восстанавливать маршруты после f5. Для переезда на nav2 надо 1) отказаться от
// onGenerateRoute (теперь та же логика перебралась в описание списка pages в GetMaterialApp); 2) создавать GetMaterialApp
// не дефолтным конструктором, а его вариантом GetMaterialApp.router и 3) выполнять pushNamed и pop не через static-методы
// Navigator`а, а через (доступный через Get.find благодаря put`у здесь) GetDelegate (использовать методы toNamed и popRoute
// соответственно). Теперь после f5 работает как программный pop, так и браузерный back, причем используем штатные возможности
// библиотки Get, ничего дополнительно подключать не пришлось.
// #TODO: пока не работает deep linking в смысле параметров в url, параметры передаются не через url (см. например открытие
// TaskPage из карточки TaskCard). Пока вроде и не надо.
class MyApp extends StatelessWidget {
  final ApplicationState _applicationState = Get.find();

  final GetDelegate _routerDelegate = Get.find();

  /// эта странца может отображаться довольно часто, поэтому не хочется ее каждый раз пересоздавать.
  static final LoginPage _loginPage = LoginPage();

  /// карта всех маршрутов. Если сделал новую страничку, добавь маршрут к ней суда
  final Map<String, Widget> staticRoutes = {
    '/': TaskListPage(
      title: 'Фигаро: список задач',
    ),
    TaskListPage.routeName: TaskListPage(
      title: 'Фигаро: список задач',
    ),
    TaskPage.routeName: TaskPage(title: "Детальное представление задачи"),
    NotificationsPage.routeName: NotificationsPage(title: "Уведомления"),
    ProfilePage.routeName: ProfilePage(),
    LoginPage.routeName: _loginPage,
    SupportPage.routeName: SupportPage(),
    HelpPage.routeName: HelpPage(),
    AboutPage.routeName: AboutPage(),
    TrunkPage.routeName: TrunkPage(),
    ReportsPage.routeName: ReportsPage(),
    CommentPage.routeName: CommentPage()
  };

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      // что интересно, здесь GetBuilder объявлен снаружи GetMaterialApp, и все равно работает!
      return GetBuilder<AuthController>(
          init: AuthController(),
          builder: (authController) {
            return Obx(() {
              return GetMaterialApp.router(
                title: 'Фигаро',
                themeMode: _applicationState.themeMode.value,
                theme: TaskListThemeData.lightThemeData.copyWith(
                  platform: defaultTargetPlatform,
                ),
                routerDelegate: _routerDelegate,
                getPages: List.of(staticRoutes.entries.map((e) {
                  return GetPage(
                      // navigator2 (он же router) ожидает, что маршруты начинаются со слеша "/" (а navigator1 наоборот)
                      name: e.key.startsWith("/") ? e.key : "/" + e.key,
                      page: () {
                        return Obx(() {
                          if (!authController.authState.isAuthenticated.value) {
                            return _loginPage;
                          } else {
                            return e.value;
                          }
                        });
                      });
                })),
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  // Добавил из-за ошбики "A CupertinoLocalizations delegate that supports the ru locale was not found."
                  // по примеру из https://docs.flutter.dev/development/accessibility-and-localization/internationalization
                  GlobalCupertinoLocalizations.delegate
                ],
                supportedLocales: [const Locale('ru')],
                darkTheme: TaskListThemeData.darkThemeData.copyWith(
                  platform: defaultTargetPlatform,
                ),
              );
            });
          });
    });
  }
}
