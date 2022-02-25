import 'package:flutter/material.dart';

class TimePickerButton extends StatelessWidget {
  final value;
  final Function(dynamic value) onChanged;

  const TimePickerButton({
    required this.value,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

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
        //TODO голубая обводка при наведении на поле и выборе времени
        //onHover: ,
        onPressed: () async {
          final TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              helpText: "Укажите время",
              cancelText: "Отмена",
              confirmText: "Ок",
              builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(primary: Colors.green),
                      buttonTheme:
                          ButtonThemeData(textTheme: ButtonTextTheme.primary),
                    ),
                    child: child ?? new Text(""));
              });
          onChanged(time);
        },
        child: Row(children: [
          Icon(
            Icons.access_time,
            color: themeData.colorScheme.onSurface,
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
              (value != null)
                  ? MaterialLocalizations.of(context).formatTimeOfDay(value!)
                  : "",
              style: TextStyle(
                  color: themeData.colorScheme.onSurface, fontSize: 16))
        ]));
  }
}
