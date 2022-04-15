import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tasklist_lite/presentation/pages/profile_page.dart';
import 'package:tasklist_lite/presentation/widgets/reflowing_scaffold.dart';

class AboutPage extends StatelessWidget {
  static const String routeName = 'about';

  Future<PackageInfo> _getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return ReflowingScaffold(
        appBar: AppBar(
            title: new Text("О приложении"),
            titleTextStyle: TextStyle(fontFamily: "ABeeZee", fontSize: 20),
            toolbarHeight: 70,
            elevation: 5.0,
            titleSpacing: 0.0,
            leading: IconButton(
                icon: Icon(Icons.chevron_left_outlined),
                onPressed: () {
                  GetDelegate routerDelegate = Get.find();
                  routerDelegate.toNamed(ProfilePage.routeName);
                })),
        body: ListView(
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
            shrinkWrap: true,
            children: [
              Column(children: [
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Image.asset(
                    "images/logo_figaro.png",
                    bundle: rootBundle,
                    height: 180,
                    width: 180,
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                        "Фигаро - приложение для быстрых выездных сотрудников крупнейшего в России провайдера цифровых услуг и решений.",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center),
                  ),
                ]),
                Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Card(
                        color: themeData.cardColor,
                        child: ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            children: [
                              FutureBuilder<PackageInfo>(
                                  future: _getPackageInfo(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<PackageInfo> snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text('ERROR');
                                    } else if (!snapshot.hasData) {
                                      return TextWithLabelColumn(
                                          label: "Версия приложения:",
                                          value: "Loading...");
                                    }
                                    final data = snapshot.data!;
                                    return Column(
                                      children: [
                                        TextWithLabelColumn(
                                            label: "Версия приложения:",
                                            value:
                                                "${data.version}.${data.buildNumber}"),
                                      ],
                                    );
                                  }),
                              TextWithLabelColumn(
                                  label: "Разработчик приложения:",
                                  value: "ООО “НТЦ АРГУС”"),
                              TextWithLabelColumn(
                                  label: "Контактный телефон:",
                                  value: "+7(812)333-36-60",
                                  type: TextType.phone),
                              TextWithLabelColumn(
                                  label: "Сайт компании:",
                                  value: "https://argustelecom.ru/",
                                  type: TextType.link),
                              TextWithLabelColumn(
                                  label: "E-mail:",
                                  value: "support@argustelecom.ru",
                                  type: TextType.mail),
                            ])))
              ])
            ]));
  }
}