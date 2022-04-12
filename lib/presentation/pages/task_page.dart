import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/domain/entities/task.dart';
import 'package:tasklist_lite/presentation/controllers/comment_controller.dart';
import 'package:tasklist_lite/presentation/dialogs/idle_time_manager_dialog.dart';
import 'package:tasklist_lite/presentation/widgets/due_date_label.dart';
import 'package:tasklist_lite/presentation/widgets/figaro_logo.dart';
import 'package:tasklist_lite/presentation/widgets/object_attach_widget/widgets/object_attach_widget.dart';
import 'package:tasklist_lite/presentation/widgets/reflowing_scaffold.dart';
import 'package:tasklist_lite/presentation/widgets/tabs/history_tab.dart';
import 'package:tasklist_lite/presentation/widgets/tabs/summary_tab.dart';

import '../controllers/tasklist_controller.dart';
import '../dialogs/adaptive_dialog.dart';
import '../dialogs/close_task_dialog.dart';
import '../dialogs/info_dialog.dart';
import '../widgets/mark_filter_list.dart';
import '../widgets/tabs/works_tab.dart';

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
    ThemeData themeData = Theme.of(context);
    return DefaultTabController(
        length: 5,
        initialIndex: 0,
        child: GetBuilder<TaskListController>(
            init: TaskListController(),
            builder: (taskListController) {
              return ReflowingScaffold(
                appBar: TaskAppBar(
                    task: taskListController.taskListState.currentTask.value ??
                        Task(
                            id: 1,
                            name: "",
                            assignee: [],
                            flexibleAttribs: LinkedHashMap())),
                appBarRight: FigaroLogoHorizontal(
                    columnAlignment: MainAxisAlignment.center),
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
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.black,
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
                            Tab(
                              child: Text(
                                "Баллы",
                              ),
                            ),
                          ],
                          controller: DefaultTabController.of(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: TabBarView(children: [
                    SummaryTab(),
                    WorksTab(),
                    ObjectAttachWidget(),
                    HistoryTab(),
                    MarkTypeFilter()
                  ]))
                ]),
              );
            }));
  }
}

class TaskAppBarLeading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 40,
      icon: Icon(Icons.chevron_left_outlined),
      onPressed: () {
        GetDelegate routerDelegate = Get.find();
        routerDelegate.popRoute();
      },
    );
  }
}

class TaskAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Task task;

  const TaskAppBar({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TaskListController taskListController = Get.find();
    return GetBuilder<CommentController>(
        init: CommentController(),
        builder: (historyEventController) {
          return AppBar(
              leading: TaskAppBarLeading(),
              titleSpacing: 0.0,
              toolbarHeight: 60,
              title: task != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Row(children: [
                                    Text(
                                      task.name,
                                      style: TextStyle(
                                          inherit: false,
                                          fontSize: 20,
                                          color: Colors.black),
                                      textAlign: TextAlign.left,
                                    )
                                  ])),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Row(children: [
                                    DueDateLabel(
                                        dueDate: task.getDueDateFullText(),
                                        isOverdue: task.isTaskOverdue()),
                                  ])),
                            ],
                          ),
                          if (!task.isClosed)
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                      width: 30,
                                      height: 30,
                                      margin: EdgeInsets.only(right: 18),
                                      decoration: BoxDecoration(
                                          color: Colors.yellow.shade700,
                                          borderRadius:
                                              BorderRadius.circular(4),
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
                                        itemBuilder: (BuildContext context) =>
                                            <PopupMenuEntry>[
                                          PopupMenuItem(
                                            child: ListTile(
                                                leading: Icon(
                                                    Icons.check_circle_outline),
                                                title: Text('Завершить этап'),
                                                onTap: () async {
                                                  // если завершаем последний этап, отобразим дилог закрытия для выбора ШЗ
                                                  // у нарядов ТО этапов нет, поэтому всегда переходим к диалогу закрытия
                                                  if (task.stage == null ||
                                                      task.stage!.isLast) {
                                                    Navigator.pop(context, "");
                                                    showAdaptiveDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return CloseTaskDialog();
                                                        });
                                                  } else {
                                                    Navigator.pop(context, "");
                                                    try {
                                                      Task newTask =
                                                          await taskListController
                                                              .completeStage();
                                                      taskListController
                                                          .taskListState
                                                          .currentTask
                                                          .value = newTask;
                                                      taskListController
                                                          .update();
                                                    } catch (e) {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return InfoDialog(
                                                                text:
                                                                    "Произошла ошибка: \"$e\"");
                                                          });
                                                    }
                                                  }
                                                }),
                                            value: 1,
                                          ),
                                          PopupMenuItem(
                                            child: ListTile(
                                                leading:
                                                    Icon(Icons.access_time),
                                                title: Text((task
                                                            .getCurrentIdleTime() ==
                                                        null)
                                                    ? "Зарегистрировать простой"
                                                    : "Завершить простой"),
                                                onTap: () {
                                                  // предыдущее решение...
                                                  // GetDelegate routerDelegate =
                                                  // Get.find();
                                                  // routerDelegate.popRoute();
                                                  // ... не закрывает меню, поэтому используем Navigator
                                                  Navigator.pop(context, "");
                                                  showAdaptiveDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return IdleTimeManagerDialog(
                                                            idleTime: this
                                                                .task
                                                                .getCurrentIdleTime());
                                                      });
                                                }),
                                            value: 2,
                                          ),
                                          // Данная кнопка оставляет системный комментарий
                                          PopupMenuItem(
                                              value: 3,
                                              child: ListTile(
                                                leading:
                                                    Icon(Icons.announcement),
                                                title: Text('Проверка аварии'),
                                                onTap: () {
                                                  DefaultTabController.of(
                                                          context)!
                                                      .animateTo(3,
                                                          curve: Curves.easeOut,
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      300));
                                                  historyEventController
                                                      .addNewCrashComment(
                                                          taskListController
                                                              .taskListState
                                                              .currentTask
                                                              .value!);
                                                },
                                              ))
                                        ],
                                      ))
                                ])
                        ])
                  : Container());
        });
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

/// Ниже старая реализация гибких атрибутов через группы, остается тут на случай если она нам еще понадобится
// // Вывод группы параметров
// class AttrGroup extends StatelessWidget {
//   final Task task;
//   final String attrGroup;
//
//   const AttrGroup({Key? key, required this.task, required this.attrGroup})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     LinkedHashMap<String, Object?> attribValuesByGroup =
//         task.getAttrValuesByGroup(attrGroup);
//
//     return Column(children: [
//       // Container(
//       //     padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
//       //     child: Text(attrGroup,
//       //         style: const TextStyle(fontSize: 18, color: Colors.grey))),
//       SizedBox(
//           child: ListView.builder(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         shrinkWrap: true,
//         itemCount: attribValuesByGroup.length,
//         itemBuilder: (BuildContext context, int index) {
//           return AttribValueRow(
//               attribValue: attribValuesByGroup.entries.elementAt(index));
//         },
//       ))
//     ]);
//   }
// }
// TODO: Используется в закрытии наряда НИ надо будет поправить потом?
// Вывод строки Параметр: Значение
class AttribValueRow extends StatelessWidget {
  final MapEntry<String, Object?> attribValue;
  final maxLines = 5;

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
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      style: const TextStyle(
                          fontSize: 16.0,
                          color: Color(0xFF646363),
                          fontWeight: FontWeight.normal),
                      children: <TextSpan>[
                        TextSpan(text: "$attrKey:   "),
                        TextSpan(
                            text: attrValue,
                            style: TextStyle(color: Colors.black))
                      ]))))
    ]);
  }
}
