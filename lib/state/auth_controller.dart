import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:tasklist_lite/auth/auth_service.dart';
import 'package:tasklist_lite/tasklist/model/user_info.dart';
import 'package:tasklist_lite/user_secure_storage/user_secure_storage_service.dart';

///*******************************************************************************
///****          хранит state аутентификации и инфу о текущем пользователе    ****
///*******************************************************************************
class AuthController extends GetxController {
  /// Состоялся ли успешный логин в рамках этого сеанса работы.
  /// Почему тут не обойтись без .obs? потому что получить настоящее значение
  /// isAuthenticated мы должны из UserSecureStorage, который инициализируется
  /// асинхронно. То есть (см. например https://habr.com/ru/post/497278/,
  /// https://dart.dev/codelabs/async-await#execution-flow-with-async-and-await )
  /// сначала контроллер синхронно вернет неверное локальное значение, а потом,
  /// в event loop`e (то есть хз когда) проинитит UserSecureStorage и достанет
  /// настоящее значение. К этому моменту onGenerateRoute из main`а уже отработает
  /// по неправильному, ранее возвращенному значению. И только реактивность и
  /// observable может заставить onGenerateRoute учесть правильное значение, когда
  /// оно будет готово (см. применение Obx в onGenerateRoute).
  Rx<bool> _isAuthenticated = false.obs;

  /// в такой нотации получаем Expected a value of type 'Null', but got one of type 'UserInfo'
  /// при попытке установить любое значение value:
  /// Rx<UserInfo?> _userInfo = null.obs;
  /// Вариант с (null as UserInfo?).obs приводит к обратной ошибке, Expected a value of type 'UserInfo', but got one of type 'Null'
  /// вместо этого надо вот так (см. https://stackoverflow.com/questions/68125824/flutter-getx-initial-value-of-obs-variable-set-to-null ):
  Rx<UserInfo?> _userInfo = Rxn<UserInfo?>();

  /// в случае, если при попытке входа была ошибка, она будет сохранена суда, и будет отображена
  /// в нижней части LoginPage
  String? _errorText;

  static const String authenticatedKeyName = "authenticated";
  static const String authenticated = "Authorization";
  static const String userInfoKeyName = "userInfo";

  bool get isAuthenticated {
    return _isAuthenticated.value;
  }

  late String basicAuth = "";
  late String serverAddress;

  String getServerAddress() {
    if (serverAddress == null) {
      UserSecureStorageService.getServerAddress().whenComplete(() => null);
    }
    return serverAddress;
  }

  setServerAddress(String value) {
    serverAddress = value;
    UserSecureStorageService.setServerAddress(value);
  }

  Future initServerAddress() async {
    // TODO разобраться как сделать правильно
    serverAddress = (await UserSecureStorageService.getServerAddress())!;
  }

  set isAuthenticated(bool value) {
    _isAuthenticated.value = value;
    // #TODO: нужен ли update, если у нас тут .obs и Stream?
    // наверное да, т.к. не все и не везде наблюдают?
    update();

    UserSecureStorageService.setAuthenticated(_isAuthenticated.value);
  }

  UserInfo? get userInfo => _userInfo.value;

  set userInfo(UserInfo? value) {
    _userInfo.value = value;
    update();
    UserSecureStorageService.setUserInfo(value);
  }

  String? get errorText => _errorText;

  set errorText(String? value) {
    _errorText = value;
    update();
  }

  String setAuth(String basAuth) => this.basicAuth = basAuth;

  String getAuth() => this.basicAuth;

  Future initAuthData() async {
    isAuthenticated = await UserSecureStorageService.getAuthenticated();
    userInfo = await UserSecureStorageService.getUserInfo();
  }

  @override
  void onInit() {
    super.onInit();
    initAuthData().whenComplete(() => null);
  }

  login(bool inDemonstrationMode, String login, String password,
      String serverAddress) async {
    errorText = null;
    if (inDemonstrationMode || (login.isNotEmpty && password.isNotEmpty)) {
      try {
        AuthService authService = Get.find();
        String basicAuth =
            "Basic " + base64Encode(utf8.encode('$login:$password'));
        setAuth(basicAuth);
        setServerAddress(serverAddress);

        await authService
            .login(basicAuth, serverAddress, inDemonstrationMode)
            .whenComplete(() => null)
            .then(
          (value) {
            userInfo = value;
            isAuthenticated = true;
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
        errorText =
            "Неожиданная ошибка. \nСообщите администратору.";
      }
    } else {
      errorText =
          "Неверный логин или пароль. \nПроверьте правильность введенных данных.";
    }
    update();
  }

  logout() {
    userInfo = null;
    isAuthenticated = false;
    // TODO FIX ME
    basicAuth = "";
    update();
  }
}
