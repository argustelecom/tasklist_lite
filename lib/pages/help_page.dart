import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';

import '../crazylib/quote_card.dart';
import '../games/beaumarchais_quotes.dart';

class HelpPage extends StatelessWidget {
  static const String routeName = 'help';

  @override
  Widget build(BuildContext context) {
    return ReflowingScaffold(
        appBar: AppBar(
            title: new Text("Помощь"),
            titleTextStyle: TextStyle(fontFamily: "ABeeZee", fontSize: 20),
            toolbarHeight: 50,
            elevation: 5.0,
            titleSpacing: 0.0,
            leading: IconButton(
                icon: Icon(Icons.chevron_left_outlined),
                onPressed: () {
                  GetDelegate routerDelegate = Get.find();
                  routerDelegate.popRoute();
                })),
        body: ListView(
          children: [
            //TODO:Должно появиться вложение Руководство пользователя.doc
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text("Страница находится в разработке."),
            ),
            QuoteCard(
                quote: kBeaumarchaisQuotes[
                    Random().nextInt(kBeaumarchaisQuotes.length)]),
          ],
        ));
  }
}
