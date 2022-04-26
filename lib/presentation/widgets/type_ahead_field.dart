import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

// Текстовое поле с автокомплитом
// Хотелось бы обойтись темой, но поля могу иметь или не иметь границы, иметь разный радиус скругления
// Плюс здесь мы можем зафиксировать высоту поля и отступы
// TODO: можем ли обойтись набором тем?
class CustomTypeAheadField<T> extends StatelessWidget {
  final TextEditingController controller;
  final Function(String pattern) suggestionsCallback;
  final SuggestionSelectionCallback onSelected;
  final ItemBuilder itemBuilder;
  final String? hint;
  final double height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry fieldPadding;
  final bool noBorder;
  final double borderRadius;
  final Color? borderColor;

  const CustomTypeAheadField(
      {required this.controller,
      required this.suggestionsCallback,
      required this.onSelected,
      required this.itemBuilder,
      this.hint,
      this.height = 40,
      this.padding = const EdgeInsets.all(0),
      this.fieldPadding = const EdgeInsets.all(0),
      this.noBorder = false,
      this.borderRadius = 5,
      this.borderColor,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Padding(
        padding: padding,
        child: Container(
            height: height,
            child: TypeAheadField<String>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: controller,
                decoration: InputDecoration(
                    labelText: hint,
                    filled: true,
                    fillColor: themeData.cardColor,
                    floatingLabelStyle:
                        TextStyle(color: themeData.colorScheme.primary),
                    border: OutlineInputBorder(
                        borderSide: noBorder
                            ? BorderSide.none
                            : BorderSide(color: borderColor ?? Colors.black45),
                        borderRadius: BorderRadius.circular(borderRadius)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: themeData.colorScheme.primary),
                        borderRadius: BorderRadius.circular(borderRadius))),
              ),
              suggestionsCallback: (pattern) => suggestionsCallback(pattern),
              itemBuilder: itemBuilder,
              onSuggestionSelected: onSelected,
              noItemsFoundBuilder: (context) {
                // иначе будет показан жирный No items found!
                return Text("");
              },
            )));
  }
}
