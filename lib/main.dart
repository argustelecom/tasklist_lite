import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/pages/alternative_tasklist_page.dart';
import 'package:tasklist_lite/pages/notifications_page.dart';
import 'package:tasklist_lite/pages/settings_page.dart';
import 'package:tasklist_lite/pages/task_page.dart';
import 'package:tasklist_lite/pages/tasklist_page.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/task_repository.dart';
import 'package:tasklist_lite/theme/tasklist_theme_data.dart';

void main() {
  runApp(MyApp());
}

// #TODO: сделать автотесты
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // без встраивания Builder не работает, получаем unexpected null value
    // (внутри ApplicationState.of scope is null). Builder дает какой-то другой контекст по итогу, надо разобраться
    // https://stackguides.com/questions/69408608/flutter-dependoninheritedwidgetofexacttype-returns-null
    return ModelBinding(child: Builder(builder: (context) {
      return GetMaterialApp(
        title: 'Список задач исполнителя',
        initialRoute: "/",
        routes: {
          '/': (context) => TaskListPage(
                title: 'Список задач исполнителя',
              ),
          TaskListPage.routeName: (context) => TaskListPage(
                title: 'Список задач исполнителя',
              ),
          TaskPage.routeName: (context) =>
              TaskPage(title: "Детальное представление задачи"),
          NotificationsPage.routeName: (context) =>
              NotificationsPage(title: "Уведомления"),
          SettingsPage.routeName: (context) => SettingsPage(),
          AlternativeTaskListPage.routeName: (context) =>
              AlternativeTaskListPage(
                title: "Список задач исполнителя",
              ),
        },
        themeMode: ApplicationState.of(context).themeMode,
        theme: TaskListThemeData.lightThemeData.copyWith(
          platform: defaultTargetPlatform,
        ),
        localizationsDelegates: [GlobalMaterialLocalizations.delegate],
        supportedLocales: [const Locale('ru')],
        // чтобы таким образом добавить зависимости в контекст, пришлось делать не MaterialApp, а именно GetMaterialApp
        //https://medium.com/flutter-community/the-flutter-getx-ecosystem-dependency-injection-8e763d0ec6b9
        // #TODO: чтобы делать lazuPut, надо делать и отдельный класс-потомок Bindings (т.к. #lazyPut void, а BindingBuilder`у нужны экземпляры зависимостей)
        // а еще в dart низя делать анонимный класс (но можно анонимную функцию), что огорчает
        initialBinding: BindingsBuilder(
            () => {Get.put(TaskRepository()), Get.put(TaskFixtures())}),
        darkTheme: TaskListThemeData.darkThemeData.copyWith(
          platform: defaultTargetPlatform,
        ),
      );
    }));
  }
}
