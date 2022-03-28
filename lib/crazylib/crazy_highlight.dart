import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:substring_highlight/substring_highlight.dart';

class CrazyHighlight extends StatelessWidget {
  final String text;
  final String term;
  final double? width;
  final TextStyle? textStyle;
  final TextStyle? textStyleHighlight;
  final int? maxLines;

  CrazyHighlight(
      {required this.text,
      required this.term,
      this.width,
      this.textStyle,
      this.textStyleHighlight,
      this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: width ?? MediaQuery.of(context).size.width * 0.6,
      ),
      child: SubstringHighlight(
        text: text,
        term: term,
        textStyle: textStyle ??
            TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        textStyleHighlight:
            textStyleHighlight ?? TextStyle(color: Colors.yellow.shade700),
        maxLines: maxLines != null ? maxLines: 20,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
