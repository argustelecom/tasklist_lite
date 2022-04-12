import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../layout/adaptive.dart';

class InfoDialog extends StatelessWidget {
  String text;
  int? maxLines = 7;

  InfoDialog({required this.text, this.maxLines, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Center(
        child: Card(
            color: themeData.cardColor,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(text,
                          maxLines: maxLines, overflow: TextOverflow.clip),
                      SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("ОК",
                                style: TextStyle(color: Color(0x99FBC22F))))
                      ])
                    ])))));
  }
}
