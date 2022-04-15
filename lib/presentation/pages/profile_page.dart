import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/domain/entities/user_info.dart';
import 'package:tasklist_lite/presentation/controllers/auth_controller.dart';
import 'package:tasklist_lite/presentation/pages/about_page.dart';
import 'package:tasklist_lite/presentation/pages/help_page.dart';
import 'package:tasklist_lite/presentation/pages/support_page.dart';
import 'package:tasklist_lite/presentation/state/application_state.dart';
import 'package:tasklist_lite/presentation/state/auth_state.dart';
import 'package:tasklist_lite/presentation/widgets/reflowing_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  static const String routeName = 'profile';

  @override
  Widget build(BuildContext context) {
    ApplicationState applicationState = Get.find();
    //Отступ карточки блока
    EdgeInsets paddingSettingBlock = EdgeInsets.only(bottom: 2);
    return GetX<AuthController>(builder: (authController) {
      // #TODO: вообще может(но не долго) быть null, если мы нажали f5, и state асинхронно поднимается из хранилища
      UserInfo userInfo = authController.authState.userInfo.value ??
          new UserInfo(
              family: "Информация отстуствует",
              homeRegionName: "Информация отстуствует",
              userName: "Информация отстуствует",
              securityRoleNames: ["Информация о ролях отсутствует"],
              securityRoles: ["Информация о ролях отсутствует"]);
      return ReflowingScaffold(
          appBar: AppBar(
            // нажатие на заголовок должно возвращать назад
            title: InkResponse(
                child: Text("Профиль"),
                highlightShape: BoxShape.rectangle,
                onTap: () {
                  GetDelegate routerDelegate = Get.find();
                  routerDelegate.popRoute();
                }),
            titleTextStyle: TextStyle(fontFamily: "ABeeZee", fontSize: 20),
            leading: IconButton(
              icon: const Icon(Icons.chevron_left_outlined),
              onPressed: () {
                GetDelegate routerDelegate = Get.find();
                routerDelegate.popRoute();
              },
            ),
            toolbarHeight: 70,
            elevation: 5.0,
            titleSpacing: 0.0,
            actions: [
              //Скопировано из TopUserBar
              IconButton(
                iconSize: IconTheme.of(context).size ?? 24,
                tooltip: 'Выход',
                icon: const Icon(Icons.exit_to_app_outlined),
                onPressed: () {
                  //TASK-126749#п4. сбросим текущий путь в адресной строке и логаут
                  GetDelegate routerDelegate = Get.find();
                  routerDelegate.popRoute();
                  authController.logout();
                },
              )
            ],

            //  bottom: BorderSide(color: themeData.dividerColor, width: 2.0)))
          ),
          body: ListView(
              padding: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
              shrinkWrap: true,
              children: [
                Column(children: [
                  Container(
                      padding: EdgeInsets.only(left: 2, top: 10),
                      alignment: Alignment.centerLeft,
                      child: Text("Общая информация",
                          style: TextStyle(fontSize: 18))),
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Card(
                          color: context.theme.cardColor,
                          child: ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              children: [
                                TextWithLabelColumn(
                                    label: "ФИО:",
                                    value:
                                        userInfo.getFullWorkerName().isNotEmpty
                                            ? userInfo.getFullWorkerName()
                                            : "Не заполнено"),
                                TextWithLabelColumn(
                                    label: "Табельный номер:",
                                    value: userInfo.tabNumber?.toString() ??
                                        "Не заполнено"),
                                TextWithLabelColumn(
                                    label: "Почтовый адрес:",
                                    value: userInfo.email?.toString() ??
                                        "Не заполнено"),
                                TextWithLabelColumn(
                                    label: "Должность:",
                                    value: userInfo.workerAppoint?.toString() ??
                                        "Не заполнено"),
                                TextWithLabelColumn(
                                    label: "Основной участок:",
                                    value: userInfo.mainWorksite?.toString() ??
                                        "Не заполнено")
                              ]))),
                  Container(
                      padding: EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: Text("Контакты руководителя",
                          style: TextStyle(fontSize: 18))),
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Card(
                          color: context.theme.cardColor,
                          child: _ContactsChiefListView(
                              contactChiefList: authController.authState
                                  .userInfo.value?.contactChiefList))),
                  Container(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      alignment: Alignment.centerLeft,
                      child: Text("Настройки приложения",
                          style: TextStyle(fontSize: 18))),
                  Padding(
                      padding: paddingSettingBlock,
                      child: Card(
                          child: SizedBox(
                              height: 50.0,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Text(
                                          "Ночной режим",
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: Transform.scale(
                                            scale: 1.1,
                                            child: Switch(
                                                activeColor: Color(0xFFFFFF),
                                                activeTrackColor:
                                                    Color(0xFBC22F),
                                                value: applicationState
                                                        .themeMode.value ==
                                                    ThemeMode.dark,
                                                onChanged: (value) {
                                                  if (value) {
                                                    applicationState.themeMode
                                                        .value = ThemeMode.dark;
                                                  } else {
                                                    applicationState
                                                            .themeMode.value =
                                                        ThemeMode.light;
                                                  }
                                                }))),
                                  ])))),
                  // TASK-126749 з4. прячем лишннее для релизной сборки.
                  // функционал "Запоминать избранные работы" не попадает в релиз первой версии
                  // если нужна в релизной сборке или  другой, то убери "if (kDebugMode)".
                  if (kDebugMode)
                    Padding(
                        padding: paddingSettingBlock,
                        child: Card(
                            child: SizedBox(
                                height: 50.0,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(left: 15),
                                          child: Text(
                                            "Запоминать избранные работы",
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(right: 5),
                                          child: Transform.scale(
                                              scale: 1.1,
                                              child:
                                                  //Переклбчатель задизайблен, так как
                                                  //доработка "Запоминать избранные работы"
                                                  //будет в следующих этапах
                                                  Switch(
                                                      activeColor:
                                                          Color(0xFFFFFF),
                                                      activeTrackColor:
                                                          Color(0xFBC22F),
                                                      value: false,
                                                      // непосреджственно отсутствие действий при нажатии
                                                      // дизеблит переключатель в ui (тускнет и окрашивается в серый цвет)
                                                      onChanged: null)))
                                    ])))),
                  InkResponse(
                    highlightShape: BoxShape.rectangle,
                    onTap: () {
                      GetDelegate routerDelegate = Get.find();
                      routerDelegate.toNamed(SupportPage.routeName);
                    },
                    child: Padding(
                        padding: paddingSettingBlock,
                        child: Card(
                            child: SizedBox(
                                height: 50.0,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Text("Служба поддержки")),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.only(right: 15),
                                      child: const Icon(
                                          Icons.chevron_right_outlined,
                                          size: 30),
                                    )
                                  ],
                                )))),
                  ),

                  InkResponse(
                      highlightShape: BoxShape.rectangle,
                      onTap: () {
                        GetDelegate routerDelegate = Get.find();
                        routerDelegate.toNamed(HelpPage.routeName);
                      },
                      child: Padding(
                          padding: paddingSettingBlock,
                          child: Card(
                              child: SizedBox(
                                  height: 50.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(left: 15),
                                          child: Text("Помощь")),
                                      Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(right: 15),
                                          child: const Icon(
                                              Icons.chevron_right_outlined,
                                              size: 30))
                                    ],
                                  ))))),
                  InkResponse(
                      highlightShape: BoxShape.rectangle,
                      onTap: () {
                        GetDelegate routerDelegate = Get.find();
                        routerDelegate.toNamed(AboutPage.routeName);
                      },
                      child: Padding(
                          padding: paddingSettingBlock,
                          child: Card(
                              child: SizedBox(
                                  height: 50.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(left: 15),
                                          child: Text("О приложении")),
                                      Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(right: 15),
                                          child: const Icon(
                                              Icons.chevron_right_outlined,
                                              size: 30))
                                    ],
                                  )))))
                ])
              ]));
    });
  }
}

