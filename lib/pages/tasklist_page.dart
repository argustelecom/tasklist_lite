import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/bottom_button_bar.dart';
import 'package:tasklist_lite/crazylib/task_card.dart';
import 'package:tasklist_lite/crazylib/top_user_bar.dart';
import 'package:tasklist_lite/pages/task_page.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:tasklist_lite/tasklist/task_repository.dart';
import 'package:tasklist_lite/theme/tasklist_theme_data.dart';

class TaskListPage extends StatefulWidget {
  static const String routeName = 'tasklist';

  TaskListPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    ApplicationState applicationState = ApplicationState.of(context);
    Get.delete<ApplicationState>();
    Get.put(applicationState);
    TaskRepository taskRepository = Get.find();
    List<Task> taskList = taskRepository.getTasks();
    // #TODO: это текущее значение фильтра назначенные/неназначенные.
    double val = 1;

    return Scaffold(
        appBar: TopUserBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
              child: TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Номер наряда",
                  fillColor: themeData.bottomAppBarColor,
                  border: InputBorder.none,
                  filled: true,
                  suffixIcon: IconButton(
                    tooltip: 'Поиск',
                    icon: const Icon(Icons.search_outlined),
                    onPressed: () {},
                  ),
                  isCollapsed: false,
                ),
              ),
            ),
            SizedBox(
                // ListView с неизвестным заранее числом элементов не  может посчитать свой размер по вертикали, поэтому должны ограничивать его явно
                height: 600.0,
                child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                    shrinkWrap: true,
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: taskList[index],
                        taskPageRoutName: TaskPage.routeName,
                      );
                    })),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
              child: Card(
                  child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'На вчера',
                      icon: const Icon(Icons.chevron_left_outlined),
                      onPressed: () {},
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: new Icon(
                            Icons.date_range_outlined,
                          ),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                                context: context,
                                // #TODO: нужно брать из TaskListState
                                initialDate: DateTime.now(), // Refer step 1
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2025),
                                builder: (context, child) {
                                  return Theme(
                                      data: TaskListThemeData.darkThemeData
                                          .copyWith(
                                              indicatorColor: Colors.white),
                                      // #TODO: размеры не работают
                                      child: SizedBox(
                                        height: 100,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                2 /
                                                3,
                                        child: child ?? Text("null"),
                                      ));
                                }); /*
                            if (picked != null && picked != selectedDate)
                              setState(() {
                                selectedDate = picked;
                              });*/
                          },
                        ),
                        Text("12 января 2022"),
                      ],
                    ),
                    IconButton(
                      tooltip: 'На завтра',
                      icon: const Icon(Icons.chevron_right_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
              ])),
            ),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                child: Column(
                  children: [
                    //#TODO: сделать из этого компонент выбора
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                          child: Text(
                            "Назначенные ",
                            style: TextStyle(
                                color: Colors.deepPurpleAccent, fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                          child: Text(
                            "Неназначенные ",
                            style:
                                TextStyle(color: Colors.blueGrey, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                      child: SliderTheme(
                        child: Slider(
                          value: val,
                          onChanged: (value) {
                            setState(() {
                              val = value;
                            });
                          },
                          activeColor: Colors.deepPurpleAccent,
                          inactiveColor: Colors.blueGrey,
                          min: 0,
                          max: 2,
                          divisions: 2,
                          label: "value = $val",
                        ),
                        data: SliderTheme.of(context).copyWith(
                            showValueIndicator: ShowValueIndicator.always,
                            valueIndicatorShape:
                                PaddleSliderValueIndicatorShape(),
                            thumbShape: SliderComponentShape.noThumb,
                            overlayShape: SliderComponentShape.noOverlay),
                      ),
                    ),
                  ],
                )),
          ],
        ),
        bottomNavigationBar: BottomButtonBar());
  }
}
