import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/expansion_radio_tile.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/pages/help_page.dart';
import 'package:tasklist_lite/pages/login_page.dart';
import 'package:tasklist_lite/pages/support_page.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/state/auth_controller.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/user_info.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = 'profile';

  @override
  State<StatefulWidget> createState() {
    return new ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
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
    _serverAddressEditingController.text = applicationState.serverAddress;
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
                        applicationState.serverAddress;
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
        // не забываем добавить новый текст в коллекцию suggestions
        if (!serverAddressSuggestions
            .contains(_serverAddressEditingController.text)) {
          serverAddressSuggestions.add(_serverAddressEditingController.text);
        }
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
    //Отступ карточки блока
    EdgeInsets paddingSettingBlock =
        EdgeInsets.only(left: 15, right: 15, bottom: 2);

    return ReflowingScaffold(
        appBar: AppBar(
          title: new Text("Профиль"),
          leading: IconButton(
            icon: Icon(Icons.chevron_left_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
            shrinkWrap: true,
            children: [
              GetX<AuthController>(builder: (authController) {
                UserInfo userInfo = authController.userInfo as UserInfo;
                if (userInfo == null) {
                  return SizedBox(
                    child: Text("не полученны данные"),
                  );
                } else {
                  LinkedHashSet<String> attrGroups = userInfo.getAttrGroups();
                  return SizedBox(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: attrGroups.length,
                          itemBuilder: (BuildContext context, int index) {
                            return AttrGroup(
                                userInfo: userInfo,
                                attrGroup: attrGroups.elementAt(index));
                          }));
                }
              }),
              Padding(
                  padding: EdgeInsets.only(left: 17, right: 15, bottom: 10, top: 4),
                  child: Text("Настройки приложения",
                      style: TextStyle(fontSize: 18))),
              Padding(
                  padding: paddingSettingBlock,
                  child: Card(
                      elevation: 3,
                      child: SizedBox(
                          height: 50.0,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text(
                                      "Ночной режим",
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Transform.scale(
                                        scale: 1.1,
                                        child: CupertinoSwitch(
                                            activeColor:
                                                Color.fromRGBO(251, 194, 47, 1),
                                            value: ApplicationState.of(context)
                                                    .themeMode ==
                                                ThemeMode.dark,
                                            onChanged: (value) {
                                              if (value) {
                                                ApplicationState.update(
                                                    context,
                                                    ApplicationState.of(context)
                                                        .copyWith(
                                                            themeMode: ThemeMode
                                                                .dark));
                                              } else {
                                                ApplicationState.update(
                                                    context,
                                                    ApplicationState.of(context)
                                                        .copyWith(
                                                            themeMode: ThemeMode
                                                                .light));
                                              }
                                            })))
                              ])))),
              Padding(
                  padding: paddingSettingBlock,
                  child: Card(
                      elevation: 3,
                      child: SizedBox(
                          height: 50.0,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text(
                                      "Запоминать избранные работы",
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Transform.scale(
                                        scale: 1.1,
                                        child:
                                            //Переклбчатель задизайблен, так как
                                            //доработка "Запоминать избранные работы"
                                            //будет в следующих этапах
                                            CupertinoSwitch(
                                          value: false,
                                          onChanged: null,
                                          activeColor:
                                              Color.fromRGBO(251, 194, 47, 1),
                                        )))
                              ])))),
              Padding(
                  padding: paddingSettingBlock,
                  child: Card(
                      elevation: 3,
                      child: ExpansionTile(
                          title: Text("Адрес сервера"),
                          children: [
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
                                      labelText:
                                          "В формате <доменное имя(ip):порт>"),
                                ),
                                suggestionsCallback: (String pattern) {
                                  return serverAddressSuggestions.where(
                                      (element) => element.startsWith(pattern));
                                },
                                itemBuilder:
                                    (BuildContext context, suggestion) {
                                  return ListTile(
                                    title: Text(suggestion),
                                  );
                                },
                                onSuggestionSelected: (String suggestion) {
                                  _serverAddressEditingController.text =
                                      suggestion;
                                },
                                noItemsFoundBuilder: (context) {
                                  // иначе будет показан жирный No items found!
                                  return Text("");
                                },
                              ),
                            ),
                          ]))),
              Padding(
                  padding: paddingSettingBlock,
                  child: Card(
                      elevation: 3,
                      child: ExpansionRadioTile<CurrentTaskFixture>(
                          title: Text("Источник данных"),
                          selectedObject:
                              ApplicationState.of(context).currentTaskFixture,
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
                          }))),
              Padding(
                  padding: paddingSettingBlock,
                  child: Card(
                      elevation: 3,
                      child: SizedBox(
                          height: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Text("Служба поддержки")),
                              IconButton(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 15),
                                  iconSize: 30,
                                  tooltip: 'Служба поддержки',
                                  icon:
                                      const Icon(Icons.chevron_right_outlined),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, SupportPage.routeName);
                                  })
                            ],
                          )))),
              Padding(
                  padding: paddingSettingBlock,
                  child: Card(
                      elevation: 3,
                      child: SizedBox(
                          height: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Text("Помощь")),
                              IconButton(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 15),
                                  iconSize: 30,
                                  tooltip: 'Помощь',
                                  icon:
                                      const Icon(Icons.chevron_right_outlined),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, HelpPage.routeName);
                                  })
                            ],
                          )))),
              Padding(
                  padding: paddingSettingBlock,
                  child: Card(
                      elevation: 3,
                      child: SizedBox(
                        height: 50.0,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Text("О приложении")),
                              //TODO: Значение версии нужно брать из настройки.
                              Padding(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Text("0.0.1",
                                      style: TextStyle(color: Colors.grey)))
                            ]),
                      )))
            ]));
  }
}

// Вывод группы параметров
class AttrGroup extends StatelessWidget {
  final UserInfo userInfo;
  final String attrGroup;

  const AttrGroup({Key? key, required this.userInfo, required this.attrGroup})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LinkedHashMap<String, Object?> attribValuesByGroup =
        userInfo.getAttrValuesByGroup(attrGroup);

    return Column(children: [
      Container(
          padding: EdgeInsets.only(left: 17, right: 15, top: 4),
          alignment: Alignment.centerLeft,
          child: Text(attrGroup, style: TextStyle(fontSize: 18))),
      Padding(
          padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          child: Card(
              elevation: 3,
              color: context.theme.cardColor,
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: attribValuesByGroup.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AttribValueColumn(
                        attribValue:
                            attribValuesByGroup.entries.elementAt(index));
                  })))
    ]);
  }
}

// Вывод стобцом Параметр: Значение
class AttribValueColumn extends StatelessWidget {
  final MapEntry<String, Object?> attribValue;

  const AttribValueColumn({Key? key, required this.attribValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String attrKey = attribValue.key;
    String attrValue =
        (attribValue.value == null) ? "" : attribValue.value.toString();

    return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 5),
        child: Column(children: [
          Container(
              alignment: Alignment.centerLeft,
              child: Text("$attrKey:",
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF646363),
                      fontWeight: FontWeight.normal))),
          Container(
              alignment: Alignment.centerLeft,
              child: Text(attrValue, style: TextStyle(fontSize: 16))),
        ]));
  }
}
