import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tasklist_lite/crazylib/idle_time_manager_dialog.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';

class TaskPage extends StatefulWidget {
  static const String routeName = 'task';

  TaskPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  @override
  Widget build(BuildContext context) {
    Task? task;
    if (ModalRoute.of(context)!.settings.arguments != null) {
      task = ModalRoute.of(context)!.settings.arguments as Task;
    }
    ThemeData themeData = Theme.of(context);
    ApplicationState applicationState = ApplicationState.of(context);

    if (task == null)

      /// TODO облагородить или создать страницу ошибки
      return DefaultTabController(
          length: 4,
          child: ReflowingScaffold(
              body: Text(
                  "Что-то пошло не так. Вернитесь на главную страницу и попробуйте снова.")));
    else {
      LinkedHashSet<String> attrGroups = task.getAttrGroups();

      return DefaultTabController(
          length: 4,
          child: ReflowingScaffold(
              appBar: TaskAppBar(task: task),
              body: Column(children: [
                // нужен чтобы ограничить высоту tabBar`а ниже
                SizedBox(
                  height: 40,
                  // чтобы сделать indicator для unselected tabs в tabBar`е ниже, подложим под него Decoration с подчеркиванием,
                  // как предлагается https://stackoverflow.com/questions/52028730/how-to-create-unselected-indicator-for-tab-bar-in-flutter
                  child: Stack(
                    fit: StackFit.passthrough,
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: themeData.dividerColor, width: 2.0),
                          ),
                        ),
                      ),
                      TabBar(
                        isScrollable: true,
                        labelColor: Colors.black,
                        labelStyle: TextStyle(fontSize: 18),
                        unselectedLabelStyle:
                            TextStyle(color: Colors.grey, fontSize: 18),
                        tabs: [
                          Tab(
                            child: Text(
                              "Сведения",
                            ),
                          ),
                          Tab(
                            child: Text(
                              'Работы',
                            ),
                          ),
                          Tab(
                            child: Text(
                              "Вложения",
                            ),
                          ),
                          Tab(
                            child: Text(
                              "История",
                            ),
                          ),
                        ],
                        controller: DefaultTabController.of(context),
                      ),
                    ],
                  ),
                ),
                //Заменил SizedBox на Expanded, чтобы не ругался на bottom overflow
                Expanded(
                    child: TabBarView(children: [
                  Padding(
                    padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    child: Card(
                      child: SizedBox(
                          height: 400.0,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: attrGroups.length,
                              itemBuilder: (BuildContext context, int index) {
                                return AttrGroup(
                                    task: task!,
                                    attrGroup: attrGroups.elementAt(index));
                              })),
                      elevation: 3,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Card(
                      child: Text("Здесь будут работы"),
                      elevation: 3,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Card(
                      child: Text("Здесь будут вложения"),
                      elevation: 3,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Card(
                          child: Text("Здесь будет история"), elevation: 3))
                ]))
              ])));
    }
  }
}

class TaskAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Task task;

  const TaskAppBar({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        leading: IconButton(
          iconSize: 40,
          icon: Icon(Icons.chevron_left_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0.0,
        toolbarHeight: 100,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Text(
                      task.processTypeName ?? " ",
                      style: TextStyle(
                          inherit: false, fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.left,
                    )
                  ])),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    Text(
                      task.name,
                      style: TextStyle(
                          inherit: false, fontSize: 20, color: Colors.black),
                      textAlign: TextAlign.left,
                    )
                  ])),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    Text(
                      "КС: " + task.getDueDateFullText(),
                      style: TextStyle(
                          inherit: false,
                          fontSize: 14,
                          color: task.isOverdue() ? Colors.red : Colors.green),
                      textAlign: TextAlign.left,
                    )
                  ])),
            ],
          ),
          if (!task.isClosed)
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.only(right: 18),
                  decoration: BoxDecoration(
                      color: Colors.yellow.shade700,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black38,
                            blurRadius: 0.6,
                            spreadRadius: 0.6,
                            offset: Offset(0.0, 1.2)),
                      ]),
                  child: PopupMenuButton(
                    icon: Icon(Icons.menu),
                    iconSize: 28,
                    padding: EdgeInsets.all(0.0),
                    elevation: 3,
                    offset: Offset(0, 50),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      const PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.check_circle_outline),
                          title: Text('Завершить этап'),
                        ),
                        value: 0,
                      ),
                      PopupMenuItem(
                        child: ListTile(
                            leading: Icon(Icons.access_time),
                            title: Text((task.idleTime == null)
                                ? "Зарегистрировать простой"
                                : "Завершить простой"),
                            onTap: () {
                              Navigator.pop(context, "");
                              showModalBottomSheet(
                                  context: context,
                                  isDismissible: false,
                                  isScrollControlled: true,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6)),
                                  ),
                                  constraints: BoxConstraints(
                                      minHeight:
                                          MediaQuery.of(context).size.height -
                                              90,
                                      maxHeight:
                                          MediaQuery.of(context).size.height -
                                              90),
                                  builder: (BuildContext context) {
                                    return IdleTimeManagerDialog(
                                        task: this.task,
                                        idleTime: this.task.idleTime);
                                  });
                            }),
                        value: 1,
                      ),
                      if (task.assignee != null)
                        const PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.file_upload_outlined),
                            title: Text('Вернуть группе'),
                          ),
                          value: 2,
                        ),
                      if (task.assignee == null)
                        const PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.file_download_outlined),
                            title: Text('Взять себе'),
                          ),
                          value: 3,
                        )
                    ],
                  ))
            ])
        ]));
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}

// Вывод группы параметров
class AttrGroup extends StatelessWidget {
  final Task task;
  final String attrGroup;

  const AttrGroup({Key? key, required this.task, required this.attrGroup})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LinkedHashMap<String, Object?> attribValuesByGroup =
        task.getAttrValuesByGroup(attrGroup);

    return Column(children: [
      Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(attrGroup,
              style: const TextStyle(fontSize: 18, color: Colors.grey))),
      SizedBox(
          child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shrinkWrap: true,
        itemCount: attribValuesByGroup.length,
        itemBuilder: (BuildContext context, int index) {
          return AttribValueRow(
              attribValue: attribValuesByGroup.entries.elementAt(index));
        },
      ))
    ]);
  }
}

// Вывод строки Параметр: Значение
class AttribValueRow extends StatelessWidget {
  final MapEntry<String, Object?> attribValue;

  const AttribValueRow({Key? key, required this.attribValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String attrKey = attribValue.key;
    String attrValue = (attribValue.value == null)
        ? ""
        : (attribValue.value.runtimeType == DateTime
            ? DateFormat("dd.MM.yyyy HH:mm")
                .format(DateTime.parse(attribValue.value.toString()))
            : attribValue.value.toString());

    return Row(children: [
      Expanded(
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: RichText(
                  text: TextSpan(
                      style: const TextStyle(
                          fontSize: 16.0,
                          color: Color(0xFF646363),
                          fontWeight: FontWeight.normal),
                      children: <TextSpan>[
                    TextSpan(text: "$attrKey:   "),
                    TextSpan(
                        text: attrValue, style: TextStyle(color: Colors.black))
                  ]))))
    ]);
  }
}
