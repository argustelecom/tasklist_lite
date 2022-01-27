import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tasklist_lite/crazylib/top_user_bar.dart';

import 'package:tasklist_lite/main.dart' as app;

void main() {
  //Инициализируем singleton service для выполенния тестов на физическом
  // устройстве (в случае web-приложения в браузере)
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Тесты проверки приложения в демо-режиме', () {
    testWidgets('Выполняем вход в демо-режиме', (WidgetTester tester) async {
      //запуск приложения
      //TODO: подумать об отдельном запуске на этапе подготовки перед выполением
      //теста
      app.main();
      //необходимо дождаться загрузки приложения
      await tester.pumpAndSettle();

      //Включаем Демо-режим
      final onDemo = find.byKey(ValueKey('demo_mode'));
      await tester.tap(onDemo);
      await tester.pumpAndSettle();

      //Нажимае кнопку логина
      await tester.tap(find.byKey(ValueKey('login_button')));
      await tester.pumpAndSettle();

      //Убеждаемся, что отображено имя пользователя VLG_BOGDANOVA в верхнем блоке
      //информации о пользователе.
      Text userNameOnTopBar =
          tester.firstWidget(find.byKey(ValueKey('$TopUserBar' + '_username')));
      expect(userNameOnTopBar.data.toString().contains(RegExp('VLG_BOGDANOVA')),
          true,
          reason: "Не отображено ожидаемое имя пользователя");
    });
  });
}
