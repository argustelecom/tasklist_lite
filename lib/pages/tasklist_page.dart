import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/crazylib/task_card.dart';
import 'package:tasklist_lite/crazylib/top_user_bar.dart';
import 'package:tasklist_lite/pages/task_page.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';

import '../crazylib/tasklist_filter_bar.dart';

class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskListController>(builder: (controller) {
      return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
          shrinkWrap: true,
          itemCount: controller.getTasks().length,
          itemBuilder: (context, index) {
            return TaskCard(
              task: controller.getTasks()[index], //taskList[index],
              taskPageRouteName: TaskPage.routeName,
            );
          });
    });
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
      builder: (taskListController) {
        return ReflowingScaffold(
          appBar: TopUserBar(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TasklistFiltersBar(),
              Expanded(
                child: Stack(
                  children: [
                    TaskList(),
                    if (taskListController.calendarOpened)
                      // отображается только вместе с календарем. Расположен "под календарем"
                      // с точки зрения stack`а. Нужен, чтобы если пользователь ткнул мимо календаря,
                      // календарь был спрятан
                      // #TODO: если будут жалобы, что это не работает, когда кликнули на TaskListFilterBar или
                      // вообще на appBar, нужно поднять его повыше, либо срозу в body Scaffold`а страницы, либо
                      // даже под Scaffold (добавить еще один стек)
                      GestureDetector(
                          onTap: () {
                            taskListController.calendarOpened = false;
                          },
                          child: null),
                    if (taskListController.calendarOpened) InlineCalendar()
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
