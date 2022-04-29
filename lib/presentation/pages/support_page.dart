import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/core/games/beaumarchais_quotes.dart';
import 'package:tasklist_lite/presentation/pages/profile_page.dart';
import 'package:tasklist_lite/presentation/widgets/cards/quote_card.dart';
import 'package:tasklist_lite/presentation/widgets/reflowing_scaffold.dart';

class SupportPage extends StatelessWidget {
  static const String routeName = 'support';

  @override
  Widget build(BuildContext context) {
    return ReflowingScaffold(
        appBar: AppBar(
            title: new Text("Служба поддержки"),
            toolbarHeight: 70,
            titleSpacing: 0.0,
            leading: IconButton(
                icon: Icon(Icons.chevron_left_outlined),
                onPressed: () {
                  GetDelegate routerDelegate = Get.find();
                  routerDelegate.toNamed(ProfilePage.routeName);
                })),
        body: ListView(children: [
          //TODO: Тут будет информация о службе поддержки и настройка включения debugMode ?
          Padding(
              padding: EdgeInsets.all(15.0),
              child: Text("Страница находится в разработке.")),
          QuoteCard(
              quote: kBeaumarchaisQuotes[
                  Random().nextInt(kBeaumarchaisQuotes.length)]),
        ]));
  }
}
