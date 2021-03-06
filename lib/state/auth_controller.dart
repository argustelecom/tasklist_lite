import 'dart:convert';

import 'package:get/get.dart';
import 'package:tasklist_lite/auth/auth_service.dart';

import 'auth_state.dart';

///*******************************************************************************
///****          хранит state аутентификации и инфу о текущем пользователе    ****
///*******************************************************************************
class AuthController extends GetxController {
  AuthState authState = Get.put(AuthState());

  /// в случае, если при попытке входа была ошибка, она будет сохранена суда, и будет отображена
  /// в нижней части LoginPage
  String? _errorText;

  String? get errorText => _errorText;

  set errorText(String? value) {
    _errorText = value;
    update();
  }

  @override
  void onInit() {
    super.onInit();
  }

  login(bool inDemonstrationMode, String login, String password,
      String serverAddress) async {
    errorText = null;

    if (inDemonstrationMode || (login.isNotEmpty && password.isNotEmpty)) {
      try {
        AuthService authService = Get.find();
        String basicAuth =
            "Basic " + base64Encode(utf8.encode('$login:$password'));

        authState.authString.value = basicAuth;
        authState.serverAddress.value = serverAddress;

        await authService
            .login(basicAuth, serverAddress, inDemonstrationMode)
            .whenComplete(() => null)
            .then(
          (value) {
            authState.userInfo.value = value;
            authState.isAuthenticated.value = true;
          },
          onError: (Object e, StackTrace stackTrace) {
            // Простейшая обработка ошибок
            // дурацкая реализация. Exception.message не доступно
            String message = e.toString().substring("Exception: ".length);

            switch (message) {
              case ("Сервер не доступен"):
                errorText =
                    "Сервер не доступен. \nПроверьте правильность введенных данных. \nСообщите администратору.";
                break;
              case ("Неавторизован"):
                errorText =
                    "Неверный логин или пароль. \nПроверьте правильность введенных данных.";
                break;
              case ("Ошибка получения данных о профиле пользователя"):
                errorText =
                    "Ошибка получения данных о профиле пользователя. \nСообщите администратору.";
                break;
              default:
                errorText =
                    "Ошибка получения данных. \nСообщите администратору.";
            }
          },
        );
      }
      // #TODO: при реальной аутентификации тут возможны исключения нескольких типов,
      // их надо обрабатывать в секциях on (см. например flutter_entity_list)
      catch (anyException) {
        errorText = "Неожиданная ошибка. \nСообщите администратору.";
      }
    } else {
      errorText =
          "Неверный логин или пароль. \nПроверьте правильность введенных данных.";
    }
    update();
  }

  logout() {
    authState.userInfo.value = null;
    authState.isAuthenticated.value = false;
    // TODO FIX ME
    authState.authString.value = "";
    update();
  }
}
