import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InspectorPanel extends StatelessWidget {
  // #TODO: вообще в flutter как будто не принято строки передавать, обычно передается виджет
  final String title;
  final bool initiallyExpanded;
  final Widget? child;
  InspectorPanel(
      {required this.title, this.child, this.initiallyExpanded = false});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: themeData.colorScheme.onPrimary, width: 1),
          borderRadius: BorderRadius.circular(10),
          color: themeData.colorScheme.primaryVariant),
      child: ExpansionTile(
        title: Text(title),
        initiallyExpanded: initiallyExpanded,
        // trailing: null,
        children: [Container(child: child ?? Text(title))],
      ),
    );
  }
}
