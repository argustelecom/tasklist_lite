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

  @override
  Widget build(BuildContext context) {
    ApplicationState applicationState = ApplicationState.of(context);

    return GetBuilder<AuthController>(builder: (authController) {
      return ReflowingScaffold(
          body: Column(children: [
        Row(
          children: [
            Text("Адрес сервера: "),
            Text(applicationState.serverAddress ?? ""),
          ],
        ),
        TextField(
          decoration: InputDecoration(labelText: "Имя пользователя"),
        ),
        TextField(
          obscureText: true,
          decoration: InputDecoration(labelText: "Пароль"),
        ),
        Row(
          children: [
            CrazyButton(
              title: "Войти",
              key: ValueKey('login_button'),
              onPressed: () {
                authController.login(isDemonstrationModeChecked);
                NavigatorState navigatorState = Navigator.of(context);
                // пока такой возможности нет, но если пользователь разлогинился не с домашней странички,
                // надо бы его возвращать туда, откуда он разлогинился
                if (navigatorState.canPop()) {
                  navigatorState.pop();
                } else {
                  navigatorState.pushNamed("/");
                }
              },
              padding: EdgeInsets.only(bottom: 8, top: 8, left: 8, right: 32),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
                key: ValueKey('demo_mode'),
                child: CheckboxListTile(
              value: isDemonstrationModeChecked,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    isDemonstrationModeChecked = value;
                  });
                }
              },
              title: Tooltip(
                textStyle: TextStyle(fontSize: 16),
                message: "Можно указать любое имя пользователя и пароль. "
                    "\nБудет осуществлен вход без подключения к серверу, "
                    "\nбудут доступны демонстрационные данные. ",
                child: Text(
                  "Демо-режим",
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            )),
          ],
        )
      ]));
    });
  }
}
