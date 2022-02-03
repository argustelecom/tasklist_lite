import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerButton extends StatelessWidget {
  final value;
  final Function(dynamic value) onChanged;

  const DatePickerButton({
    required this.value,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Row(children: [
          IconButton(
            icon: new Icon(
              Icons.today,
            ),
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
                          buttonTheme: ButtonThemeData(
                              textTheme: ButtonTextTheme.primary),
                        ),
                        child: child ?? new Text(""));
                  });
              onChanged(date);
            },
          ),
          Text((value != null) ? DateFormat('dd.MM.yyyy').format(value!) : "",
              style: TextStyle(fontSize: 14))
        ]));
  }
}
