import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String? description;
  final String cancelButtonText;
  final String confirmButtonText;
  final void Function() onConfirm;
  final int? descrMaxLines;

  const ConfirmationDialog(
      {required this.title,
      this.description,
      this.cancelButtonText = "НЕТ",
      this.confirmButtonText = "ДА",
      required this.onConfirm,
      this.descrMaxLines = 7,
      Key? key})
      : super(key: key);

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
                      Text(
                        title!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (description != null) ...[
                        SizedBox(height: 8),
                        Text(description!,
                            maxLines: descrMaxLines,
                            overflow: TextOverflow.clip)
                      ],
                      SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(cancelButtonText,
                                    style:
                                        TextStyle(color: Color(0x99FBC22F)))),
                            TextButton(
                                onPressed: onConfirm,
                                child: Text(confirmButtonText,
                                    style: TextStyle(color: Color(0xFFFBC22F))))
                          ])
                    ])))));
  }
}
