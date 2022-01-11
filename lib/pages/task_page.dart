import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tasklist_lite/crazylib/bottom_button_bar.dart';
import 'package:tasklist_lite/crazylib/crazy_button.dart';
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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
                    task == null ? "test text for null task" : task.name,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                new Text(
                  task == null
                      ? "test processTypeName for null task"
                      : task.processTypeName ??
                          "Аварийно-восстановительные работы",
                  style: TextStyle(color: Colors.white),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Container(
                    width: 200,
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        labelText: "КВ: 01.02.2022 10:00",
                        labelStyle: TextStyle(color: Colors.green),
                        fillColor: themeData.bottomAppBarColor,
                        border: InputBorder.none,
                        filled: true,
                        enabled: false,
                        // #TODO:
                        isCollapsed: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Column(children: [
            SizedBox(
              height: 40,
              child: TabBar(
                isScrollable: true,
                indicatorColor: Colors.deepPurple,
                //indicator: BoxDecoration(color: Colors.green, shape: BoxShape.rectangle),
                tabs: [
                  Tab(
                    child: Text(
                      "Сведения",
                      style: TextStyle(
                          color: DefaultTabController.of(context)?.index == 1
                              ? Colors.black
                              : Colors.blueGrey,
                          fontSize: 18),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Работы',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Вложения",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "История",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                    ),
                  ),
                ],
                controller: DefaultTabController.of(context),
              ),
            ),
            SizedBox(
              height: 690,
              child: TabBarView(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Card(
                      child: Text("здесь будут сведения"),
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
                        title: "Выезд на объект (КС: 10h 5м)",
                        onPressed: () => {},
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 32)),
                  ],
                )
              ],
            )
          ]),
          bottomNavigationBar: BottomButtonBar()),
    );
  }
}
