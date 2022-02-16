import 'package:flutter/material.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/pages/profile_page.dart';

class AboutAppPage extends StatefulWidget {
  static const String routeName = 'AboutApp';

  AboutAppPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _AboutAppPageState createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return ReflowingScaffold(
        appBar: AppBar(
            title: new Text("О приложении"),
            titleTextStyle: TextStyle(fontFamily: "ABeeZee", fontSize: 20),
            toolbarHeight: 50,
            elevation: 5.0,
            titleSpacing: 0.0,
            leading: IconButton(
                icon: Icon(Icons.chevron_left_outlined),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: ListView(
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
            shrinkWrap: true,
            children: [
              Column(children: [
                Padding(
                    padding: EdgeInsets.only(
                        left: 15, right: 15, top: 10, bottom: 10),
                    child: Card(
                        elevation: 3,
                        color: themeData.cardColor,
                        child: ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            children: [
                              TextWithLabelColumn(
                                  label: "Версия приложения:", value: "0.1.0"),
                              TextWithLabelColumn(
                                  label: "Разработчик приложения:",
                                  value: "ООО “НТЦ АРГУС”"),
                              TextWithLabelColumn(
                                  label: "Телефон:",
                                  value: "+7 (812) 333-36-60")
                            ])))
              ])
            ]));
  }
}
