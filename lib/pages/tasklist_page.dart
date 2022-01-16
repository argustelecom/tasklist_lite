import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/date_picker_bar.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/crazylib/task_card.dart';
import 'package:tasklist_lite/crazylib/top_user_bar.dart';
import 'package:tasklist_lite/pages/task_page.dart';
import 'package:tasklist_lite/state/application_state.dart';
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

class AssignedUnassignedSwitch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AssignedUnassignedSwitchState();
}

class AssignedUnassignedSwitchState extends State<AssignedUnassignedSwitch>
    with SingleTickerProviderStateMixin {
  // пришлось громоздить весь этот state with SingleTickerProviderMixin только ради
  // этого контроллера. А DefaultTabController не подходит, т.к. не позволит навесить
  // listener на событие изменения выбранного tab`а
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        TaskListController taskListController = Get.find();
        taskListController.assignedSwitch = (_tabController.index == 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: Theme.of(context).dividerColor, width: 2.0),
              ),
            ),
          ),
          TabBar(
            // цвет у selected label должен быть такой же, как у индикатора
            labelColor: Theme.of(context).indicatorColor,
            labelStyle: TextStyle(fontSize: 18),
            // а здесь пытаемся сохранить оригинальный неизменный цвет label
            unselectedLabelColor: Theme.of(context).textTheme.headline1?.color,
            tabs: [
              Tab(
                child: Text(
                  "Назначенные",
                ),
              ),
              Tab(
                child: Text(
                  'Неназначенные',
                ),
              ),
            ],
            controller: _tabController,
          ),
        ],
      ),
    );
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
