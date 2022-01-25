import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/expansion_radio_tile.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/pages/login_page.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/state/auth_controller.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = 'settings';

  @override
  State<StatefulWidget> createState() {
    return new SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  // из-за него пришлось делать всю страницу stateful
  late TextEditingController _serverAddressEditingController;
  // а еще в этом state хранится набор suggestions для autocomplete`а
  // #TODO: обеспечить, чтобы эта коллекция переживала f5 в браузере
  List<String> serverAddressSuggestions = List.of({});

  @override
  void initState() {
    super.initState();
    _serverAddressEditingController = new TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ApplicationState applicationState = ApplicationState.of(context);
    _serverAddressEditingController.text = applicationState.serverAddress ?? "";
  }

  @override
  void dispose() {
    _serverAddressEditingController.dispose();
    super.dispose();
  }

  /// Вызывается, когда пользователь отредактировал адрес сервера.
  /// то есть, помимо onSubmitted в самом TextField`e, еще и при
  /// потере фокуса (потому что в вебе пользователь именно так и заканчивает
  /// редактирование. #TODO: не понятно, почему для этого пришлось изобретать
  /// костылик с Focus.onFocusChange, а TextField это из коробки не поддерживает.
  onServerAddressEdited() {
    ApplicationState applicationState = ApplicationState.of(context);
    if (_serverAddressEditingController.text !=
        applicationState.serverAddress) {
      // по итогам редактирования адрес сервера таки изменился
      // если пользователь аутентифицирован, надо его предупредить, а потом
      // завершить сеанс и отправить на страницу входа, чтобы подключиться к
      // серверу с новым адресом.
      AuthController authController = Get.find();
      if (authController.isAuthenticated) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Переподключение к серверу"),
              content: const Text("Адрес сервера был изменен. "
                  "\nВ случае подтверждения, потребуется переподключение к серверу. "
                  "\nСеанс завершится, будет отображена страница входа. Продолжить?"),
              actions: <Widget>[
                TextButton(
                  child: const Text('Отмена'),
                  onPressed: () {
                    _serverAddressEditingController.text =
                        applicationState.serverAddress ?? "";
                    Navigator.of(context).pop();
                    return;
                  },
                ),
                TextButton(
                  child: const Text('Продолжить'),
                  onPressed: () {
                    ApplicationState.update(
                        context,
                        applicationState.copyWith(
                            serverAddress:
                                _serverAddressEditingController.text));
                    // не забываем добавить новый текст в коллекцию suggestions
                    if (!serverAddressSuggestions
                        .contains(_serverAddressEditingController.text)) {
                      serverAddressSuggestions
                          .add(_serverAddressEditingController.text);
                    }
                    authController.logout();
                    // закроем открытый диалог и перекинем пользователя на страницу входа
                    NavigatorState navigatorState = Navigator.of(context);
                    navigatorState.pop();
                    navigatorState.pushNamed(LoginPage.routeName);
                  },
                ),
              ],
            );
          },
        );
      } else {
        // пользователь не был залогинен, поэтому просто заменим адрес в настройках на новый
        ApplicationState.update(
            context,
            applicationState.copyWith(
                serverAddress: _serverAddressEditingController.text));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReflowingScaffold(
      appBar: AppBar(
        title: new Text("Настройки"),
        leading: IconButton(
          icon: Icon(Icons.chevron_left_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          ExpansionTile(title: Text("Адрес сервера"), children: [
            Focus(
              onFocusChange: (value) {
                // здесь value имеет тип bool и говорит, обрели мы фокус (true) или потеряли (false)
                // #TODO: и почему все же нет такого у TextField из коробки? эх, еще учиться и учиться!
                if (!value) {
                  onServerAddressEdited();
                }
              },
              // TypeAheadField -- это одна из реализаций поля с autocompete (на вкус kostd, наиболее зрелая)
              child: TypeAheadField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _serverAddressEditingController,
                  onSubmitted: (value) {
                    // достаточно вызывать из onFocusChanged, т.к иначе это будет повторный вызов
                    //onServerAddressEdited();
                  },
                  decoration: InputDecoration(
                      labelText: "В формате <доменное имя(ip):порт>"),
                ),
                suggestionsCallback: (String pattern) {
                  return serverAddressSuggestions;
                },
                itemBuilder: (BuildContext context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (String suggestion) {
                  _serverAddressEditingController.text = suggestion;
                },
                noItemsFoundBuilder: (context) {
                  // иначе будет показан жирный No items found!
                  return Text("");
                },
              ),
            ),
          ]),
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
