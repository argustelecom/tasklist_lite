import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:google_language_fonts/google_language_fonts.dart';
import 'package:tasklist_lite/crazylib/crazy_button.dart';
import 'package:tasklist_lite/crazylib/dropdown_button.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/state/auth_controller.dart';
import 'package:tasklist_lite/state/common_dropdown_controller.dart';

import '../local_storage/local_storage_service.dart';
import '../state/auth_state.dart';

// #TODO: если делать отдельным виджетом, стоит параметризовать размеры, кривую анимации, длительность
class AnimatedLogo extends StatefulWidget {
  final String assetName;

  AnimatedLogo({required this.assetName});
  @override
  State<StatefulWidget> createState() {
    return AnimatedLogoState(assetName: this.assetName);
  }
}

class AnimatedLogoState extends State<AnimatedLogo> {
  final String assetName;

  bool tapped = false;

  AnimatedLogoState({required this.assetName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          tapped = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.bounceOut,
        onEnd: () {
          setState(() {
            tapped = false;
          });
        },
        height: tapped ? 220 : 180,
        width: tapped ? 220 : 180,
        child: Image.asset(
          // внимательней, хотсвап не подцепляет изменения в asset, надо делать полную пересборку
          assetName,
          bundle: rootBundle,
        ),
      ),
    );
  }
}

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

  ApplicationState _applicationState = Get.find();
  AuthState _authState = Get.find();

  InputDecoration fieldDecoration(BuildContext context, String text) {
    ThemeData themeData = Theme.of(context);
    return InputDecoration(
        labelText: text,
        floatingLabelStyle: TextStyle(color: themeData.colorScheme.primary),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: themeData.colorScheme.primary)));
  }

  @override
  void initState() {
    super.initState();

    LocalStorageService.readList(_serverAddressSuggestionsStorageKey)
        .then((value) => _serverAddressSuggestions = value,
            onError: (Object error, StackTrace stackTrace) {
      // #TODO: завести нормальный лог вместо print. И вообще, хорошо бы спрятать обработку
      // ошибок в UserSecureStorageService
      print(
          "ошибка чтения serverAddressSuggestions из хранилища: $error, stack = $stackTrace");
    });

    _authState.serverAddress.listen((value) {
      if (_selectedServer == null) {
        _serverAddressEditingController.text = value ?? "";
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
          body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedLogo(
              assetName: "images/logo_figaro.png",
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text("ФИГАРО",
                  style: // Arsenal из google_fonts не умеет кириллицу, пришлось из google_language_fonts
                      CyrillicFonts.arsenal(fontSize: 30)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        TextField(
                            controller: _loginEditingController,
                            cursorColor: themeData.colorScheme.primary,
                            // #TODO: "Имя пользователя" как-то посолидней, чем "логин". Обсудить с Лизой
                            decoration: fieldDecoration(context, "Логин")),
                        TextField(
                            controller: _passwordEditingController,
                            cursorColor: themeData.colorScheme.primary,
                            obscureText: true,
                            decoration: fieldDecoration(context, "Пароль")),
                        CustomDropDownButton<String>(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                          hint: "Сервер",
                          value: _selectedServer,
                          borderColor:
                              commonDropdownController.someDropdownTapped
                                  ? themeData.colorScheme.primary
                                  // по дефолту там Black54
                                  : null,
                          dropdownColor: themeData.colorScheme.primary,
                          onTap: () {
                            commonDropdownController.someDropdownTapped = true;
                          },
                          onChanged: (String? value) {
                            setState(() {
                              Map<String?, String> possibleServers =
                                  _applicationState.possibleServers;
                              _selectedServer = value;

                              _serverAddressEditingController.text =
                                  possibleServers[_selectedServer] ??
                                      _serverAddressEditingController.text;
                            });
                          },
                          itemsList:
                              List.of(_applicationState.possibleServers.keys),
                          selectedItemBuilder: (BuildContext context) {
                            return _applicationState.possibleServers.keys
                                .map<Widget>((String item) {
                              return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Сервер $item",
                                  ));
                            }).toList();
                          },
                        ),
                        TypeAheadField<String>(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _serverAddressEditingController,
                            decoration:
                                fieldDecoration(context, "Адрес сервера"),
                          ),
                          suggestionsCallback: (String pattern) {
                            return _serverAddressSuggestions.where(
                                (element) => element.startsWith(pattern));
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
                        Tooltip(
                          textStyle: TextStyle(fontSize: 16),
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
                              value:
                                  _applicationState.inDemonstrationMode.value,
                              onChanged: (value) {
                                if (value != null) {
                                  _applicationState.inDemonstrationMode.value =
                                      value;
                                }
                              },
                              title: Text(
                                "Демо-режим",
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }),
                        ),
                        Row(
                          children: [
                            CrazyButton(
                              title: "Войти",
                              key: ValueKey('login_button'),
                              onPressed: () {
                                /// пополняем коллекцию suggestions

                                if (!_serverAddressSuggestions.contains(
                                        _serverAddressEditingController.text) &&
                                    _serverAddressEditingController
                                        .text.isNotEmpty) {
                                  setState(() {
                                    _serverAddressSuggestions.add(
                                        _serverAddressEditingController.text);
                                    // но пополняем не бесконечно, а только до пяти возможных
                                    // вариантов, чтобы не пухла
                                    if (_serverAddressSuggestions.length > 5) {
                                      _serverAddressSuggestions.removeAt(0);
                                    }
                                  });
                                }

                                // #TODO: сделать частью какого-то state
                                LocalStorageService.writeList(
                                    _serverAddressSuggestionsStorageKey,
                                    _serverAddressSuggestions);

                                /// логинимся
                                Future<void> loginFuture = authController.login(
                                    _applicationState.inDemonstrationMode.value,
                                    _loginEditingController.text,
                                    _passwordEditingController.text,
                                    _serverAddressEditingController.text);

                                /// Если пользователь разлогинился не с домашней странички(а, например, со страницы профиля),
                                /// надо его возвращать туда, откуда он разлогинился
                                loginFuture.then((value) {
                                  if (authController
                                      .authState.isAuthenticated.value) {
                                    NavigatorState navigatorState =
                                        Navigator.of(context);
                                    if (navigatorState.canPop()) {
                                      navigatorState.pop();
                                    } else {
                                      navigatorState.pushNamed("/");
                                    }
                                  }
                                });
                              },
                              padding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 32, top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
              ),
            ),
          ]),
        );
      });
    });
  }
}
