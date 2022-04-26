import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_language_fonts/google_language_fonts.dart';
import 'package:tasklist_lite/presentation/controllers/auth_controller.dart';
import 'package:tasklist_lite/presentation/controllers/common_dropdown_controller.dart';
import 'package:tasklist_lite/presentation/state/application_state.dart';
import 'package:tasklist_lite/presentation/widgets/butttons/crazy_button.dart';
import 'package:tasklist_lite/presentation/widgets/butttons/dropdown_button.dart';
import 'package:tasklist_lite/presentation/widgets/crazy_progress_dialog.dart';
import 'package:tasklist_lite/presentation/widgets/reflowing_scaffold.dart';

import '../state/auth_state.dart';
import '../widgets/figaro_logo.dart';
import '../widgets/text_field.dart';
import '../widgets/type_ahead_field.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = "/login";

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  TextEditingController _loginEditingController = new TextEditingController();
  TextEditingController _passwordEditingController =
      new TextEditingController();
  TextEditingController _serverAddressEditingController =
      new TextEditingController();

  String? _selectedServer;

  // набор suggestions для autocomplete`а
  List<String> _serverAddressSuggestions = List.of({});

  static const _serverAddressSuggestionsStorageKey =
      "serverAddressSuggestionsStorageKey";

  // вводим константы, т.к. на форме авторизации поля имеют нестандартный вид
  static const double _fieldHeight = 50;
  static const double _fieldBorderRadius = 15;
  static const EdgeInsets _fieldPadding = EdgeInsets.zero;

  bool _passwordVisible = false;

  ApplicationState _applicationState = Get.find();
  AuthState _authState = Get.find();

  @override
  void initState() {
    super.initState();

    _authState.serverAddressSuggestions.listen((onData) {
      _serverAddressSuggestions = onData ?? List.of({});
    });

    _authState.serverAddress.listen((onData) {
      if (_selectedServer == null) {
        _serverAddressEditingController.text = onData ?? "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return GetBuilder<CommonDropdownController>(
        builder: (commonDropdownController) {
      return GetBuilder<AuthController>(builder: (authController) {
        return ReflowingScaffold(
            body: Align(
                alignment: Alignment.center,
                child: Row(children: [
                  Expanded(
                      child: ListView(shrinkWrap: true, children: [
                    AnimatedLogo(
                      assetName: "images/logo_figaro.png",
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text("ФИГАРО",
                          style: // Arsenal из google_fonts не умеет кириллицу, пришлось из google_language_fonts
                              CyrillicFonts.arsenal(fontSize: 30),
                          textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Obx(
                        () {
                          return Container(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: [
                                    Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    _fieldBorderRadius))),
                                        child: CustomTextField(
                                            controller: _loginEditingController,
                                            hint: "Логин",
                                            height: _fieldHeight,
                                            padding: _fieldPadding,
                                            borderRadius: _fieldBorderRadius,
                                            noBorder: true)),
                                    Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    _fieldBorderRadius))),
                                        child: CustomTextField(
                                            controller:
                                                _passwordEditingController,
                                            hint: "Пароль",
                                            height: _fieldHeight,
                                            padding: _fieldPadding,
                                            borderRadius: _fieldBorderRadius,
                                            noBorder: true,
                                            obscureText: true)),
                                    Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    _fieldBorderRadius))),
                                        child: CustomDropDownButton<String>(
                                          hint: "Сервер",
                                          height: _fieldHeight,
                                          value: _selectedServer,
                                          padding: _fieldPadding,
                                          borderRadius: _fieldBorderRadius,
                                          noBorder: true,
                                          onTap: () {
                                            commonDropdownController
                                                .someDropdownTapped = true;
                                          },
                                          onChanged: (String? value) {
                                            setState(() {
                                              Map<String?, String>
                                                  possibleServers =
                                                  _applicationState
                                                      .possibleServers;
                                              _selectedServer = value;

                                              _serverAddressEditingController
                                                  .text = possibleServers[
                                                      _selectedServer] ??
                                                  _serverAddressEditingController
                                                      .text;
                                            });
                                          },
                                          itemsList: List.of(_applicationState
                                              .possibleServers.keys),
                                          selectedItemBuilder:
                                              (BuildContext context) {
                                            return _applicationState
                                                .possibleServers.keys
                                                .map<Widget>((String item) {
                                              return Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "Сервер $item",
                                                  ));
                                            }).toList();
                                          },
                                        )),
                                    Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    _fieldBorderRadius))),
                                        child: CustomTypeAheadField(
                                            controller:
                                                _serverAddressEditingController,
                                            hint: "Адрес сервера",
                                            height: _fieldHeight,
                                            padding: _fieldPadding,
                                            borderRadius: _fieldBorderRadius,
                                            noBorder: true,
                                            suggestionsCallback:
                                                (String pattern) {
                                              return _serverAddressSuggestions
                                                  .where((element) => element
                                                      .startsWith(pattern));
                                            },
                                            itemBuilder: (BuildContext context,
                                                suggestion) {
                                              return ListTile(
                                                title: Text(suggestion),
                                              );
                                            },
                                            onSelected: (suggestion) {
                                              _serverAddressEditingController
                                                  .text = suggestion;
                                            })),
                                    Tooltip(
                                      textStyle: TextStyle(fontSize: 16),
                                      waitDuration: Duration(seconds: 2),
                                      decoration: BoxDecoration(
                                          color: themeData.cardColor,
                                          border: Border.all(width: 1)),
                                      message:
                                          "Можно указать любое имя пользователя и пароль. "
                                          "\nБудет осуществлен вход без подключения к серверу, "
                                          "\nбудут доступны демонстрационные данные. ",
                                      key: ValueKey('demo_mode'),
                                      child: Obx(() {
                                        // получается не как в макете, сам чекбокс все же имеет небольшой отступ, а в макете без отступа
                                        // если это не прокатит, то надо If the way CheckboxListTile pads and positions its elements isn't quite
                                        // what you're looking for, you can create custom labeled checkbox widgets by
                                        // combining [Checkbox] with other widgets, such as [Text], [Padding] and
                                        // [InkWell]. (см. каменты в checkbox_list_tile)
                                        return CheckboxListTile(
                                          contentPadding: EdgeInsets.zero,
                                          value: _applicationState
                                              .inDemonstrationMode.value,
                                          onChanged: (value) {
                                            if (value != null) {
                                              _applicationState
                                                  .inDemonstrationMode
                                                  .value = value;
                                            }
                                          },
                                          title: Text(
                                            "Демо-режим",
                                          ),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                        );
                                      }),
                                    ),
                                    Row(
                                      children: [
                                        CrazyButton(
                                          title: "Войти",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 18),
                                          key: ValueKey('login_button'),
                                          onPressed: () {
                                            /// пополняем коллекцию suggestions

                                            if (!_serverAddressSuggestions.contains(
                                                    _serverAddressEditingController
                                                        .text) &&
                                                _serverAddressEditingController
                                                    .text.isNotEmpty) {
                                              setState(() {
                                                _serverAddressSuggestions.add(
                                                    _serverAddressEditingController
                                                        .text);
                                                // но пополняем не бесконечно, а только до пяти возможных
                                                // вариантов, чтобы не пухла
                                                if (_serverAddressSuggestions
                                                        .length >
                                                    5) {
                                                  _serverAddressSuggestions
                                                      .removeAt(0);
                                                }
                                              });
                                            }

                                            _authState.serverAddressSuggestions
                                                    .value =
                                                _serverAddressSuggestions;

                                            /// логинимся
                                            /// Если пользователь разлогинился не с домашней странички(а, например, со страницы профиля),
                                            /// надо его возвращать туда, откуда он разлогинился. Но это произойдет само, т.к.
                                            /// authState у нас теперь реактивный, а при логауте url мы не меняем
                                            asyncShowProgressIndicatorOverlay(
                                              asyncFunction: () {
                                                return authController.login(
                                                    _applicationState
                                                        .inDemonstrationMode
                                                        .value,
                                                    _loginEditingController
                                                        .text,
                                                    _passwordEditingController
                                                        .text,
                                                    _serverAddressEditingController
                                                        .text);
                                              },
                                            );
                                          },
                                          padding:
                                              EdgeInsets.symmetric(vertical: 8),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 32, top: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            authController.errorText ?? "",
                                            style: TextStyle(
                                              // #TODO: из error style надо брать цвет
                                              color: Colors.red,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          );
                        },
                      ),
                    ),
                  ]))
                ])));
      });
    });
  }
}
