import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/crazylib/history_event_card.dart';
import 'package:tasklist_lite/crazylib/idle_time_manager_dialog.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/crazylib/task_due_date_label.dart';
import 'package:tasklist_lite/state/history_event_controller.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';

import '../crazylib/adaptive_dialog.dart';
import '../state/tasklist_controller.dart';
import '../state/tasklist_state.dart';
import 'comment_page.dart';

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
    // Это дефолтный контроллер для управления текстовым полем
    // #Fixme: опрометчиво его создавать в методе build
    TextEditingController commentTextController;
    commentTextController = TextEditingController();

    // Это дефолтный скроллконтрроллер, используем на вкладке история, чтобы перематывать на последнее событие т.к. это удобно для пользователя
    ScrollController historyScrollController = new ScrollController();

    return DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: GetBuilder<TaskListController>(
            init: TaskListController(),
            builder: (taskListController) {
              return ReflowingScaffold(
                  appBar: TaskAppBar(
                      task:
                          taskListController.taskListState.currentTask.value ??
                              Task(
                                  id: 1,
                                  name: "",
                                  flexibleAttribs: LinkedHashMap(),
                                  biId: 1)),
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
                            labelColor: Colors.black,
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
                            ],
                            controller: DefaultTabController.of(context),
                          ),
                        ],
                      ),
                    ),
                    //Заменил SizedBox на Expanded, чтобы не ругался на bottom overflow
                    Expanded(
                        child: TabBarView(children: [
                      Padding(
                        padding:
                            EdgeInsets.only(left: 12, right: 12, bottom: 12),
                        child: Card(
                          child: SizedBox(
                              height: 400.0,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: taskListController
                                      .taskListState.currentTask.value
                                      ?.getAttrGroups()
                                      .length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return AttrGroup(
                                        task: taskListController.taskListState
                                                .currentTask.value ??
                                            Task(
                                                id: 1,
                                                name: "",
                                                flexibleAttribs:
                                                    LinkedHashMap(),
                                                biId: 1),
                                        attrGroup: taskListController
                                                .taskListState.currentTask.value
                                                ?.getAttrGroups()
                                                .elementAt(index) ??
                                            "");
                                  })),
                          elevation: 3,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Card(
                          child: Text("Здесь будут работы"),
                          elevation: 3,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Card(
                          child: Text("Здесь будут вложения"),
                          elevation: 3,
                        ),
                      ),
                      GetBuilder<HistoryEventController>(
                          init: HistoryEventController(),
                          builder: (historyEventController) {
                            return Padding(
                                padding: EdgeInsets.only(
                                    left: 12, right: 12, bottom: 12),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                          itemCount: historyEventController
                                              .getHistoryEvents()
                                              .length,
                                          controller: historyScrollController,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return InkWell(
                                                child: HistoryEventCard(
                                                    maxLines: 10,
                                                    comment: historyEventController
                                                            .getHistoryEvents()[
                                                        index]),
                                                onTap: () {
                                                  historyEventController
                                                      .setCurrentComment(
                                                          historyEventController
                                                                  .getHistoryEvents()[
                                                              index]);
                                                  GetDelegate routerDelegate =
                                                      Get.find();
                                                  routerDelegate.toNamed(
                                                      CommentPage.routeName);
                                                });
                                          }),
                                    ),
                                    // Текстовое поле ввода комментария
                                    Padding(
                                      padding: EdgeInsets.only(top: 16),
                                      child: Focus(
                                        onFocusChange: (value) {
                                          Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () {
                                            historyEventController
                                                .setOnTextFieldFocused(value);
                                          });
                                        },
                                        child: TextField(
                                            textInputAction:
                                                TextInputAction.send,
                                            keyboardType: TextInputType.text,
                                            textAlign: TextAlign.start,
                                            decoration: InputDecoration(
                                              hintText: "Ваш комментарий",
                                              hintStyle:
                                                  TextStyle(fontSize: 14),
                                              fillColor:
                                                  themeData.bottomAppBarColor,
                                              border: InputBorder.none,
                                              filled: true,
                                              suffixIcon: IconButton(
                                                tooltip: 'С уведомлением',
                                                icon: Icon(
                                                    historyEventController
                                                            .getIsAlarmComment()
                                                        ? Icons.notifications
                                                        : Icons
                                                            .notifications_off,
                                                    // size: 30,
                                                    color: Colors.black),
                                                onPressed: () {
                                                  historyEventController
                                                      .changeIsAlarmComment();
                                                },
                                              ),
                                              isCollapsed: false,
                                            ),
                                            onSubmitted: (text) {
                                              historyEventController.addComment(
                                                  commentTextController.text,
                                                  historyEventController
                                                      .getIsAlarmComment(),
                                                  taskListController
                                                      .taskListState
                                                      .currentTask
                                                      .value!);
                                              commentTextController.clear();
                                              historyScrollController.animateTo(
                                                historyScrollController
                                                    .position.maxScrollExtent,
                                                curve: Curves.easeOut,
                                                duration: const Duration(
                                                    milliseconds: 300),
                                              );
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            minLines: 1,
                                            maxLines: 5,
                                            controller: commentTextController),
                                      ),
                                    ),
                                    Visibility(
                                        visible: historyEventController
                                            .getOnTextFieldFocused(),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 8, right: 16),
                                          child: Row(
                                              children: [
                                                TextButton(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 4,
                                                        right: 8,
                                                        left: 8,
                                                        bottom: 4),
                                                    child: const Text(
                                                        'Отправить',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14)),
                                                  ),
                                                  style: ButtonStyle(
                                                      shape: MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      32))),
                                                      padding: MaterialStateProperty.all<
                                                              EdgeInsets>(
                                                          EdgeInsets.all(2)),
                                                      backgroundColor:
                                                          MaterialStateProperty.all<Color>(
                                                              Colors.yellow.shade700)),
                                                  onPressed: () {
                                                    historyEventController.addComment(
                                                        commentTextController
                                                            .text,
                                                        historyEventController
                                                            .getIsAlarmComment(),
                                                        taskListController
                                                            .taskListState
                                                            .currentTask
                                                            .value!);
                                                    commentTextController
                                                        .clear();
                                                    historyScrollController
                                                        .animateTo(
                                                      historyScrollController
                                                          .position
                                                          .maxScrollExtent,
                                                      curve: Curves.easeOut,
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                    );
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                  },
                                                ),
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end),
                                        ))
                                  ],
                                ));
                          })
                    ]))
                  ]));
            }));
  }
}

class TaskAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Task task;

  const TaskAppBar({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TaskListState taskListState = Get.find();
    return GetBuilder<HistoryEventController>(
        init: HistoryEventController(),
        builder: (historyEventController) {
          return AppBar(
              leading: IconButton(
                iconSize: 40,
                icon: Icon(Icons.chevron_left_outlined),
                onPressed: () {
                  GetDelegate routerDelegate = Get.find();
                  routerDelegate.popRoute();
                },
              ),
              titleSpacing: 0.0,
              toolbarHeight: 60,
              title: Row(
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
                              TaskDueDateLabel(task: task),
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
                                    borderRadius: BorderRadius.circular(4),
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
                                    const PopupMenuItem(
                                      child: ListTile(
                                        leading:
                                            Icon(Icons.check_circle_outline),
                                        title: Text('Завершить этап'),
                                      ),
                                      value: 0,
                                    ),
                                    PopupMenuItem(
                                      child: ListTile(
                                          leading: Icon(Icons.access_time),
                                          title: Text(
                                              (task.getCurrentIdleTime() ==
                                                      null)
                                                  ? "Зарегистрировать простой"
                                                  : "Завершить простой"),
                                          onTap: () {
                                            GetDelegate routerDelegate =
                                                Get.find();
                                            routerDelegate.popRoute();

                                            showAdaptiveDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return IdleTimeManagerDialog(
                                                      idleTime: this
                                                          .task
                                                          .getCurrentIdleTime());
                                                });
                                          }),
                                      value: 1,
                                    ),
                                    if (task.assignee != null)
                                      const PopupMenuItem(
                                        child: ListTile(
                                          leading:
                                              Icon(Icons.file_upload_outlined),
                                          title: Text('Вернуть группе'),
                                        ),
                                        value: 2,
                                      ),
                                    if (task.assignee == null)
                                      const PopupMenuItem(
                                        child: ListTile(
                                          leading: Icon(
                                              Icons.file_download_outlined),
                                          title: Text('Взять себе'),
                                        ),
                                        value: 3,
                                      ),
                                    // Данная кнопка оставляет системный комментарий
                                    PopupMenuItem(
                                        value: 4,
                                        child: ListTile(
                                          leading: Icon(Icons.announcement),
                                          title: Text('Проверка аварии'),
                                          onTap: () {
                                            DefaultTabController.of(context)!
                                                .animateTo(3,
                                                    curve: Curves.easeOut,
                                                    duration: const Duration(
                                                        milliseconds: 300));
                                            historyEventController
                                                .addNewCrashComment(
                                                    taskListState
                                                        .currentTask.value!);
                                          },
                                        ))
                                  ],
                                ))
                          ])
                  ]));
        });
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
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
              style: const TextStyle(fontSize: 18, color: Colors.grey))),
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
              child: RichText(
                  text: TextSpan(
                      style: const TextStyle(
                          fontSize: 16.0,
                          color: Color(0xFF646363),
                          fontWeight: FontWeight.normal),
                      children: <TextSpan>[
                    TextSpan(text: "$attrKey:   "),
                    TextSpan(
                        text: attrValue, style: TextStyle(color: Colors.black))
                  ]))))
    ]);
  }
}
