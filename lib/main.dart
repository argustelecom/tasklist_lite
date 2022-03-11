import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/auth/auth_service.dart';
import 'package:tasklist_lite/custom_navigator_observer.dart';
import 'package:tasklist_lite/pages/about_app_page.dart';
import 'package:tasklist_lite/pages/help_page.dart';
import 'package:tasklist_lite/pages/login_page.dart';
import 'package:tasklist_lite/pages/notifications_page.dart';
import 'package:tasklist_lite/pages/profile_page.dart';
import 'package:tasklist_lite/pages/reports_page.dart';
import 'package:tasklist_lite/pages/support_page.dart';
import 'package:tasklist_lite/pages/task_page.dart';
import 'package:tasklist_lite/pages/tasklist_page.dart';
import 'package:tasklist_lite/pages/trunk_page.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/state/auth_controller.dart';
import 'package:tasklist_lite/tasklist/fixture/history_events_fixtures.dart';
import 'package:tasklist_lite/tasklist/fixture/notification_fixtures.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/history_events_repository.dart';
import 'package:tasklist_lite/tasklist/idle_time_reason_repository.dart';
import 'package:tasklist_lite/tasklist/notification_repository.dart';
import 'package:tasklist_lite/tasklist/task_repository.dart';
import 'package:tasklist_lite/theme/tasklist_theme_data.dart';

import 'local_storage/local_storage_service.dart';
import 'state/common_dropdown_controller.dart';

void main() {
  // некоторые "бины" должны быть созданы еще до того, как отработает initialBinding у MaterialApp
  Get.put(ApplicationState());
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
    SupportPage.routeName: SupportPage(title: "Служба поддержки"),
    HelpPage.routeName: HelpPage(title: "Помощь"),
    AboutAppPage.routeName: AboutAppPage(title: "О приложении"),
    TrunkPage.routeName: TrunkPage(),
    ReportsPage.routeName: ReportsPage(),
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
                // чтобы таким образом добавить зависимости в контекст, пришлось делать не MaterialApp, а именно GetMaterialApp
                //https://medium.com/flutter-community/the-flutter-getx-ecosystem-dependency-injection-8e763d0ec6b9
                // #TODO: чтобы делать lazuPut, надо делать и отдельный класс-потомок Bindings (т.к. #lazyPut void, а BindingBuilder`у нужны экземпляры зависимостей)
                // а еще в dart низя делать анонимный класс (но можно анонимную функцию), что огорчает
                initialBinding: BindingsBuilder(() => {
                      Get.put(TaskRepository()),
                      Get.put(TaskFixtures()),
                      Get.put(AuthService()),
                      Get.put(NotificationRepository()),
                      Get.put(NotificationFixtures()),
                      Get.put(IdleTimeReasonRepository()),
                      Get.put(HistoryEventsFixtures()),
                      Get.put(HistoryEventRepository()),
                      Get.put(CommonDropdownController()),
                      Get.put(LocalStorageService()),
                    }),
                darkTheme: TaskListThemeData.darkThemeData.copyWith(
                  platform: defaultTargetPlatform,
                ),
              );
            });
          });
    });
  }
}
