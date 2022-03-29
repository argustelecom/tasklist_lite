import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../pages/task_page.dart';
import '../state/common_dropdown_controller.dart';
import '../state/tasklist_controller.dart';
import '../tasklist/model/close_code.dart';
import '../tasklist/model/task.dart';
import 'adaptive_dialog.dart';
import 'dropdown_button.dart';

class CloseTaskDialog extends StatefulWidget {
  CloseTaskDialog({Key? key}) : super(key: key);

  @override
  CloseTaskDialogState createState() => CloseTaskDialogState();
}

class CloseTaskDialogState extends State<CloseTaskDialog> {
  CloseCode? _closeCode;
  bool _operationCompleted = false;
  String? _error;

  // TODO: временно необходимый параметр, пока не получаем исполнителей по закрытой задаче
  String? _workers;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommonDropdownController>(
        builder: (commonDropdownController) {
      return GetBuilder<TaskListController>(builder: (taskListController) {
        ThemeData themeData = Theme.of(context);

        Widget body;
        Widget buttonBar;

        // тело диалога
        // режим регистрации закрытия задачи
        if (!_operationCompleted) {
          body =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // шифр закрытия
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Шифр закрытия*",
                    style: TextStyle(color: Colors.black54))),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CustomDropDownButton<CloseCode>(
                  hint: "Выбрать шифр закрытия",
                  value: _closeCode,
                  borderColor: commonDropdownController.someDropdownTapped
                      ? themeData.colorScheme.primary
                      : null,
                  dropdownColor: themeData.colorScheme.primary,
                  itemsList: taskListController.taskListState.closeCodes,
                  selectedItemBuilder: (BuildContext context) {
                    return taskListController.taskListState.closeCodes
                        .map<Widget>((CloseCode item) {
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
                      _closeCode = value;
                    });
                  },
                )),
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
        // диалог с результатами завершения задачи
        else {
          body =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // шифр закрытия
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: AttribValueRow(
                    attribValue: MapEntry("Шифр закрытия", _closeCode))),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: AttribValueRow(
                    attribValue: MapEntry(
                        "Исполнитель",
                        // taskListController.taskListState.currentTask.value!
                        //     .getAssigneeListToText(true)
                        // TODO: временно необходимый параметр, пока не получаем исполнителей по закрытой задаче
                        _workers)))
          ]);
        }

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
              "Закрыть наряд",
              style: TextStyle(
                  inherit: false,
                  color: themeData.colorScheme.onSurface,
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
            onPressed: () async {
              if (_closeCode == null) {
                this.setState(() {
                  _error = "Укажите шифр закрытия";
                });
              } else {
                try {
                  Task newTask =
                      await taskListController.closeOrder(_closeCode!);
                  this.setState(() {
                    _operationCompleted = true;
                    _error = null;
                    // TODO: временно необходимый параметр, пока не получаем исполнителей по закрытой задаче
                    _workers = taskListController
                        .taskListState.currentTask.value!
                        .getAssigneeListToText(true);
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
            },
          );
        } else {
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
              Navigator.pop(context);
              Navigator.pop(context);
            },
          );
        }

        return AdaptiveDialog(
            titleIcon: Icons.check_circle_outline,
            titleIconColor: _operationCompleted ? Colors.green : null,
            titleText:
                !_operationCompleted ? "Закрытие наряда" : "Наряд закрыт",
            body: body,
            buttonBar: buttonBar);
      });
    });
  }
}
