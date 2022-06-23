# Автоматизация тестирования

## Виды тестов

- unit test - проверяют одну функцию, метод или класс.
- widget test - проверяет один виджет без запуска приложения.
- integration test - проверяет все приложение или его большую часть.

## Unit и Widget тесты

Unit и Widget тесты пишутся в основном разработчиком или автоматизатором, который достаточно 
погружен во flutter. Например, разработка от Unit-тестов хороша, когда точно известно поведение 
новых функций/методов или класса.
Widget тест подойдет для отладки/проверки анимации поведения ui без сборки проекта и запуска всего 
приложения.

По написанию unit-тестов документация:  
- Unit test: https://docs.flutter.dev/cookbook/testing/unit/introduction
- Использование mokito: https://docs.flutter.dev/cookbook/testing/unit/mocking
- Widget test: https://docs.flutter.dev/cookbook/testing/widget/introduction
- Способы поиска widget: https://docs.flutter.dev/cookbook/testing/widget/finders
- Прокрутка списка в widget: https://docs.flutter.dev/cookbook/testing/widget/scrolling
- Другие дейсвтия для педеачи в widget: https://docs.flutter.dev/cookbook/testing/widget/tap-drag

### Запуск тестов

Unit и widget тесты запускаются командой:
```
flutter test
```
Запустить конкретный файл-тестов:
```
flutter test test/model/task_test.dart
```
Запустить тест на физическом устройстве или web: 
```
flutter run test/settings_page_test.dart -d chrome
```

## Integration test

Интеграционные тесты могут писаться автоматизатаром по пользовательским/функциональным сценариям. 

### Запуск тестов

Для запуска на iOS / Android устройстве, сначала подключите устройство и выполните следующую команду из корня проекта
```
flutter test integration_test/app_test.dart
```
Или запустите все интеграционные тесты:
```
flutter test integration_test
```

### Настройка окружения и запуска тестов на web

Необходимо скачать и установить [chromediver](https://chromedriver.chromium.org/downloads).

Перед запуском тестов необходимо запустить chromedriver:
```
chromedrvier --port=4444
```
Запуск интеграционного теста в бразуре chrome, где integration_test.dart обеспечивает работу с drive, 
в app_test.dart целевой файл интеграционными тестами:
```
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d web-server
```
Можно добавить в команду `--no-headless`, чтобы увидеть прогон тестов на экране.

Официальная дока flutter по интеграционному тестированию: https://docs.flutter.dev/cookbook/testing/integration/introduction  