/// Для отображения контактов руководителя на странице profile
class _ContactsChiefListView extends StatelessWidget {
  final List<Contact>? contactChiefList;
  final AuthState authState = Get.find();

  _ContactsChiefListView({Key? key, this.contactChiefList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (authState.userInfo.value?.contactChiefList != null ||
        (authState.userInfo.value?.contactChiefList as List).isNotEmpty) {
      return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: authState.userInfo.value?.contactChiefList?.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(children: [
              TextWithLabelColumn(
                  label: "ФИО:",
                  value: authState.userInfo.value?.contactChiefList
                          ?.elementAt(index)
                          .name ??
                      "Не заполнено"),
              TextWithLabelColumn(
                  label: "Контактный телефон:",
                  value: authState.userInfo.value?.contactChiefList
                          ?.elementAt(index)
                          .phoneNum ??
                      "Не заполнено",
                  type: authState.userInfo.value?.contactChiefList
                              ?.elementAt(index)
                              .phoneNum !=
                          null
                      ? TextType.phone
                      : TextType.text),
              TextWithLabelColumn(
                  label: "Почтовый адрес:",
                  value: authState.userInfo.value?.contactChiefList
                          ?.elementAt(index)
                          .email ??
                      "Не заполнено",
                  type: authState.userInfo.value?.contactChiefList
                              ?.elementAt(index)
                              .email !=
                          null
                      ? TextType.mail
                      : TextType.text)
            ]);
          });
    } else {
      return Text("Нет контактов руководителя.",
          style: TextStyle(
              fontSize: 16.0,
              color: Color(0xFF646363),
              fontWeight: FontWeight.normal));
    }
  }
}

