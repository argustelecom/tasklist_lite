import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:tasklist_lite/crazylib/date_picker_button.dart';
import 'package:tasklist_lite/crazylib/time_picker_button.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';
import 'package:tasklist_lite/tasklist/model/idle_time.dart';

import 'adaptive_dialog.dart';
import 'dropdown_button.dart';

class IdleTimeManagerDialog extends StatefulWidget {
  IdleTimeManagerDialog({Key? key, this.idleTime}) : super(key: key);

  IdleTime? idleTime;

  @override
  IdleTimeManagerDialogState createState() => IdleTimeManagerDialogState();
}

class IdleTimeManagerDialogState extends State<IdleTimeManagerDialog> {
  IdleTime? idleTime;
  IdleTimeReason? reason;
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    idleTime = widget.idleTime;

    if (idleTime != null) {
      reason = idleTime!.reason;
      startTime = TimeOfDay.fromDateTime(idleTime!.startDate);
      startDate = idleTime!.startDate;
      if (idleTime!.endDate != null) {
        endTime = TimeOfDay.fromDateTime(idleTime!.endDate!);
        endDate = idleTime!.endDate;
      }
    } else {
      startTime = TimeOfDay.fromDateTime(DateTime.now());
      startDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskListController>(builder: (controller) {
      ThemeData themeData = Theme.of(context);
      ApplicationState applicationState = ApplicationState.of(context);

      Widget body =
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("Причина простоя*",
                style: TextStyle(color: Colors.black54))),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CustomDropDownButton<IdleTimeReason>(
              value: reason,
              itemsList: controller.idleTimeReasons,
              selectedItemBuilder: (BuildContext context) {
                return controller.idleTimeReasons
                    .map<Widget>((IdleTimeReason item) {
                  return Align(
                      alignment: Alignment.centerLeft,
                      child: (Text(item.name)));
                }).toList();
              },
              hint: "Выберите причину",
              onChanged: (value) {
                setState(() {
                  reason = value;
                });
              },
            )),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("Начало простоя*",
                style: TextStyle(color: Colors.black54))),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: TimePickerButton(
                    value: startTime,
                    onChanged: (value) {
                      if (value != null) {
                        this.setState(() {
                          startTime = value;
                        });
                      }
                    },
                  )),
                  SizedBox(width: 30),
                  Expanded(
                      child: DatePickerButton(
                          value: startDate,
                          onChanged: (value) {
                            if (value != null) {
                              this.setState(() {
                                startDate = value;
                              });
                            }
                          }))
                ])),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("Окончание простоя",
                style: TextStyle(color: Colors.black54))),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: TimePickerButton(
                    value: endTime,
                    onChanged: (value) {
                      if (value != null) {
                        this.setState(() {
                          endTime = value;
                        });
                      }
                    },
                  )),
                  SizedBox(width: 30),
                  Expanded(
                      child: DatePickerButton(
                          value: endDate,
                          onChanged: (value) {
                            if (value != null) {
                              this.setState(() {
                                endDate = value;
                              });
                            }
                          }))
                ]))
      ]);

      Widget buttonBar = ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.yellow.shade700),
            padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(horizontal: 80, vertical: 16)),
            elevation: MaterialStateProperty.all(3.0),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)))),
        child: Text(
          (idleTime == null) ? "Зарегистрировать" : "Завершить",
          style: TextStyle(
              inherit: false,
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16),
        ),
        // TODO: обращение к контроллеру/репозиторию для валидации и формирования запроса
        //  пока просто закрываем диалог
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      return AdaptiveDialog(
          titleIcon: Icons.timer_sharp,
          titleText:
              (idleTime == null) ? "Регистрация простоя" : "Завершение простоя",
          body: body,
          buttonBar: buttonBar);
    });
  }
}
