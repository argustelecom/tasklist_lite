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
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Row(children: [
          IconButton(
            icon: new Icon(Icons.access_time),
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
                          buttonTheme: ButtonThemeData(
                              textTheme: ButtonTextTheme.primary),
                        ),
                        child: child ?? new Text(""));
                  });
              onChanged(time);
            },
          ),
          Text(
              (value != null)
                  ? MaterialLocalizations.of(context).formatTimeOfDay(value!)
                  : "",
              style: TextStyle(fontSize: 14))
        ]));
  }
}
