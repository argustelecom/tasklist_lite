import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tasklist_lite/pages/settings_page.dart';

///*******************************************************
/// **           Нижняя панель с кнопками               **
/// ******************************************************
///
/// -- используется почти на каждой странице
/// -- обеспечивает базовую навигацию приложения
///
class BottomButtonBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
          IconButton(
            iconSize: IconTheme.of(context).size ?? 24,
            tooltip: 'Рюкзак',
            icon: const Icon(Icons.backpack_outlined),
            onPressed: () {},
          ),
          IconButton(
            iconSize: IconTheme.of(context).size ?? 24,
            tooltip: 'Календарь',
            //#TODO: ничего что названия иконок противоречат их смыслу? тем
            // самым отклоняемся от best practice "использовать по прямому назначению"
            icon: const Icon(Icons.event_available_outlined),
            onPressed: () {},
          ),
          IconButton(
            iconSize: IconTheme.of(context).size ?? 24,
            tooltip: 'Отчеты',
            icon: const Icon(Icons.insert_chart_outlined),
            onPressed: () {},
          ),
          IconButton(
            iconSize: IconTheme.of(context).size ?? 24,
            tooltip: 'Соообщить об ошибке',
            icon: const Icon(Icons.report_problem_outlined),
            onPressed: () {},
          ),
          IconButton(
            iconSize: IconTheme.of(context).size ?? 24,
            tooltip: 'Настройки',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(
                context,
                SettingsPage.routeName,
              );
            },
          ),
        ]));
  }
}
