import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tasklist_lite/main.dart';
import 'package:tasklist_lite/pages/settings_page.dart';

class SettingsPageTest extends SettingsPage {
  final Widget child;


}


/// Не рабочий пример теста.
/// TODO: ВС хочет доделать

@GenerateMocks([BuildContext])
void main() {
  testWidgets('Проверка виджета settings_page', (WidgetTester tester) async {
    final context = MockBuildContext();

    //TODO: у ВС есть еще мысля, которую нужно опробовать по хорошему примеру
    //https://github.com/kltsv/clickdash
    //await tester.pumpWidget(SettingsPage());
    //MaterialApp(builder: (context) => SettingsPage.routeName));

    await tester.pump(Duration(minutes: 1));

    expect(find.text("Демо-режим"),
        findsOneWidget);

    await tester.tap(find.text("Демо-режим"));
    await tester.pump();
    await tester.tap(find.text("Войти"));
    await tester.pump();

    await tester.pump(Duration(minutes: 1));

    expect(find.text("Профиль"),
    findsOneWidget);
  });
}


// Предполагал что должно выглядеться следующим образом
// testWidgets('Проверка виджета settings_page', (WidgetTester tester) async {
// await tester.pumpWidget(SettingsPage());
// expect(find.text("Настройки"), findsOneWidget);
// }



