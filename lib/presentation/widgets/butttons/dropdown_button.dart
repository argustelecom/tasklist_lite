import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../controllers/common_dropdown_controller.dart';

class CustomDropDownButton<T> extends StatelessWidget {
  final value;
  final List<T> itemsList;
  final Function(T? value) onChanged;
  final DropdownButtonBuilder? selectedItemBuilder;
  final VoidCallback? onTap;
  final String? hint;
  final double height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry dropdownPadding;
  final double borderRadius;
  final Color? borderColor;
  final bool noBorder;

  /// была мысль для dropdown border`а использовать тот же borderColor, но
  /// borderColor может задаваться условием (например, синенький, если dropdown выпал),
  /// а метод build с выпавшим dropdown`ом вызывается еще до условия "dropdown выпал".
  /// Короче, dropdown border color нужно рисовать безусловно, иначе не работает.
  final Color? dropdownColor;

  const CustomDropDownButton(
      {required this.value,
      required this.itemsList,
      required this.onChanged,
      this.selectedItemBuilder,
      this.onTap,
      this.hint,
      this.height = 40,
      this.padding = const EdgeInsets.all(0),
      this.dropdownPadding = const EdgeInsets.all(0),
      this.borderRadius = 5,
      this.borderColor,
      this.noBorder = false,
      this.dropdownColor,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommonDropdownController>(
        builder: (commonDropdownController) {
      ThemeData themeData = Theme.of(context);

      return Padding(
        padding: padding,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: themeData.cardColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
                color: commonDropdownController.someDropdownTapped
                    ? themeData.colorScheme.primary
                    : (borderColor ?? Colors.black54),
                style:
                    (commonDropdownController.someDropdownTapped || !noBorder)
                        ? BorderStyle.solid
                        : BorderStyle.none),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<T>(
              offset: Offset(0, -10),
              isExpanded: true,
              underline: SizedBox(),
              itemHeight: height,
              buttonPadding: EdgeInsets.symmetric(horizontal: 8),
              dropdownPadding: dropdownPadding,
              itemPadding: EdgeInsets.symmetric(horizontal: 8),
              dropdownDecoration: BoxDecoration(
                color: themeData.cardColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: themeData.colorScheme.primary),
              ),
              focusColor: themeData.cardColor,
              hint: Align(
                  alignment: Alignment.centerLeft, child: Text(hint ?? "")),
              icon: Icon(Icons.keyboard_arrow_down),
              value: value,
              items: itemsList
                  .map((T item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(item.toString()),
                      ))
                  .toList(),
              onTap: () {
                commonDropdownController.someDropdownTapped = true;
              },
              onChanged: (value) => onChanged(value),
              selectedItemBuilder: selectedItemBuilder,
            ),
          ),
        ),
      );
    });
  }
}
