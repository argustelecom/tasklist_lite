import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/core/games/beaumarchais_quotes.dart';
import 'package:tasklist_lite/presentation/widgets/cards/quote_card.dart';
import 'package:tasklist_lite/presentation/widgets/reflowing_scaffold.dart';

/// Рюкзак/багажник
class TrunkPage extends StatelessWidget {
  static const String routeName = 'trunk';

  @override
  Widget build(BuildContext context) {
    return ReflowingScaffold(
        appBar: AppBar(
            title: new Text("Багажник выездного специалиста"),
            titleTextStyle: TextStyle(fontFamily: "ABeeZee", fontSize: 20),
            toolbarHeight: 50,
            //elevation: 5.0,
            titleSpacing: 0.0,
            leading: IconButton(
                icon: Icon(Icons.chevron_left_outlined),
                onPressed: () {
                  GetDelegate routerDelegate = Get.find();
                  routerDelegate.popRoute();
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