import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropDownButton extends StatelessWidget {
  final value;
  final List<String> itemsList;
  final String? hint;
  final Function(dynamic value) onChanged;

  const CustomDropDownButton({
    required this.value,
    required this.itemsList,
    this.hint,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(5),
          color: themeData.cardColor,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            offset: Offset(0, -10),
            isExpanded: true,
            underline: SizedBox(),
            itemHeight: 40,
            buttonPadding: EdgeInsets.symmetric(horizontal: 8),
            dropdownPadding: EdgeInsets.all(0),
            itemPadding: EdgeInsets.symmetric(horizontal: 8),
            dropdownDecoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(5),
                color: themeData.cardColor),
            focusColor: themeData.cardColor,
            hint: Text(hint ?? ""),
            value: value,
            items: itemsList
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: (value) => onChanged(value),
          ),
        ),
      ),
    );
  }
}
