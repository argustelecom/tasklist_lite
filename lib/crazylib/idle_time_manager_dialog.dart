import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/crazylib/date_picker_button.dart';
import 'package:tasklist_lite/crazylib/time_picker_button.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';
import 'package:tasklist_lite/tasklist/model/idle_time.dart';

import '../state/common_dropdown_controller.dart';
import '../tasklist/model/task.dart';
import 'adaptive_dialog.dart';
import 'crazy_progress_dialog.dart';
import 'dropdown_button.dart';

class IdleTimeManagerDialog extends StatefulWidget {
  IdleTimeManagerDialog({Key? key, this.idleTime}) : super(key: key);

  IdleTime? idleTime;

  @override
  IdleTimeManagerDialogState createState() => IdleTimeManagerDialogState();
}

class IdleTimeManagerDialogState extends State<IdleTimeManagerDialog> {
  // простой, ассоциированный с диалогом
  IdleTime? _idleTime;

  // текущие значения параметров диалога, указываемые пользователем
  IdleTimeReason? _reason;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  // выполнена ли операция
  bool _operationCompleted = false;

  // ошибка валидации или ошибка сервера
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
    return GetBuilder<CommonDropdownController>(
        builder: (commonDropdownController) {
      return GetBuilder<TaskListController>(builder: (taskListController) {
        ThemeData themeData = Theme.of(context);
        List<IdleTimeReason> idleTimeReasons =
            taskListController.taskListState.idleTimeReasons;
        Task? task = taskListController.taskListState.currentTask.value;
        if (task == null) {
          return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                  "Что-то пошло не так. Вернитесь на главную страницу и попробуйте снова."));
        }
        Widget body;
        Widget buttonBar;

        // тело диалога
        // диалог регистрации
        if (!_operationCompleted) {
          body =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // причина простоя
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Причина простоя*",
                    style: TextStyle(color: Colors.black54))),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CustomDropDownButton<IdleTimeReason>(
                  hint: "Выберите причину",
                  value: _reason == null
                      ? null
                      : idleTimeReasons.firstWhere((e) => e.id == _reason!.id),
                  borderColor: commonDropdownController.someDropdownTapped
                      ? themeData.colorScheme.primary
                      : null,
                  dropdownColor: themeData.colorScheme.primary,
                  itemsList: idleTimeReasons,
                  selectedItemBuilder: (BuildContext context) {
                    return idleTimeReasons.map<Widget>((IdleTimeReason item) {
                      return Align(
                          alignment: Alignment.centerLeft,
                          child: (Text(item.name)));
                    }).toList();
                  },
                  onTap: () {
                    commonDropdownController.someDropdownTapped = true;
                  },
                  onChanged: (value) {
                    setState(() {
                      _reason = value;
                    });
                  },
                )),
            // начало простоя
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
            // окончание простоя
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                    (_idleTime == null)
                        ? "Окончание простоя"
                        : "Окончание простоя*",
                    style: TextStyle(color: Colors.black54))),
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
            // сообщение об ошибке
            if (_error != null)
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(_error!,
                      maxLines: 3,
                      overflow: TextOverflow.clip,
                      style:
                          TextStyle(color: Colors.red, fontFamily: 'Roboto')))
          ]);
        }

        // диалог с результатами выполнения операции
        else {
          body =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // причина простоя
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Причина простоя",
                    style: TextStyle(color: Colors.black54))),
            Padding(
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
                child: Text("Начало простоя",
                    style: TextStyle(color: Colors.black54))),
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
            if (_endDate != null) ...[
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Окончание простоя",
                      style: TextStyle(color: Colors.black54))),
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
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Длительность",
                      style: TextStyle(color: Colors.black54))),
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
                  ]))
            ],
            // подсказка при регистрации открытого простоя
            if (_endDate == null)
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                    fontFamily: 'Roboto',
                                    color: Color(0xFF287BF6)),
                                textWidthBasis: TextWidthBasis.parent,
                                maxLines: 4))
                      ]))
          ]);
        }

        // панель кнопок
        // в диалоге регистрации
        if (!_operationCompleted) {
          buttonBar = ElevatedButton(
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
              if (_reason == null) {
                this.setState(() {
                  _error = "Укажите причину простоя";
                });
              } else if (_startDate == null || _startTime == null) {
                this.setState(() {
                  _error = "Укажите дату и время начала простоя";
                });
              } else if (_idleTime != null &&
                  (_endDate == null || _endTime == null)) {
                this.setState(() {
                  _error = "Укажите дату и время окончания простоя";
                });
              } else {
                if (_idleTime == null) {
                  try {
                    Task newTask = await asyncShowProgressIndicatorOverlay(
                        asyncFunction: () {
                      return taskListController.registerIdle(
                          _reason!,
                          new DateTime(
                              _startDate!.year,
                              _startDate!.month,
                              _startDate!.day,
                              _startTime!.hour,
                              _startTime!.minute),
                          (_endDate != null && _endTime != null)
                              ? new DateTime(
                                  _endDate!.year,
                                  _endDate!.month,
                                  _endDate!.day,
                                  _endTime!.hour,
                                  _endTime!.minute)
                              : null);
                    });
                    this.setState(() {
                      _operationCompleted = true;
                      _error = null;
                      _idleTime = newTask.idleTimeList?.last;
                      taskListController.taskListState.currentTask.value =
                          newTask;
                      taskListController.update();
                    });
                  } catch (e) {
                    this.setState(() {
                      _error = e.toString();
                    });
                  }
                } else {
                  try {
                    Task newTask = await asyncShowProgressIndicatorOverlay(
                        asyncFunction: () {
                      return taskListController.finishIdle(
                          new DateTime(
                              _startDate!.year,
                              _startDate!.month,
                              _startDate!.day,
                              _startTime!.hour,
                              _startTime!.minute),
                          new DateTime(_endDate!.year, _endDate!.month,
                              _endDate!.day, _endTime!.hour, _endTime!.minute));
                    });
                    this.setState(() {
                      _operationCompleted = true;
                      _error = null;
                      _idleTime = newTask.idleTimeList?.last;
                      taskListController.taskListState.currentTask.value =
                          newTask;
                      taskListController.update();
                    });
                  } catch (e) {
                    this.setState(() {
                      _error = e.toString();
                    });
                  }
                }
              }
            },
          );
        }

        // в диалоге с результатами выполнения операции
        else {
          buttonBar = ElevatedButton(
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
              // taskListController.update();
              GetDelegate routerDelegate = Get.find();
              routerDelegate.popRoute();
            },
          );
        }

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
    });
  }
}
