import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tasklist_lite/crazylib/quote_card.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/games/beaumarchais_quotes.dart';

/// Отчеты (какие?)
class ReportsPage extends StatelessWidget {
  static const String routeName = 'reports';

  @override
  Widget build(BuildContext context) {
    return ReflowingScaffold(
        appBar: AppBar(
            title: new Text("Страница отчетов"),
            titleTextStyle: TextStyle(fontFamily: "ABeeZee", fontSize: 20),
            toolbarHeight: 50,
            elevation: 5.0,
            titleSpacing: 0.0,
            leading: IconButton(
                icon: Icon(Icons.chevron_left_outlined),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: ListView(children: [
          //#TODO:
          Padding(
              padding: EdgeInsets.all(15.0),
              child: Text("Страница находится в разработке.")),
          QuoteCard(
              quote: kBeaumarchaisQuotes[
                  Random().nextInt(kBeaumarchaisQuotes.length)]),
        ]));
  }
}
