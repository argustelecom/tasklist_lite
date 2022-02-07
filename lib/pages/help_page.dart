import 'package:flutter/material.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';

class HelpPage extends StatefulWidget {
  static const String routeName = 'help';

  HelpPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {

  @override
  Widget build(BuildContext context) {
      return ReflowingScaffold(
          appBar: AppBar(
          title: new Text("Помощь"),
    leading: IconButton(
    icon: Icon(Icons.chevron_left_outlined),
    onPressed: () {
    Navigator.pop(context);
    })),
    body: ListView(
      children: [
        //TODO:Должно появиться вложение Руководство пользователя.doc
        Text("")
      ],
    ));
  }
}