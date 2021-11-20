import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
/// представляет собой item внутри listView, который умеет expansion(то есть разворачиваться) и
/// который внутри себя содержит полноценный radioList
/// @author kostd
class ExpansionRadioTile<T> extends StatefulWidget {
  /// заголовок (если не указывать, будет пустым)
  final Widget? title;

  /// выбранный (на момент открытия) объект из списка
  final T? selectedObject;

  ///  карта, в которой ключи -- это выбираемые объекты, а значения -- это отображаемые caption
  final Map<T, String> optionsMap;

  /// внешний callback для изменения state при выборе опции
  final ValueChanged<T?> onChanged;

  const ExpansionRadioTile(
      {this.title,
      this.selectedObject,
      required this.optionsMap,
      required this.onChanged});

  @override
  State<StatefulWidget> createState() => new ExpansionRadioTileState(
      this.title, this.selectedObject, this.optionsMap, this.onChanged);
}

class ExpansionRadioTileState<T> extends State<ExpansionRadioTile> {
  Widget? title;

  T? selectedObject;

  Map<T, String> optionsMap;

  ValueChanged<T?> onChanged;

  ExpansionRadioTileState(
      this.title, this.selectedObject, this.optionsMap, this.onChanged);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return ExpansionTile(
      title: title ?? Text(""),
      children: [
        ListView.builder(
            itemCount: optionsMap.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return RadioListTile(
                value: optionsMap.keys.elementAt(index),
                title: Text(
                  optionsMap.values.elementAt(index),
                  style: themeData.textTheme.bodyText1!.copyWith(
                    color: themeData.colorScheme.onPrimary,
                  ),
                ),
                groupValue: selectedObject,
                onChanged: (T? newValue) {
                  // сначала сделаем setState себе, чтобы визуально отобразился новый выбранный item
                  setState(() {
                    this.selectedObject = newValue;
                  });
                  // и теперь не забудем вызвать внешний onChanged, который, видимо, изменит shared State
                  onChanged(newValue);
                }, //this.onChanged,
                activeColor: themeData.colorScheme.primary,
                dense: true,
                toggleable: true,
              );
            }),
      ],
      backgroundColor: themeData.colorScheme.onBackground,
      collapsedBackgroundColor: themeData.colorScheme.onBackground,
      // иначе сливается с цветом фона
      textColor: themeData.colorScheme.onSurface,
      iconColor: themeData.colorScheme.onSurface,
    );
  }
}
