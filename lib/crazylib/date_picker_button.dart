import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerButton extends StatelessWidget {
  final value;
  final Function(dynamic value) onChanged;

  const DatePickerButton(
      {required this.value, required this.onChanged, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return OutlinedButton(
        style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.all(16)),
            backgroundColor: MaterialStateProperty.all(themeData.cardColor),
            foregroundColor: MaterialStateProperty.all(themeData.primaryColor),
            overlayColor: MaterialStateProperty.all(themeData.cardColor),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            side: MaterialStateProperty.all(BorderSide(color: Colors.black54)),
            textStyle: MaterialStateProperty.all(TextStyle(
                inherit: false,
                fontSize: 14,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto'))),
        //TODO голубая обводка при наведении на поле и выборе даты
        //onHover: ,
        onPressed: () async {
          final DateTime? date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2021),
              lastDate: DateTime(2024),
              helpText: "Укажите день",
              cancelText: "Отмена",
              confirmText: "Ок",
              locale: const Locale("ru", "RU"),
              builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(primary: Colors.green),
                      buttonTheme:
                          ButtonThemeData(textTheme: ButtonTextTheme.primary),
                    ),
                    child: child ?? new Text(""));
              });
          onChanged(date);
        },
        child: Row(children: [
          Icon(
            Icons.today,
            color: themeData.colorScheme.onSurface,
            size: 24,
          ),
          SizedBox(width: 12),
          Text((value != null) ? DateFormat('dd.MM.yyyy').format(value!) : "",
              style: TextStyle(
                  inherit: false,
                  color: themeData.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Roboto'))
        ]));
  }
}
