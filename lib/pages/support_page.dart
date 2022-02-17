import 'package:flutter/material.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';

class SupportPage extends StatefulWidget {
  static const String routeName = 'support';

  SupportPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    return ReflowingScaffold(
        appBar: AppBar(
            title: new Text("Служба поддержки"),
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
          children: [
            //TODO: Тут будет информация о службе поддержки и настройка включения debugMode ?
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Text("Страница находится в разработке."))
          ],
        ));
  }
}
