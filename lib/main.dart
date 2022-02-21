import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/auth/auth_service.dart';
import 'package:tasklist_lite/custom_navigator_observer.dart';
import 'package:tasklist_lite/pages/about_app_page.dart';
import 'package:tasklist_lite/pages/alternative_tasklist_page.dart';
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

import 'state/common_dropdown_controller.dart';

void main() {
  runApp(MyApp());
}

// #TODO: сделать автотесты
class MyApp extends StatelessWidget {
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
    AlternativeTaskListPage.routeName: AlternativeTaskListPage(
      title: "Список задач исполнителя",
    ),
    LoginPage.routeName: LoginPage(),
    SupportPage.routeName: SupportPage(title: "Служба поддержки"),
    HelpPage.routeName: HelpPage(title: "Помощь"),
    AboutAppPage.routeName: AboutAppPage(title: "О приложении"),
    TrunkPage.routeName: TrunkPage(),
    ReportsPage.routeName: ReportsPage(),
  };

  // то же самое (то есть не пустить на страницу, а отправить на форму входа, если не залогинен)
  // в приличном обществе делают через route guard`ы. Например, https://blog.logrocket.com/implementing-route-guards-flutter-web-apps/
  // Но в этом примере не нравится генерация маршрутов (от кодогенерации хочется держаться подальше, если можно).
  // Также по фразе route guard ищется много примеров, но в среднем они не сильно лучше решения здесь.
  // Это вовсе не значит, что kostd некуда совершенствоваться. Напротив, целины еще много.
  Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    AuthController authController = Get.find();
    return MaterialPageRoute(
      builder: (context) => Obx(() {
        if (authController.isAuthenticated ||
            // без аутентификации можно попасть на страницу настроек
            routeSettings.name == ProfilePage.routeName) {
          return staticRoutes[routeSettings.name] ?? staticRoutes['/']!;
        } else {
          return LoginPage();
        }
      }),
      settings: routeSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    // без встраивания Builder не работает, получаем unexpected null value
    // (внутри ApplicationState.of scope is null). Builder дает какой-то другой контекст по итогу, надо разобраться
    // https://stackguides.com/questions/69408608/flutter-dependoninheritedwidgetofexacttype-returns-null
    return ModelBinding(
      child: Builder(builder: (context) {
        // что интересно, здесь GetBuilder объявлен снаружи GetMaterialApp, и все равно работает!
        return GetBuilder<AuthController>(
            init: AuthController(),
            builder: (authController) {
              return GetMaterialApp(
                title: 'Фигаро',
                themeMode: ApplicationState.of(context).themeMode,
                theme: TaskListThemeData.lightThemeData.copyWith(
                  platform: defaultTargetPlatform,
                ),
                // к сожалению,  пришлось отказаться от перечисления маршрутов здесь, т.к. иначе не вызывается onGenerateRoute,
                // в которой хитрая логика редиректа на страницу входа в систему
                onGenerateRoute: onGenerateRoute,
                // случай onUnknown тоже будет корректно обработан внутри onGenerateRoute
                onUnknownRoute: onGenerateRoute,
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
                      //          Get.put(TaskListController()),
                      //          Get.put(HistoryEventController())
                    }),
                darkTheme: TaskListThemeData.darkThemeData.copyWith(
                  platform: defaultTargetPlatform,
                ),
                navigatorObservers: [
                  CustomNavigatorObserver(
                    onPop: (route, previousRoute) {
                      // _DropdownRoute<String> является приватным, поэтому проверить здесь через is не можем
                      // route.settings.name у _DropdownRoute<String> равен null, тоже проекрасно
                      // но воля к костылям несокрушима, поэтому:
                      if (route.runtimeType
                          .toString()
                          .startsWith("_DropdownRoute")) {
                        CommonDropdownController commonDropdownController =
                            Get.find();
                        commonDropdownController.someDropdownTapped = false;
                      }
                    },
                  )
                ],
              );
            });
      }),
    );
  }
}
