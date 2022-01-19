import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
                    padding:
                    EdgeInsets.only(bottom: 8, top: 8, left: 32, right: 8),
                  ),
                  CrazyButton(
                    title: "+ Простой",
                    onPressed: () => {},
                    padding:
                    EdgeInsets.only(bottom: 8, top: 8, left: 8, right: 32),
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
      ),
    );
  }
}
