import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:tasklist_lite/crazylib/date_picker_button.dart';
import 'package:tasklist_lite/crazylib/time_picker_button.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';
import 'package:tasklist_lite/tasklist/model/idle_time.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';

import 'dropdown_button.dart';

class IdleTimeManagerDialog extends StatefulWidget {
  IdleTimeManagerDialog({
    Key? key,
    this.idleTime,
  }) : super(key: key);

  IdleTime? idleTime;

  @override
  _IdleTimeManagerDialogState createState() => _IdleTimeManagerDialogState();
}

class _IdleTimeManagerDialogState extends State<IdleTimeManagerDialog> {
  IdleTime? _idleTime;
  String? _reason;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    IdleTime? _idleTime = widget.idleTime;

    if (_idleTime != null) {
      _reason = _idleTime.reason;
      _startTime = TimeOfDay.fromDateTime(_idleTime.startDate);
      _startDate = _idleTime.startDate;
      if (_idleTime.endDate != null) {
        _endTime = TimeOfDay.fromDateTime(_idleTime.endDate!);
        _endDate = _idleTime.endDate;
      }
    } else {
      _startTime = TimeOfDay.fromDateTime(DateTime.now());
      _startDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskListController>(builder: (controller) {
      ThemeData themeData = Theme.of(context);
      ApplicationState applicationState = ApplicationState.of(context);

      Widget? dialog = new Column(children: [
        // разделитель
        // упаковываем в контейнер заданного размера, чтобы получить нужную ширину разделителя и отступы
        Container(
            width: 60,
            height: 30,
            child: Divider(color: Colors.black, height: 10, thickness: 2)),
        // заголовок
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.timer_sharp,
            color: Colors.black,
            size: 30,
          ),
          SizedBox(width: 20),
          Text(
              (_idleTime == null)
                  ? "Регистрация простоя"
                  : "Завершение простоя",
              style: TextStyle(fontWeight: FontWeight.bold))
        ]),
        // тело диалога
        Padding(
            padding: EdgeInsets.fromLTRB(20, 40, 20, 15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Причина простоя*",
                      style: TextStyle(color: Colors.black54))),
              CustomDropDownButton(
                value: _reason,
                itemsList: controller.idleTimeReasons,
                hint: "Выберите причину",
                onChanged: (value) {
                  setState(() {
                    _reason = value;
                  });
                },
              ),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Начало простоя*",
                      style: TextStyle(color: Colors.black54))),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: TimePickerButton(
                          value: _startTime,
                          onChanged: (value) {
                            if (value != null) {
                              this.setState(() {
                                _startTime = value;
                              });
                            }
                          },
                        )),
                        SizedBox(width: 30),
                        Expanded(
                            child: DatePickerButton(
                                value: _startDate,
                                onChanged: (value) {
                                  if (value != null) {
                                    this.setState(() {
                                      _startDate = value;
                                    });
                                  }
                                }))
                      ])),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Окончание простоя",
                      style: TextStyle(color: Colors.black54))),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: TimePickerButton(
                          value: _endTime,
                          onChanged: (value) {
                            if (value != null) {
                              this.setState(() {
                                _endTime = value;
                              });
                            }
                          },
                        )),
                        SizedBox(width: 30),
                        Expanded(
                            child: DatePickerButton(
                                value: _endDate,
                                onChanged: (value) {
                                  if (value != null) {
                                    this.setState(() {
                                      _endDate = value;
                                    });
                                  }
                                }))
                      ])),
              Container(
                  padding: EdgeInsets.fromLTRB(10, 60, 0, 20),
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.yellow.shade700),
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(horizontal: 80, vertical: 16)),
                        elevation: MaterialStateProperty.all(3.0),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)))),
                    child: Text(
                      (_idleTime == null) ? "Зарегистрировать" : "Завершить",
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
                  ))
            ])),
      ]);
      return Container(
          color: themeData.cardColor,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500), child: dialog))
          ]));
    });
  }
}
