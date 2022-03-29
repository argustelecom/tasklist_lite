import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';
import '../state/tasklist_controller.dart';
import '../tasklist/model/task.dart';
import '../tasklist/model/work.dart';
import '../tasklist/model/worker.dart';
import 'adaptive_dialog.dart';
import 'crazy_progress_dialog.dart';

class WorksManagerDialog extends StatefulWidget {
  WorksManagerDialog({Key? key, required this.work}) : super(key: key);

  Work work;

  @override
  WorksManagerDialogState createState() => WorksManagerDialogState();
}

class WorksManagerDialogState extends State<WorksManagerDialog> {
  // исходные данные о работе и отметках
  late Work _work;

  // текущие значения параметров диалога, указываемые пользователем
  bool _notRequired = false;
  double? _amount;
  List<Worker> _workers = [];

  // кол-во баллов на сотрудника за ед.работы
  late double _marksPerWorker;

  // режим регистрации работы
  late bool _registrationMode;

  // режим удаления отметки
  bool _deletionMode = false;

  // индекс удаляемой отметки
  int _i = 0;

  // выполнена ли операция
  bool _operationCompleted = false;

  // ошибка валидации или ошибка сервера
  String? _error;

  @override
  void initState() {
    super.initState();
    _work = widget.work;
    _registrationMode =
        (_work.workDetail == null || _work.workDetail!.isEmpty) &&
            !_work.notRequired;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskListController>(builder: (taskListController) {
      ThemeData themeData = Theme.of(context);
      Task? task = taskListController.taskListState.currentTask.value;
      if (task == null) {
        return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
                "Что-то пошло не так. Вернитесь на главную страницу и попробуйте снова."));
      }
      List<Worker>? workers = task.assignee;
      Widget body;
      Widget buttonBar;

      // тело диалога
      // работа еще не зарегистрирована, но отемечена как требующаяся (режим регистрации)
      if (_registrationMode && !_operationCompleted) {
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(_work.workType.name,
                  style: TextStyle(color: Colors.black54))),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Text("Выполнять не требуется",
                    style: TextStyle(color: Colors.black54)),
                SizedBox(width: 20),
                Switch(
                    activeColor: Color(0xFFFFFFFF),
                    activeTrackColor: Color(0xFFFBC22F),
                    value: _notRequired,
                    onChanged: (value) {
                      setState(() {
                        _notRequired = value;
                      });
                    })
              ])),
          if (!_notRequired) ...[
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Объем работ (шт):",
                    style: TextStyle(color: Colors.black54))),
            Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Color(0xFF287BF6)))),
                  cursorWidth: 1,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                  ],
                  onChanged: (value) {
                    if (value == "") {
                      _amount = null;
                    } else {
                      _amount = double.parse(value);
                    }
                  },
                )),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Исполнители:",
                    style: TextStyle(color: Colors.black54))),
            ListView.builder(
                shrinkWrap: true,
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.all(0),
                    activeColor: Color(0xFF646363),
                    value: _workers.contains(workers[index]),
                    onChanged: (value) {
                      if (value == true) {
                        _workers.add(workers[index]);
                      }
                      if (value == false) {
                        _workers.remove(workers[index]);
                      }
                      setState(() {
                        _marksPerWorker = (_workers.length == 0)
                            ? 0
                            : _work.workType.marks / _workers.length;
                      });
                    },
                    title: Text(
                      workers[index].getWorkerShortNameWithTabNo(),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
            if (_workers.isNotEmpty)
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
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
                                "Каждому исполнителю, выполнившему работу, будет начислено $_marksPerWorker балла(-ов) за одну единицу работы.",
                                style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: Color(0xFF287BF6)),
                                textWidthBasis: TextWidthBasis.parent,
                                maxLines: 4))
                      ]))
          ],
          if (_error != null)
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(_error!,
                    maxLines: 3,
                    overflow: TextOverflow.clip,
                    style: TextStyle(color: Colors.red, fontFamily: 'Roboto')))
        ]);
      }
      // диалог подтверждения удаления отметки (режим удаления)
      else if (_deletionMode && !_operationCompleted) {
        body = Column(children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                  "факт регистрации работы:\n\n" +
                      "${_work.workType.name}\n" +
                      "от ${DateFormat("dd.MM.yyyy HH:mm").format(_work.workDetail![_i].date)}\n",
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center)),
          if (_error != null)
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(_error!,
                    maxLines: 3,
                    overflow: TextOverflow.clip,
                    style: TextStyle(color: Colors.red, fontFamily: 'Roboto'))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            // по нажатию на НЕТ возвращаемся в режим просмотра
            TextButton(
                onPressed: () {
                  this.setState(() {
                    _deletionMode = false;
                  });
                },
                child: Text("НЕТ", style: TextStyle(color: Color(0x99FBC22F)))),
            // по нажатию на ДА удаляем отметку
            // если еще есть отметки о работе, возвращаемся в режим просмотра
            // если нет, переходим в режим регистрации
            TextButton(
                onPressed: () async {
                  WorkDetail workDetail = _work.workDetail![_i];
                  try {
                    Work newWork = await asyncShowProgressIndicatorOverlay(
                        asyncFunction: () {
                      return taskListController.deleteWorkDetail(workDetail);
                    });
                    this.setState(() {
                      if (newWork.workDetail != null &&
                          newWork.workDetail!.isNotEmpty) {
                        _operationCompleted = true;
                        final Work oldWork = _work;
                        _work = newWork;
                        // #TODO[НИ]: копипаст устранить при переходе на WorkController
                        int oldWorkIndex = taskListController
                            .taskListState.currentTask.value!.works!
                            .indexOf(oldWork);
                        taskListController
                            .taskListState.currentTask.value!.works!
                            .replaceRange(
                                oldWorkIndex, oldWorkIndex + 1, [_work]);
                        taskListController.update();
                      } else {
                        _registrationMode = true;
                      }
                      _deletionMode = false;
                      _error = null;
                    });
                  } catch (e) {
                    this.setState(() {
                      _error = e.toString();
                    });
                  }
                },
                child: Text("ДА", style: TextStyle(color: Color(0xFFFBC22F))))
          ])
        ]);
      }
      // работа зарегистрирована или отмечена как не требующаяся (режим просмотра)
      else {
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(_work.workType.name,
                  style: TextStyle(color: Color(0xFF646363)))),
          if (!_work.notRequired) ...[
            SizedBox(height: 20),
            SizedBox(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _work.workDetail!.length,
                    itemBuilder: (context, index1) {
                      return Column(children: [
                        Row(children: [
                          Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _work
                                      .workDetail![index1].workerMarks.length,
                                  itemBuilder: (context, index2) {
                                    return Column(children: [
                                      Table(children: [
                                        TableRow(children: [
                                          Text(
                                              _work.workDetail![index1]
                                                  .workerMarks.entries
                                                  .elementAt(index2)
                                                  .key
                                                  .getWorkerShortNameWithTabNo(),
                                              style: TextStyle(
                                                  color: Color(0xFF646363))),
                                          Text(
                                              _work.workDetail![index1].amount
                                                      .toString() +
                                                  " " +
                                                  (_work.workType.units ??
                                                      "шт.") +
                                                  "\n",
                                              style: TextStyle(
                                                  color: Color(0xFF646363)))
                                        ]),
                                        TableRow(children: [
                                          Text(
                                              DateFormat("dd.MM.yyyy HH:mm")
                                                  .format(_work
                                                      .workDetail![index1]
                                                      .date),
                                              style: TextStyle(
                                                  color: Color(0xFF646363))),
                                          Text(
                                              _work.workDetail![index1]
                                                      .workerMarks.entries
                                                      .elementAt(index2)
                                                      .value
                                                      .toString() +
                                                  ' балла(-ов)',
                                              style: TextStyle(
                                                  color: Color(0xFF646363)))
                                        ])
                                      ]),
                                      if (index2 !=
                                          _work.workDetail![index1].workerMarks
                                                  .length -
                                              1)
                                        SizedBox(height: 28)
                                    ]);
                                  })),
                          // кнопка удаления отметки о работе, открывает диалог подтверждения
                          IconButton(
                            icon: Icon(Icons.delete_outlined),
                            color: Color(0xFF646363),
                            onPressed: () async {
                              this.setState(() {
                                _operationCompleted = false;
                                _registrationMode = false;
                                _deletionMode = true;
                                _i = index1;
                              });
                            },
                          )
                        ]),
                        if (index1 != _work.workDetail!.length - 1)
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider())
                      ]);
                    }))
          ],
          if (_work.notRequired)
            Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
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
                              "Работа отмечена как не требующаяся к выполнению.",
                              style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Color(0xFF287BF6)),
                              textWidthBasis: TextWidthBasis.parent,
                              maxLines: 4))
                    ]))
        ]);
      }

      // панель кнопок
      // кнопка для регистрации работы на сервере
      if (_registrationMode && !_operationCompleted) {
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
              "Зарегистрировать",
              style: TextStyle(
                  inherit: false,
                  color: themeData.colorScheme.onSurface,
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
            onPressed: () async {
              Work? newWork;
              if (_notRequired) {
                try {
                  newWork = await asyncShowProgressIndicatorOverlay(
                      asyncFunction: () {
                    return taskListController.registerWorkDetail(
                        _work.workType, true, null, null);
                  });
                } catch (e) {
                  this.setState(() {
                    _error = e.toString();
                  });
                } finally {
                  if (newWork != null) {
                    this.setState(() {
                      _operationCompleted = true;
                      _error = null;
                      final Work oldWork = _work;
                      _work = newWork!;
                      _notRequired = false;
                      _amount = null;
                      _workers = [];

                      // kostd, 24.03.2022: в _work у нас лежит instance-результат операции,
                      // выполненной на сервере, а в oldWork мы сохранили старый экземпляр.
                      // Теперь вонзим результат в правильное место мозгов контроллера.
                      // Если у контроллера предусмотрено такое место (по идее, это ведь
                      // и есть registerWorkDetail, только получающий еще oldWork, чтобы знать,
                      // на что заменяиить), то это даже вполне норм. решение и не костыль.
                      // #TODO[НИ]: сформулировать, а потом зафиксировать нашу концепцию операций
                      //  в ридми и провести доклад.
                      int oldWorkIndex = taskListController
                          .taskListState.currentTask.value!.works!
                          .indexOf(oldWork);
                      taskListController.taskListState.currentTask.value!.works!
                          .replaceRange(
                              oldWorkIndex, oldWorkIndex + 1, [_work]);
                      taskListController.update();
                    });
                  }
                }
              } else if (_amount == null || _amount == 0) {
                {
                  this.setState(() {
                    _error = "Укажите объем работ";
                  });
                }
              } else if (_workers.isEmpty) {
                {
                  this.setState(() {
                    _error = "Укажите исполнителей";
                  });
                }
              } else {
                try {
                  newWork = await asyncShowProgressIndicatorOverlay(
                      asyncFunction: () {
                    return taskListController.registerWorkDetail(
                        _work.workType, false, _amount, _workers);
                  });
                } catch (e) {
                  this.setState(() {
                    _error = e.toString();
                  });
                } finally {
                  if (newWork != null) {
                    this.setState(() {
                      _operationCompleted = true;
                      _error = null;
                      final Work oldWork = _work;
                      _work = newWork!;
                      _notRequired = false;
                      _amount = null;
                      _workers = [];

                      // #TODO[НИ]: копипаст, убрать вместе с рефакторингом на WorkController
                      int oldWorkIndex = taskListController
                          .taskListState.currentTask.value!.works!
                          .indexOf(oldWork);
                      taskListController.taskListState.currentTask.value!.works!
                          .replaceRange(
                              oldWorkIndex, oldWorkIndex + 1, [_work]);
                      taskListController.update();
                    });
                  }
                }
              }
            });
      }
      // в диалоге подтверждения удаления нижняя панель кнопок отсутствует
      else if (_deletionMode & !_operationCompleted)
        buttonBar = Center();
      // кнопка для перехода к диалогу регистрации работы из режима просмотра
      else if (!_registrationMode && !_deletionMode && !_operationCompleted) {
        // #TODO[НИ]: кнопки здесь должны быть основаны на CrazyButton. Если поведение
        // CrazyButton чем-то не устраивает, надо ее учить.
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
              "Зарегистрировать",
              style: TextStyle(
                  inherit: false,
                  color: themeData.colorScheme.onSurface,
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
            onPressed: () async {
              this.setState(() {
                _registrationMode = true;
              });
            });
      }
      // кнопка для закрытия диалога после регистрации
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
            Navigator.pop(context);
          },
        );
      }

      return AdaptiveDialog(
          titleIcon: _deletionMode
              ? null
              : (_operationCompleted
                  ? Icons.check_circle_outline
                  : Icons.build),
          titleIconColor: _operationCompleted ? Colors.green : null,
          titleText: _operationCompleted
              ? "Зарегистрирована работа"
              : (_deletionMode
                  ? "Удалить?"
                  : (_registrationMode
                      ? "Регистрация работы"
                      : "Работа зарегистрирована")),
          body: body,
          buttonBar: buttonBar);
    });
  }
}
