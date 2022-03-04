import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';
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
  IdleTime? _idleTime;
  IdleTimeReason? _reason;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  bool _operationCompleted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _idleTime = widget.idleTime;

    if (_idleTime != null) {
      _reason = _idleTime!.reason;
      _startTime = TimeOfDay.fromDateTime(_idleTime!.startDate);
      _startDate = _idleTime!.startDate;
      if (_idleTime!.endDate != null) {
        _endTime = TimeOfDay.fromDateTime(_idleTime!.endDate!);
        _endDate = _idleTime!.endDate;
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

      Widget body =
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // причина простоя
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
                _operationCompleted ? "Причина простоя" : "Причина простоя*",
                style: TextStyle(color: Colors.black54))),
        !_operationCompleted
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CustomDropDownButton<IdleTimeReason>(
                  value: _reason,
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
                      _reason = value;
                    });
                  },
                ))
            : Padding(
                padding: EdgeInsets.symmetric(vertical: 17),
                child: Text((_reason != null) ? _reason!.name : "",
                    style: TextStyle(
                        inherit: false,
                        fontSize: 16,
                        color: themeData.colorScheme.onSurface,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto'))),
        // начало простоя
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
                _operationCompleted ? "Начало простоя" : "Начало простоя*",
                style: TextStyle(color: Colors.black54))),
        !_operationCompleted
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
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
                    ]))
            : Padding(
                padding: EdgeInsets.symmetric(vertical: 17),
                child: Row(children: [
                  SizedBox(
                      width: 100,
                      child: Row(children: [
                        Icon(
                          Icons.access_time,
                          color: themeData.colorScheme.onSurface,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                            (_startTime != null)
                                ? MaterialLocalizations.of(context)
                                    .formatTimeOfDay(_startTime!)
                                : "",
                            style: TextStyle(fontFamily: 'Roboto'))
                      ])),
                  SizedBox(width: 30),
                  Icon(
                    Icons.today,
                    color: themeData.colorScheme.onSurface,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                      (_startDate != null)
                          ? DateFormat('dd.MM.yyyy').format(_startDate!)
                          : "",
                      style: TextStyle(fontFamily: 'Roboto'))
                ])),
        // окончание простоя
        if (!_operationCompleted || _endDate != null)
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                  (_operationCompleted || _idleTime == null)
                      ? "Окончание простоя"
                      : "Окончание простоя*",
                  style: TextStyle(color: Colors.black54))),
        if (!_operationCompleted)
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
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
        if (_operationCompleted && _endDate != null)
          Padding(
              padding: EdgeInsets.symmetric(vertical: 17),
              child: Row(children: [
                SizedBox(
                    width: 100,
                    child: Row(children: [
                      Icon(
                        Icons.access_time,
                        color: themeData.colorScheme.onSurface,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                          (_endTime != null)
                              ? MaterialLocalizations.of(context)
                                  .formatTimeOfDay(_endTime!)
                              : "",
                          style: TextStyle(fontFamily: 'Roboto'))
                    ])),
                SizedBox(width: 30),
                Icon(
                  Icons.today,
                  color: themeData.colorScheme.onSurface,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                    (_endDate != null)
                        ? DateFormat('dd.MM.yyyy').format(_endDate!)
                        : "",
                    style: TextStyle(fontFamily: 'Roboto'))
              ])),
        // длительность простоя
        if (_operationCompleted && _endDate != null)
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("Длительность",
                  style: TextStyle(color: Colors.black54))),
        if (_operationCompleted && _endDate != null)
          Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(children: [
                Icon(
                  Icons.access_time,
                  color: themeData.colorScheme.onSurface,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(_idleTime!.getDurationText(),
                    style: TextStyle(fontFamily: 'Roboto'))
              ])),
        // подсказка при регистрации открытого простоя
        if (_operationCompleted && _endDate == null)
          Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(children: [
                Icon(
                  Icons.info,
                  color: Color(0xFF287BF6),
                  size: 24,
                ),
                SizedBox(width: 12),
                Flexible(
                    child: Text(
                        "Зарегистрирован открытый простой. Его необходимо закрыть позже.",
                        style: TextStyle(
                            fontFamily: 'Roboto', color: Color(0xFF287BF6)),
                        textWidthBasis: TextWidthBasis.parent,
                        maxLines: 4))
              ])),
        // сообщение об ошибке
        if (_error != null)
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(_error!,
                  maxLines: 3,
                  overflow: TextOverflow.clip,
                  style: TextStyle(color: Colors.red, fontFamily: 'Roboto')))
      ]);

      Widget buttonBar = (_operationCompleted == false)
          ? ElevatedButton(
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
                    color: themeData.colorScheme.onSurface,
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
              ),
              onPressed: () async {
                IdleTime? newIdleTime;
                if (_idleTime == null) {
                  try {
                    newIdleTime = await controller.registerIdle(
                        controller.getCurrentTask()!.biId,
                        controller.getCurrentTask()!.id,
                        _reason!.id,
                        new DateTime(
                            _startDate!.year,
                            _startDate!.month,
                            _startDate!.day,
                            _startTime!.hour,
                            _startTime!.minute),
                        (_endDate != null && _endTime != null)
                            ? new DateTime(_endDate!.year, _endDate!.month,
                                _endDate!.day, _endTime!.hour, _endTime!.minute)
                            : null);
                  } catch (e) {
                    this.setState(() {
                      _error = e.toString();
                    });
                  } finally {
                    if (newIdleTime != null)
                      this.setState(() {
                        _operationCompleted = true;
                        _error = null;
                        _idleTime = newIdleTime;
                      });
                  }
                } else {
                  try {
                    newIdleTime = await controller.finishIdle(
                        controller.getCurrentTask()!.biId,
                        controller.getCurrentTask()!.id,
                        new DateTime(
                            _startDate!.year,
                            _startDate!.month,
                            _startDate!.day,
                            _startTime!.hour,
                            _startTime!.minute),
                        new DateTime(_endDate!.year, _endDate!.month,
                            _endDate!.day, _endTime!.hour, _endTime!.minute));
                  } catch (e) {
                    this.setState(() {
                      _error = e.toString();
                    });
                  } finally {
                    if (newIdleTime != null)
                      this.setState(() {
                        _operationCompleted = true;
                        _error = null;
                        _idleTime = newIdleTime;
                      });
                  }
                }
              },
            )
          : ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.yellow.shade700),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 80, vertical: 16)),
                  elevation: MaterialStateProperty.all(3.0),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)))),
              child: Text(
                "Ок",
                style: TextStyle(
                    inherit: false,
                    color: themeData.colorScheme.onSurface,
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );

      return AdaptiveDialog(
          titleIcon: Icons.timer_sharp,
          titleIconColor: _operationCompleted ? Colors.green : null,
          titleText: (!_operationCompleted)
              ? ((_idleTime == null)
                  ? "Регистрация простоя"
                  : "Завершение простоя")
              : ((widget.idleTime == null)
                  ? "Зарегистрирован простой"
                  : "Завершен активный простой"),
          body: body,
          buttonBar: buttonBar);
    });
  }
}
