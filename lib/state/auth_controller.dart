import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasklist_lite/auth/auth_service.dart';
import 'package:tasklist_lite/tasklist/model/user_info.dart';

///*******************************************************************************
///****          хранит state аутентификации и инфу о текущем пользователе    ****
///*******************************************************************************
class AuthController extends GetxController {
  /// Состоялся ли успешный логин в рамках этого сеанса работы.
  /// Почему тут не обойтись без .obs? потому что получить настоящее значение
  /// isAuthenticated мы должны из sharedPreferences, которые инициализируются
  /// асинхронно. То есть (см. например https://habr.com/ru/post/497278/,
  /// https://dart.dev/codelabs/async-await#execution-flow-with-async-and-await )
  /// сначала контроллер синхронно вернет неверное локальное значение, а потом,
  /// в event loop`e (то есть хз когда) проинитит shared preferences и достанет
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

  // #TODO: хранение надо спрятать в отдельный слой/класс
  final Future<SharedPreferences> sharedPreferencesFuture =
      SharedPreferences.getInstance();

  late final SharedPreferences? sharedPreferences;

  static const String authenticatedKeyName = "authenticated";
  static const String authenticated = "Authorization";
  static const String userInfoKeyName = "userInfo";


  bool get isAuthenticated {
    return _isAuthenticated.value;
  }

  late String basicAuth;

  set isAuthenticated(bool value) {
    _isAuthenticated.value = value;
    // #TODO: нужен ли update, если у нас тут .obs и Stream?
    // наверное да, т.к. не все и не везде наблюдают?
    update();

    sharedPreferences?.setBool(authenticatedKeyName, _isAuthenticated.value);
  }

  UserInfo? get userInfo => _userInfo.value;

  set userInfo(UserInfo? value) {
    _userInfo.value = value;
    update();
    sharedPreferences?.setString(
        userInfoKeyName,
        // jsonEncode сам вызовет toJson у переданного объекта (см. каменты в jsonEncode)
        jsonEncode(value));
  }

  String? get errorText => _errorText;

  set errorText(String? value) {
    _errorText = value;
    update();
  }

  Future<void> initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }


  // TODO fix me необходимо перейти на использование SecureStorage
  String setAuth(String basAuth)  =>
      this.basicAuth = basAuth;

  String getAuth()  => this.basicAuth;

  @override
  void onInit() {
    super.onInit();

    initSharedPreferences().whenComplete(() {
      bool? __isAuthenticated =
          sharedPreferences!.getBool(authenticatedKeyName);
      if (__isAuthenticated != null) {
        isAuthenticated = __isAuthenticated;
      }

      String? rawUserInfo = sharedPreferences!.getString(userInfoKeyName);
      if (rawUserInfo != null) {
        userInfo = UserInfo.fromJson(jsonDecode(rawUserInfo));
      }
    });
  }

  login(bool inDemonstrationMode, String login, String password,
      String serverAddress) async {
    errorText = null;
    try {
      AuthService authService = Get.find();
      String basicAuth =
          "Basic " + base64Encode(utf8.encode('$login:$password'));
      setAuth(basicAuth);

      await authService
          .login(basicAuth, serverAddress,
              inDemonstrationMode: inDemonstrationMode)
          .whenComplete(() => null)
          .then(
        (value) {
          userInfo = value;
          isAuthenticated = true;
        },
        onError: (Object e, StackTrace stackTrace) {
          //должны выводится разные сообщения в зависимости от типа ошибки
          // Отсутсвует Интернет/неправильный адрес СП
          errorText =
              "Неверный логин или пароль. \nПроверьте правильность введенных данных.";
        },
      );
    }
    // #TODO: при реальной аутентификации тут возможны исключения нескольких типов,
    // их надо обрабатывать в секциях on (см. например flutter_entity_list)
    catch (anyException) {

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
