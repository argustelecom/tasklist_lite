import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../pages/task_page.dart';
import '../state/common_dropdown_controller.dart';
import '../state/tasklist_controller.dart';
import '../tasklist/model/close_code.dart';
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommonDropdownController>(
        builder: (commonDropdownController) {
      return GetBuilder<TaskListController>(builder: (taskListController) {
        ThemeData themeData = Theme.of(context);

        Widget body = (!_operationCompleted)
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    ))
              ])
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                            taskListController.taskListState.currentTask.value!
                                .getAssigneeListToText(true)))),
                if (_error != null)
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(_error!,
                          maxLines: 3,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              color: Colors.red, fontFamily: 'Roboto')))
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
                  "Закрыть наряд",
                  style: TextStyle(
                      inherit: false,
                      color: themeData.colorScheme.onSurface,
                      fontWeight: FontWeight.normal,
                      fontSize: 16),
                ),
                onPressed: () async {
                  try {
                    _operationCompleted =
                        (await taskListController.completeOrder(
                            taskListController
                                .taskListState.currentTask.value!.id,
                            _closeCode!.id))!;
                  } catch (e) {
                    this.setState(() {
                      _error = e.toString();
                    });
                  } finally {
                    if (_operationCompleted)
                      this.setState(() {
                        _error = null;
                      });
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
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              );

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
