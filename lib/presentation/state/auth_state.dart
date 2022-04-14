import 'dart:convert';

import 'package:get/get.dart';
import 'package:tasklist_lite/core/state/current_auth_info.dart';
import 'package:tasklist_lite/core/state/persistent_state.dart';

import '../../domain/entities/user_info.dart';

/// содержит реактивные атрибуты, связанные с аутентификацией и авторизацией:
/// признак аутентифицированности, инфу о пользователе, адрес сервера и т.д.
class AuthState extends PersistentState implements CurrentAuthInfo {
  /// Состоялся ли успешный логин в рамках этого сеанса работы.
  final Rx<bool> isAuthenticated = false.obs;

  /// в такой нотации получаем Expected a value of type 'Null', but got one of type 'UserInfo'
  /// при попытке установить любое значение value:
  /// Rx<UserInfo?> _userInfo = null.obs;
  /// Вариант с (null as UserInfo?).obs приводит к обратной ошибке, Expected a value of type 'UserInfo', but got one of type 'Null'
  /// вместо этого надо вот так (см. https://stackoverflow.com/questions/68125824/flutter-getx-initial-value-of-obs-variable-set-to-null ):
  final Rx<UserInfo?> userInfo = Rxn<UserInfo?>();

  final Rx<String?> authString = Rxn<String?>();

  final Rx<String?> serverAddress = Rxn<String?>();

  final Rx<List<String>?> serverAddressSuggestions = Rxn<List<String>?>();

  @override
  List<RxInterface> getPersistentReactiveAttrs() {
    return [
      isAuthenticated,
      userInfo,
      serverAddress,
      authString,
      serverAddressSuggestions
    ];
  }

  AuthState();

  static const String _authStateKeyName = "authState";

  @override
  String getKeyName() {
    return _authStateKeyName;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isAuthenticated'] = isAuthenticated.value;
    // если userInfo null, запишем именно null, а не jsonEncode (а то он сам запишет
    // строку "null", что осложнит decode
    data['userInfo'] =
        userInfo.value != null ? jsonEncode(userInfo.value) : null;
    data['authString'] = authString.value;
    data['serverAddress'] = serverAddress.value;
    data['serverAddressSuggestions'] =
        jsonEncode(serverAddressSuggestions.value);
    return data;
  }

  @override
  void copyFromJson(Map<String, dynamic> json) {
    isAuthenticated.value =
        json['isAuthenticated'].toString().toLowerCase() == "true";
    userInfo.value = json['userInfo'] == null
        ? null
        : UserInfo.fromJson(jsonDecode(json['userInfo']));
    authString.value = json['authString'];
    serverAddress.value = json['serverAddress'];
    serverAddressSuggestions.value =
        List<String>.from(jsonDecode(json['serverAddressSuggestions']));
  }

  @override
  String getCurrentAuthString() {
    // вызывающий должен позаботиться о проверке на null
    return authString.value!;
  }

  @override
  String getCurrentServerAddress() {
    return serverAddress.value!;
  }
}
