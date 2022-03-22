import 'package:flutter/cupertino.dart';

/// Кастомный TextEditingController для TextField на страничке с историей.
/// Используем чтобы на лету преобразовывать спецсимволы+текст в текст с определенными стилями
class TextFieldColorizer extends TextEditingController {
  final Map<String, TextStyle> map;
  final Pattern pattern;

  TextFieldColorizer(this.map)
      : pattern = RegExp(
            map.keys.map((key) {
              return key;
            }).join('|'),
            multiLine: true);

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final List<InlineSpan> children = [];
    late String patternMatched;
    late String? formatText;
    late TextStyle myStyle;
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        myStyle = (map[match[0]] ??
            map[map.keys.firstWhere(
              (e) {
                bool ret = false;
                RegExp(e).allMatches(text)
                  ..forEach((element) {
                    if (element.group(0) == match[0]) {
                      patternMatched = e;
                      ret = true;
                      // return true;
                    }
                  });
                return ret;
              },
            )])!;

        if (patternMatched == r"_(.*?)\_") {
          formatText = match[0]!.replaceAll("_", " ");
        } else if (patternMatched == r'\*(.*?)\*') {
          formatText = match[0]!.replaceAll("*", " ");
        } else if (patternMatched == "~(.*?)~") {
          formatText = match[0]!.replaceAll("~", " ");
        } else if (patternMatched == r'```(.*?)```') {
          formatText = match[0]!.replaceAll("```", "   ");
        } else {
          formatText = match[0];
        }
        children.add(TextSpan(
          text: formatText,
          style: style!.merge(myStyle),
        ));
        return "";
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return "";
      },
    );

    return TextSpan(style: style, children: children);
  }
}
