import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tasklist_lite/crazylib/crazy_button.dart';
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              // нужен чтобы ограничить высоту tabBar`а ниже
              child: SizedBox(
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
                      labelColor: themeData.textTheme.headline1?.color,
                      labelStyle:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      unselectedLabelStyle: TextStyle(fontSize: 18),
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
            ),
            //Заменил SizedBox на Expanded, чтобы не ругался на bottom overflow
            Expanded(
              child: TabBarView(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
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
                      elevation: 5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Card(
                      child: Text("Здесь будут работы"),
                      elevation: 5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Card(
                      child: Text("Здесь будут вложения"),
                      elevation: 5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Card(
                      child: Text("Здесь будет история"),
                      elevation: 5,
                    ),
                  ),
                ],
                // ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (task.assignee != null)
                      CrazyButton(
                        title: "Вернуть группе",
                        onPressed: () => {},
                        padding: EdgeInsets.only(
                            bottom: 8, top: 8, left: 32, right: 8),
                      ),
                    if (task.assignee == null)
                      CrazyButton(
                        title: "Взять себе",
                        onPressed: () => {},
                        padding: EdgeInsets.only(
                            bottom: 8, top: 8, left: 32, right: 8),
                      ),
                    CrazyButton(
                      title: "+ Простой",
                      onPressed: () => {},
                      padding: EdgeInsets.only(
                          bottom: 8, top: 8, left: 8, right: 32),
                    ),
                  ],
                ),
                Row(
                  children: [
                    CrazyButton(
                        title: (task.taskType ?? "Выполнить задачу"),
                        onPressed: () => {},
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 32)),
                  ],
                )
              ],
            )
          ]),
        ),
      );
    }
  }
}

class TaskAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Task task;

  const TaskAppBar({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 0),
        child: AppBar(
            leading: IconButton(
              iconSize: 40,
              icon: Icon(Icons.chevron_left_outlined),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            titleSpacing: 0.0,
            toolbarHeight: 100,
            title: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      Text(
                        task.processTypeName ?? " ",
                        style: TextStyle(
                            inherit: false,
                            //fontWeight: FontWeight.normal,
                            fontSize: 14),
                        textAlign: TextAlign.left,
                      )
                    ])),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Row(children: [
                      Text(
                        task.name,
                        style: TextStyle(
                            inherit: false,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
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
                            fontWeight: FontWeight.normal,
                            color: task.isOverdue() ? Colors.red : Colors.green,
                            fontSize: 14),
                        textAlign: TextAlign.left,
                      )
                    ])),
              ],
            )));
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
              style: TextStyle(fontSize: 18, color: Colors.grey))),
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
              child: Text("$attrKey:   $attrValue")))
    ]);
  }
}
