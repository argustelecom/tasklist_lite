import 'dart:convert';

import 'package:get/get.dart';
import 'package:tasklist_lite/data/auth/auth_service.dart';
import 'package:tasklist_lite/presentation/state/application_state.dart';

import '../state/auth_state.dart';

///*******************************************************************************
///****          хранит state аутентификации и инфу о текущем пользователе    ****
///*******************************************************************************
class AuthController extends GetxController {
  AuthState authState = Get.find();
  ApplicationState applicationState = Get.find();
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
    authState.serverAddress.value = serverAddress;

    if (inDemonstrationMode || (login.isNotEmpty && password.isNotEmpty)) {
      try {
        AuthService authService = Get.find();
        String basicAuth =
            "Basic " + base64Encode(utf8.encode('$login:$password'));

        authState.authString.value = basicAuth;
        if (applicationState.subscriptionEnabled.value) {
          authState.authStringForWS.value = '$login:$password@';
        }
        await authService.login().whenComplete(() => null).then(
          (value) {
            authState.userInfo.value = value;
            authState.isAuthenticated.value = true;
          },
          onError: (Object e, StackTrace stackTrace) {
            // Простейшая обработка ошибок
            // дурацкая реализация. Exception.message не доступно
            String message = e.toString().substring("Exception: ".length);

            switch (message) {
              case ("Сервер недоступен"):
                errorText =
                    "Сервер не доступен. \nПроверьте правильность введенных данных. \nСообщите администратору.";
                break;
              case ("Не авторизован"):
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
