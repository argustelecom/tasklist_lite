import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/crazylib/task_card.dart';
import 'package:tasklist_lite/layout/adaptive.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';

import '../crazylib/figaro_logo.dart';
import '../crazylib/tasklist_filter_bar.dart';
import '../crazylib/top_user_bar.dart';

class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskListController>(builder: (controller) {
      return ListView.builder(
          padding: EdgeInsets.symmetric(
              vertical: 0, horizontal: isDisplayDesktop(context) ? 8 : 32),
          shrinkWrap: true,
          itemCount: controller.getTasks().length,
          itemBuilder: (context, index) {
            return TaskCard(
              task: controller.getTasks()[index], //taskList[index],
            );
          });
    });
  }
}

// #TODO: ничто не мешает ему быть Stateless
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

    return GetBuilder<TaskListController>(
      init: TaskListController(),
      builder: (taskListController) {
        return ReflowingScaffold(
          appBarLeft: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProfileIconButton(),
              UserInfoBar(),
            ],
          ),
          appBar: isDisplayDesktop(context)
              ? TasklistFiltersBar() as PreferredSizeWidget
              : TopUserBar(),
          appBarRight: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              NotificationsIconButton(),
              LogoutIconButton(),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (!(isDisplayDesktop(context))) TasklistFiltersBar(),
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
          bodyRight:
              FigaroLogoHorizontal(columnAlignment: MainAxisAlignment.start),
        );
      },
    );
  }
}
