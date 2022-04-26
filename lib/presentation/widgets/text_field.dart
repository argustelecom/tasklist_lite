import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Текстовое поле
// Хотелось бы обойтись темой, но поля могу иметь или не иметь границы, иметь разный радиус скругления
// Плюс здесь мы можем зафиксировать высоту поля и отступы
// TODO: можем ли обойтись набором тем?
class CustomTextField<T> extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Function(String value)? onChanged;
  final String? hint;
  final double height;
  final EdgeInsetsGeometry padding;
  final bool noBorder;
  final double borderRadius;
  final Color? borderColor;

  const CustomTextField(
      {required this.controller,
      this.keyboardType,
      this.inputFormatters,
      this.obscureText = false,
      this.onChanged,
      this.hint,
      this.height = 40,
      this.padding = const EdgeInsets.all(0),
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
            padding: EdgeInsets.all(0),
            child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                // в Edge не работает отображение скрытых символов по нажатию на глаз
                // в Chrome все ок
                obscureText: obscureText,
                onChanged: onChanged,
                cursorColor: themeData.colorScheme.primary,
                cursorWidth: 1,
                decoration: InputDecoration(
                    labelText: hint,
                    filled: true,
                    fillColor: themeData.cardColor,
                    border: OutlineInputBorder(
                      borderSide: noBorder
                          ? BorderSide.none
                          : BorderSide(color: borderColor ?? Color(0xFF287BF6)),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    floatingLabelStyle:
                        TextStyle(color: themeData.colorScheme.primary),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: themeData.colorScheme.primary),
                        borderRadius: BorderRadius.circular(borderRadius))))));
  }
}
