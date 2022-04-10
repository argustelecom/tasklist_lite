import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomDropDownButton<T> extends StatelessWidget {
  final value;
  final List<T> itemsList;
  final String? hint;
  final Function(T? value) onChanged;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry dropdownPadding;
  final Color? borderColor;
  final DropdownButtonBuilder? selectedItemBuilder;

  /// была мысль для dropdown border`а использовать тот же borderColor, но
  /// borderColor может задаваться условием (например, синенький, если dropdown выпал),
  /// а метод build с выпавшим dropdown`ом вызывается еще до условия "dropdown выпал".
  /// Короче, dropdown border color нужно рисовать безусловно, иначе не работает.
  final Color? dropdownColor;
  final VoidCallback? onTap;

  const CustomDropDownButton(
      {required this.value,
      required this.itemsList,
      this.hint,
      required this.onChanged,
      Key? key,
      this.padding = const EdgeInsets.all(0),
      this.dropdownPadding = const EdgeInsets.all(0),
      this.borderColor,
      this.dropdownColor,
      this.onTap,
      this.selectedItemBuilder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Colors.black54),
          borderRadius: BorderRadius.circular(5),
          color: themeData.cardColor,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            offset: Offset(0, -10),
            isExpanded: true,
            underline: SizedBox(),
            itemHeight: 40,
            buttonPadding: EdgeInsets.symmetric(horizontal: 8),
            dropdownPadding: dropdownPadding,
            itemPadding: EdgeInsets.symmetric(horizontal: 8),
            dropdownDecoration: BoxDecoration(
                border: Border.all(color: dropdownColor ?? Colors.black54),
                borderRadius: BorderRadius.circular(5),
                color: themeData.cardColor),
            focusColor: themeData.cardColor,
            hint:
                Align(alignment: Alignment.centerLeft, child: Text(hint ?? "")),
            value: value,
            items: itemsList
                .map((T item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(item.toString()),
                    ))
                .toList(),
            onTap: onTap,
            onChanged: (value) => onChanged(value),
            selectedItemBuilder: selectedItemBuilder,
          ),
        ),
      ),
    );
  }
}
