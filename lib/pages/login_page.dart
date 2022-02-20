import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_language_fonts/google_language_fonts.dart';
import 'package:tasklist_lite/crazylib/crazy_button.dart';
import 'package:tasklist_lite/crazylib/dropdown_button.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/state/auth_controller.dart';
import 'package:tasklist_lite/state/common_dropdown_controller.dart';

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

  InputDecoration fieldDecoration(BuildContext context, String text) {
    ThemeData themeData = Theme.of(context);
    return InputDecoration(
        labelText: text,
        floatingLabelStyle: TextStyle(color: themeData.colorScheme.primary),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: themeData.colorScheme.primary)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // didChangeDependencies делается часто, например, если пользователь тыкнул галку деморежима
    // а нам надо только один раз инициализироваться. Делать это в initState не можем, т.к.
    // нужен доступ к context для получения ApplicationState
    if (_selectedServer == null) {
      ApplicationState applicationState = ApplicationState.of(context);
      _serverAddressEditingController.text = applicationState.serverAddress;
      Map<String, String> possibleServers = applicationState.possibleServers;
      if (possibleServers.values.contains(applicationState.serverAddress)) {
        _selectedServer = possibleServers.keys.firstWhere((element) =>
            possibleServers[element] == applicationState.serverAddress);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ApplicationState applicationState = ApplicationState.of(context);
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
                                  applicationState.possibleServers;
                              _selectedServer = value;

                              _serverAddressEditingController.text =
                                  possibleServers[_selectedServer] ??
                                      _serverAddressEditingController.text;
                            });
                          },
                          itemsList:
                              List.of(applicationState.possibleServers.keys),
                          selectedItemBuilder: (BuildContext context) {
                            return applicationState.possibleServers.keys
                                .map<Widget>((String item) {
                              return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Сервер $item",
                                  ));
                            }).toList();
                          },
                        ),
                        TextField(
                          controller: _serverAddressEditingController,
                          cursorColor: themeData.colorScheme.primary,
                          decoration: fieldDecoration(context, "Адрес сервера"),
                        ),
                        Tooltip(
                          textStyle: TextStyle(fontSize: 16),
                          message:
                              "Можно указать любое имя пользователя и пароль. "
                              "\nБудет осуществлен вход без подключения к серверу, "
                              "\nбудут доступны демонстрационные данные. ",
                          key: ValueKey('demo_mode'),
                          child:
                              // получается не как в макете, сам чекбокс все же имеет небольшой отступ, а в макете без отступа
                              // если это не прокатит, то надо If the way CheckboxListTile pads and positions its elements isn't quite
                              // what you're looking for, you can create custom labeled checkbox widgets by
                              // combining [Checkbox] with other widgets, such as [Text], [Padding] and
                              // [InkWell]. (см. каменты в checkbox_list_tile)
                              CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: ApplicationState.of(context)
                                .inDemonstrationMode,
                            onChanged: (value) {
                              if (value != null) {
                                ApplicationState newApplicationState =
                                    ApplicationState.of(context)
                                        .copyWith(inDemonstrationMode: value);
                                ApplicationState.update(
                                    context, newApplicationState);
                                // kostd: делаем это глупое помещение в контекст перед тем, как слой поведения обратится
                                // к ApplicationState (см. камент в самом ApplicationState)
                                // в данном конкретном случае проще всего помещать в контекст при изменении значения inDemonstrationMode
                                // т.к. оно меняется только в одном месте -- здесь
                                Get.delete<ApplicationState>();
                                Get.put(newApplicationState);
                              }
                            },
                            title: Text(
                              "Демо-режим",
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                        Row(
                          children: [
                            CrazyButton(
                              title: "Войти",
                              key: ValueKey('login_button'),
                              onPressed: () {
                                ApplicationState.update(
                                    context,
                                    ApplicationState.of(context).copyWith(
                                        serverAddress:
                                            _serverAddressEditingController
                                                .text));
                                authController.login(
                                    ApplicationState.of(context)
                                        .inDemonstrationMode,
                                    _loginEditingController.text,
                                    _passwordEditingController.text,
                                    applicationState.serverAddress);
                                NavigatorState navigatorState =
                                    Navigator.of(context);
                                // пока такой возможности нет, но если пользователь разлогинился не с домашней странички,
                                // надо бы его возвращать туда, откуда он разлогинился
                                if (navigatorState.canPop()) {
                                  navigatorState.pop();
                                } else {
                                  navigatorState.pushNamed("/");
                                }
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
