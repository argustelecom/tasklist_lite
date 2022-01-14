import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/date_picker_bar.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/crazylib/task_card.dart';
import 'package:tasklist_lite/crazylib/top_user_bar.dart';
import 'package:tasklist_lite/pages/task_page.dart';
// #TODO: жуткий костыль, на время повторного изучения state management
import 'package:tasklist_lite/state/application_state.dart' hide ModelBinding;
import 'package:tasklist_lite/state/tasklist_controller.dart';

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return GetBuilder<TaskListController>(builder: (controller) {
      return Padding(
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
          onChanged: (value) {
            controller.searchText = value;
          },
        ),
      );
    });
  }
}

class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskListController>(builder: (controller) {
      return SizedBox(
          // ListView с неизвестным заранее числом элементов не  может посчитать свой размер по вертикали, поэтому должны ограничивать его явно
          height: 600.0,
          child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
              shrinkWrap: true,
              itemCount: controller.getTasks().length,
              itemBuilder: (context, index) {
                return TaskCard(
                  task: controller.getTasks()[index], //taskList[index],
                  taskPageRoutName: TaskPage.routeName,
                );
              }));
    });
  }
}

class AssignedUnassignedSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // #TODO: это текущее значение фильтра назначенные/неназначенные.
    // ессно, внутри метода build stateless widget`а работать не будет
    double val = 1;
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
        child: Column(
          children: [
            //#TODO: сделать из этого компонент выбора
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                  child: Text(
                    "Назначенные ",
                    style:
                        TextStyle(color: Colors.deepPurpleAccent, fontSize: 18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                  child: Text(
                    "Неназначенные ",
                    style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              child: SliderTheme(
                child: Slider(
                  value: val,
                  onChanged: (value) {
                    val = value;
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
                    valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                    thumbShape: SliderComponentShape.noThumb,
                    overlayShape: SliderComponentShape.noOverlay),
              ),
            ),
          ],
        ));
  }
}

class TaskListPage extends StatefulWidget {
  static const String routeName = 'tasklist';

  TaskListPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  // если поменялись неявные зависимости нашей страницы (например, на странице настроек выбрали другую фикстуру, и теперь
  // список задач на нашей странице должен измениться в соответствии с этим), фреймворк вызовет метод ниже.
  void didChangeDependencies() {
    super.didChangeDependencies();
    // при этом, если страница строится в первый раз, то экземпляр TaskListController еще не создан (он появится позже,
    // в ходе метода build, когда будет строить соответствующий GetBuilder
    if (Get.isRegistered<TaskListController>()) {
      ApplicationState applicationState = ApplicationState.of(context);
      Get.delete<ApplicationState>();
      // #TODO: в ходе билда будет вызываться логика контроллера, которая вызовет repository, который, в свою очередь, хочет
      // актуальный экземпляр ApplicationState
      Get.put(applicationState);
      TaskListController taskListController = Get.find();
      taskListController.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    ApplicationState applicationState = ApplicationState.of(context);
    Get.delete<ApplicationState>();
    // #TODO: в ходе билда будет вызываться логика контроллера, которая вызовет repository, который, в свою очередь, хочет
    // актуальный экземпляр ApplicationState
    Get.put(applicationState);

    return GetBuilder<TaskListController>(
      init: TaskListController(),
      builder: (controller) {
        return ReflowingScaffold(
          appBar: TopUserBar(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SearchBar(),
              TaskList(),
              DatePickerBar(),
              AssignedUnassignedSwitch(),
            ],
          ),
        );
      },
    );
  }
}
