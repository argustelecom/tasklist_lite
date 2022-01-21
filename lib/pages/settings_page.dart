import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tasklist_lite/crazylib/expansion_radio_tile.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';

class SettingsPage extends StatelessWidget {
  static const String routeName = 'settings';

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    ApplicationState applicationState = ApplicationState.of(context);
    return ReflowingScaffold(
      appBar: AppBar(
        title: new Text("Настройки"),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          ExpansionRadioTile<ThemeMode>(
              title: Text("Визуальная тема"),
              selectedObject: ApplicationState.of(context).themeMode,
              optionsMap: LinkedHashMap.of({
                ThemeMode.light: "Светлая",
                ThemeMode.dark: "Темная",
                ThemeMode.system: "По умолчанию"
              }),
              onChanged: (ThemeMode? newValue) {
                ApplicationState.update(context,
                    ApplicationState.of(context).copyWith(themeMode: newValue));
              }),
          ExpansionRadioTile<CurrentTaskFixture>(
              title: Text("Источник данных"),
              selectedObject: ApplicationState.of(context).currentTaskFixture,
              optionsMap: LinkedHashMap.of({
                CurrentTaskFixture.firstFixture: "Первая фикстура",
                CurrentTaskFixture.secondFixture: "Вторая фикстура",
                CurrentTaskFixture.thirdFixture: "Третья фикстура",
                CurrentTaskFixture.noneFixture:
                    "Фикстура не выбрана (удаленный источник данных)"
              }),
              onChanged: (CurrentTaskFixture? newValue) {
                ApplicationState.update(
                    context,
                    ApplicationState.of(context)
                        .copyWith(currentTaskFixture: newValue));
              }),
        ],
      ),
    );
  }
}
