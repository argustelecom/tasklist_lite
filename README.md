# tasklist_lite

Список задач исполнителя. 
Кроссплатформенное адаптивное приложение.

## Сборка
1. Выполни настройку окружения как предлагается в интернете, https://docs.flutter.dev/get-started/install (пп. 1-2). 
   Для установки скачай версию flutter sdk 2.10.1, доступно в  (https://docs.flutter.dev/development/tools/sdk/releases).

   **Обязательно! Если обновляешь у себя версию flutter на новую из-за зависимостей:**
     - **сообщи всем в чате о необходимости обновления flutter sdk**
     - **поменяй фиксированную версию в сборке .github/workflows/build.yml** 
     - **поправь требуемую версию в pubspec.yaml**

2. Выполни `flutter pub get` в каталоге проекта, чтобы затянуть нужные зависимости.
### в IDE (Android Studio)
1. ПКМ на проекте (tasklist_lite) -> module settings -> project -> выбери android SDK (не путай с JDK).
2. В меню: file -> settings -> languages -> dart -> установи путь к dart SDK
3. Аналогично п.2 выстави flutter SDK
4. В Languages & Frameworks > Flutter включи Format code on save
5. После этого можно собирать проект в IDE и запускать его (проверь запуск в хроме и в эмуле(но если у тебя виндовая
виртуалка или физическая win7, забей сразу на эмуль, победы не будет))
### Из command-line:
#### apk-файл
Сборка apk выполняется командой: 
```
flutter build apk --release
``` 
Артефакт будет находиться в каталоге _build/app/outputs/flutter-apk/_ с именем _app-release.apk_

#### web
Сборка для web выполняется командой:
```
flutter build web
```
Артефакты лежат в каталоге _build/web_ их можно просто загрузить (скопировать в каталог) на любой доступный вам локальный web-сервер. Например dhttpd, Nginx или Apache httpd. 

Комадой `flutter run lib\main.dart` можно запустить web-приложение, будет предоставлен выбор доступных устройств (браузеров) для запуска.

Запуск также можно выполнить сразу с указанием device_id, например chrome:
```
flutter run lib\main.dart devices -d chrome
```
Посмотреть доступные устройства, на которых возможно запустить web-приложение:
```
flutter devices 
```

### Артефакты из сборок
Артефакты можно взять в **Actions** -> В табилце **All workflows** выбирать последнюю запущенную сборку [TaskList Lite build](https://github.com/argustelecom/tasklist_lite/actions/workflows/build.yml), в сборке доступны соответствующие артефакты:
- apk - в архиве apk-файл для установки приложения на устройство с OS Android.
- web - в архиве файлы web-версии приложения для размещения на web-сервере. Для развертования web достуны веб-сервер httpd и nginx на сетевом диске **A:\Интернет и сеть\webserver**
- httpd-2.4-win32-tasklist-lite - в архиве httpd 2.4.52 для установки на OS Windows + файлы web-версии приложения.

Дополнительно смотри [инструкцию по настройке web-сервера httpd/nginx](https://github.com/argustelecom/tasklist_lite/blob/master/docs/install-web.md).






