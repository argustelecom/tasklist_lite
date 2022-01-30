import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/crazy_button.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/state/auth_controller.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = "/login";

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  bool isDemonstrationModeChecked = false;

  InputDecoration fieldDecoration(String text) {
    return InputDecoration(
        labelText: text,
        // #TODO: хоть здесь все цвета инвариантны выбранной теме (т.е. на темной тоже будут
        // прилично отображаться), все равно нехорошо цвета наликом, не через Theme. Тут такого
        // много
        floatingLabelStyle: TextStyle(color: Colors.blue),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)));
  }

  @override
  Widget build(BuildContext context) {
    ApplicationState applicationState = ApplicationState.of(context);

    return GetBuilder<AuthController>(builder: (authController) {
      return ReflowingScaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // #TODO: логотип флаттыря нехорошо так юзать. Ждем наш логотип
          FlutterLogo(
            size: 64,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "ФИГАРО",
              style: TextStyle(fontSize: 20),
            ),
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
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            Text("Адрес сервера: "),
                            Text(applicationState.serverAddress ?? ""),
                          ],
                        ),
                      ),
                      TextField(
                          cursorColor: Colors.blue,
                          // #TODO: "Имя пользователя" как-то посолидней, чем "логин". Обсудить с Лизой
                          decoration: fieldDecoration("Логин")),
                      TextField(
                          cursorColor: Colors.blue,
                          obscureText: true,
                          decoration: fieldDecoration("Пароль")),
                      Tooltip(
                        textStyle: TextStyle(fontSize: 16),
                        message:
                            "Можно указать любое имя пользователя и пароль. "
                            "\nБудет осуществлен вход без подключения к серверу, "
                            "\nбудут доступны демонстрационные данные. ",
                        child:
                            // получается не как в макете, сам чекбокс все же имеет небольшой отступ, а в макете без отступа
                            // если это не прокатит, то надо If the way CheckboxListTile pads and positions its elements isn't quite
                            // what you're looking for, you can create custom labeled checkbox widgets by
                            // combining [Checkbox] with other widgets, such as [Text], [Padding] and
                            // [InkWell]. (см. каменты в checkbox_list_tile)
                            CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: isDemonstrationModeChecked,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                isDemonstrationModeChecked = value;
                              });
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
                            onPressed: () {
                              authController.login(isDemonstrationModeChecked);
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
  }
}
