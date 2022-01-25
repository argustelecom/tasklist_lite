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

  // #TODO: хранение надо спрятать в отдельный слой/класс
  final Future<SharedPreferences> sharedPreferencesFuture =
      SharedPreferences.getInstance();

  late final SharedPreferences? sharedPreferences;

  static const String authenticatedKeyName = "authenticated";

  static const String userInfoKeyName = "userinfo";

  bool get isAuthenticated {
    return _isAuthenticated.value;
  }

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

  Future<void> initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

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

  login(bool inDemonstrationMode) {
    AuthService authService = Get.find();
    userInfo = authService.login(inDemonstrationMode: inDemonstrationMode);
    isAuthenticated = true;
    update();
  }

  logout() {
    userInfo = null;
    isAuthenticated = false;
    update();
  }
}
