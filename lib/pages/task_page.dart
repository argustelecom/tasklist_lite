import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            leading: IconButton(
              icon: Icon(Icons.chevron_left_outlined),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            centerTitle: true,
            toolbarHeight: 75,
            title: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: new Text(
                    task.name,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                new Text(
                  task.processTypeName ?? "",
                  style: TextStyle(color: Colors.white),
                ),
                if (task.getTimeLeftText() != "")
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Container(
                      width: 200,
                      child: TextField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            alignLabelWithHint: true,
                            labelText: task.getTimeLeftText(),
                            labelStyle: TextStyle(color: Colors.green),
                            fillColor: themeData.bottomAppBarColor,
                            border: InputBorder.none,
                            filled: true,
                            enabled: false,
                            // #TODO:
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
            SizedBox(
              height: 690,
              child: TabBarView(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Card(
                      child: SizedBox(
                          height: 10 * 28,
                          child: Column(children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                            ),
                            AttribValueRow(
                                attribValue: new MapEntry<String, Object?>(
                                    "Исполнители", task.assignee)),
                            AttribValueRow(
                                attribValue: new MapEntry<String, Object?>(
                                    "Адрес", task.address)),
                            AttribValueRow(
                                attribValue: new MapEntry<String, Object?>(
                                    "Адресное примечание",
                                    task.addressComment)),
                            AttribValueRow(
                                attribValue: new MapEntry<String, Object?>(
                                    "Широта", task.latitude)),
                            AttribValueRow(
                                attribValue: new MapEntry<String, Object?>(
                                    "Долгота", task.longitude)),
                            AttribValueRow(
                                attribValue: new MapEntry<String, Object?>(
                                    "Примечание", task.comment)),
                            SizedBox(
                                height: 400.0,
                                child: ListView.builder(
                                  shrinkWrap: false,
                                  itemCount: attrGroups.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return AttrGroup(
                                        task: task!,
                                        attrGroup: attrGroups.elementAt(index));
                                  },
                                ))
                          ])),
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
                    CrazyButton(
                      title: "Вернуть группе",
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
                        title: (task.taskType ?? "Выполнить задачу") +
                            (task.getTimeLeftText() != ""
                                ? " (" + task.getTimeLeftText() + ")"
                                : ""),
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
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(attrGroup,
              style: TextStyle(fontSize: 18, color: Colors.grey))),
      SizedBox(
          height: attribValuesByGroup.length * 28,
          child: ListView.builder(
            shrinkWrap: false,
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

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Table(children: [
          TableRow(children: [Text("$attrKey:   $attrValue")])
        ]));
  }
}