/// Тип выполняемого оборудования
enum TextType { text, phone, mail, link }

/// Отображеине текста lable: value столбцом в card
/// отделил для сохранения отсутупов на странице profile_page.
/// value можно отобразить как текст, или телефон (будет отображаться, как ссылка)
/// Доплнительно, если в value передать неколько телефонов через заяпятую или
/// пробел, занчения будет отдельными ссылками.
class TextWithLabelColumn extends StatelessWidget {
  final String label;
  final String value;
  final TextType type;

  TextWithLabelColumn(
      {Key? key,
      required this.label,
      required this.value,
      this.type = TextType.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget textWidget;
    if (type == TextType.phone) {
      // Если поле телефон указали несколько номеров, нужно их распарсить для
      // отображения через заяпятую отдельными ссылками.
      List<TextSpan> textSpanList = [];
      List<String> phoneNums = value.split(new RegExp(r'[, ]+'));
      for (final number in phoneNums) {
        if (textSpanList.isNotEmpty)
          textSpanList.add(TextSpan(
              text: ", ", style: TextStyle(fontSize: 16, color: Colors.black)));
        textSpanList.add(TextSpan(
            text: "$number",
            style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.underline),
            // Обеспечивает открытие ссылки по нажатию
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch("tel:$number");
              }));
      }
      textWidget = GestureDetector(
          //копируем всё значение
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: "$value"));
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Скопировано: $value")));
          },
          child: Container(
              alignment: Alignment.centerLeft,
              child: RichText(text: TextSpan(children: textSpanList))));
    } else if (type == TextType.mail) {
      textWidget = GestureDetector(
          onTap: () {
            launch("mailto:$value");
          },
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: "$value"));
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Скопировано: $value")));
          },
          child: Container(
              alignment: Alignment.centerLeft,
              child: RichText(
                  text: TextSpan(
                text: value,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline),
                // Обеспечивает открытие ссылки по нажатию
              ))));
    } else if (type == TextType.link) {
      textWidget = GestureDetector(
          onTap: () {
            launch("$value");
          },
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: "$value"));
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Скопировано: $value")));
          },
          child: Container(
              alignment: Alignment.centerLeft,
              child: RichText(
                  text: TextSpan(
                      text: value,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline)))));
    } else {
      textWidget = GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: "$value"));
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Скопировано: $value")));
          },
          child: Container(
              alignment: Alignment.centerLeft,
              child: Text(value, style: TextStyle(fontSize: 16))));
    }
    return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(bottom: 5, top: 5),
        child: Column(children: [
          Container(
              alignment: Alignment.centerLeft,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF646363),
                      fontWeight: FontWeight.normal))),
          textWidget
        ]));
  }
}