import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/crazylib/history_event_card.dart';
import 'package:tasklist_lite/crazylib/idle_time_manager_dialog.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/crazylib/due_date_label.dart';
import 'package:tasklist_lite/state/comment_controller.dart';
import 'package:tasklist_lite/state/textFieldColoraizer.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/widgets/object_attach_widget/widgets/object_attach_widget.dart';
import '../crazylib/adaptive_dialog.dart';
import '../crazylib/close_task_dialog.dart';
import '../crazylib/crazy_progress_dialog.dart';
import '../crazylib/mark_filter_list.dart';
import '../crazylib/works_tab.dart';
import '../state/tasklist_controller.dart';
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

    // #Fixme: опрометчиво его создавать в методе build
    //Создаем кастомный TextEditingController. Используем для управления стилями текста в TextField и не только
    TextEditingController commentTextController = TextFieldColorizer(
      {
        r'_(.*?)\_': TextStyle(
            fontStyle: FontStyle.italic, shadows: kElevationToShadow[2]),
        '~(.*?)~': TextStyle(
            decoration: TextDecoration.lineThrough,
            shadows: kElevationToShadow[2]),
        r'\*(.*?)\*': TextStyle(
            fontWeight: FontWeight.bold, shadows: kElevationToShadow[2]),
      },
    );

    // Это дефолтный скроллконтрроллер, используем на вкладке история, чтобы перематывать на последнее событие т.к. это удобно для пользователя
    ScrollController historyScrollController = new ScrollController();

    return DefaultTabController(
        length: 5,
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
                              assignee: [],
                              flexibleAttribs: LinkedHashMap())),
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
                            Padding(
                              padding:
                              EdgeInsets.only(left: 12, right: 12, bottom: 12),
                              child: Card(
                                  elevation: 3,
                                  child: Column(
                                    children: [
                                      Row(
                                          children: [
                                            //Это тут для того, чтобы наряды ТО у нас не падали т.к. у них нет этапа
                                            if (taskListController.taskListState
                                                .currentTask.value!.stage !=
                                                null)
                                              Column(
                                                children: [
                                                  Padding(
                                                      padding: EdgeInsets
                                                          .fromLTRB(
                                                          16, 8, 16, 12),
                                                      child: Row(children: [
                                                        Text(
                                                            "${taskListController
                                                                .taskListState
                                                                .currentTask
                                                                .value!.stage!
                                                                .name}",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                      ])),
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .fromLTRB(
                                                        16, 8, 16, 0),
                                                    child: Row(children: [
                                                  DueDateLabel(
                                                      dueDate: taskListController
                                                              .taskListState
                                                              .currentTask
                                                              .value!.stage!
                                                              .getDueDateFullText(),
                                                      isOverdue:
                                                          taskListController
                                                              .taskListState
                                                              .currentTask
                                                              .value!
                                                              .isStageOverdue()
                                                    ]),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .fromLTRB(
                                                        16, 8, 16, 0),
                                                    child: Row(children: [
                                                      Text(
                                                    "${taskListController.taskListState.currentTask.value!.stage!.getTimeLeftStageText()}",
                                                    style: TextStyle(color:
                                                          taskListController
                                                                .taskListState
                                                                .currentTask
                                                                .value!
                                                                .stage!
                                                                .getTimeLeftStageText()
                                                                .contains('СКВ')
                                                            ? Colors.red
                                                            : Colors.green,
                                                        fontSize: 14),
                                                  ),
                                                ]),
                                              ),
                                            ],
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                              ),
                                            //Клизма
                                            //Это тут для того, чтобы наряды ТО у нас не падали т.к. у них нет этапа
                                            if (taskListController.taskListState
                                                .currentTask.value!.stage !=
                                                null)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 12, right: 16),
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // #TODO: в макете у иконки еще elevation присутствует, с ходу не получилось сделать
                                                IconButton(
                                                    onPressed: () async {
                                                      // Есть map_launcher, но он в вебе не работает (ругается)
                                                      // но можно открывать урл к yandex maps например
                                                      // https://stackoverflow.com/questions/52052232/flutter-url-launcher-google-maps
                                                      String baseUrl =
                                                          "https://yandex.ru/maps/?l=map&z=11";
                                                      // параметры открытия яндекса см. https://yandex.com/dev/yandex-apps-launch/maps/doc/concepts/yandexmaps-web.html
                                                      // #TODO: если бы у нас были текущиие координаты (а они будут в следующих версиях), можно открывать прям маршрут,
                                                      // см. Plot Route https://yandex.com/dev/yandex-apps-launch/maps/doc/concepts/yandexmaps-web.html#yandexmaps-web__buildroute
                                                      if ((taskListController
                                                                  .taskListState
                                                                  .currentTask
                                                                  .value!
                                                                  .latitude !=
                                                              null) &&
                                                              (taskListController
                                                                  .taskListState
                                                                  .currentTask
                                                                  .value!
                                                                  .longitude !=
                                                                  null)) {
                                                            baseUrl = baseUrl +
                                                                "&pt=" +
                                                                taskListController
                                                                    .taskListState
                                                                    .currentTask
                                                                    .value!
                                                                    .latitude
                                                                    .toString() +
                                                                "," +
                                                                taskListController
                                                                    .taskListState
                                                                    .currentTask
                                                                    .value!
                                                                    .longitude
                                                                    .toString();
                                                          } else
                                                          if (taskListController
                                                              .taskListState
                                                              .currentTask
                                                              .value!
                                                              .address !=
                                                              null) {
                                                            // если координаты не заданы, поищем по адресу
                                                            baseUrl = baseUrl +
                                                                "&text=" +
                                                                taskListController
                                                                    .taskListState
                                                                    .currentTask
                                                                    .value!
                                                                    .address!;
                                                          }
                                                          final String encodedURl =
                                                          Uri.encodeFull(
                                                              baseUrl);
                                                          // тут можно было бы проверить через canLaunch, но вроде не обязательно
                                                          // в крайнем случае откроет просто карту в неподходящем месте
                                                          launch(encodedURl);
                                                        },
                                                        icon: Column(
                                                          children: [
                                                            Expanded(
                                                              child: Icon(
                                                                Icons.place,
                                                                color: themeData
                                                                    .colorScheme
                                                                    .primary,
                                                              ),
                                                            ),
                                                            // #TODO: согласно макету, под иконкой должно быть не равномерное подчеркивание,
                                                            // а тень, хитро полученная как тень рамки иконки в figma. Подобного эффекта пока
                                                            // достичь не удалось.
                                                            // Еще вариант -- такая вот иконка https://www.iconfinder.com/icons/2344289/gps_location_map_place_icon
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                EdgeInsets.only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 20,
                                                                ),
                                                                child: Divider(
                                                                  thickness: 3,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                    Text(taskListController
                                                        .taskListState
                                                        .currentTask
                                                        .value!
                                                        .flexibleAttribs[
                                                    TaskFixtures
                                                        .distanceToObjectFlexAttrName]
                                                        ?.toString() ??
                                                        "")
                                                  ],
                                                ),
                                              )
                                          ],
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween),
                                      //Прогресс бар для этапов
                                      if (taskListController.taskListState
                                          .currentTask.value!.stage !=
                                          null)
                                        Row(
                                            children: [
                                              // Первый этап
                                              Expanded(
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12,
                                                        right: 4,
                                                        bottom: 5,
                                                        top: 12),
                                                    child: LinearProgressIndicator(
                                                      value: taskListController
                                                          .taskListState
                                                          .currentTask
                                                          .value!
                                                          .getStageProgressStatus(
                                                          1,
                                                          taskListController
                                                              .taskListState
                                                              .currentTask
                                                              .value!
                                                              .stage!),
                                                      color: Colors.yellow
                                                          .shade700,
                                                      minHeight: 12,
                                                      backgroundColor:
                                                      Colors.yellow.shade200,
                                                    )),
                                              ),
                                              // Второй этап
                                              Expanded(
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 4,
                                                        right: 4,
                                                        bottom: 5,
                                                        top: 12),
                                                    child: LinearProgressIndicator(
                                                      value: taskListController
                                                          .taskListState
                                                          .currentTask
                                                          .value!
                                                          .getStageProgressStatus(
                                                          2,
                                                          taskListController
                                                              .taskListState
                                                              .currentTask
                                                              .value!
                                                              .stage!),
                                                      color: Colors.yellow
                                                          .shade700,
                                                      minHeight: 12,
                                                      backgroundColor:
                                                      Colors.yellow.shade200,
                                                    )),
                                              ),
                                              // Третий этап
                                              Expanded(
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 4,
                                                        right: 4,
                                                        bottom: 5,
                                                        top: 12),
                                                    child: LinearProgressIndicator(
                                                      value: taskListController
                                                          .taskListState
                                                          .currentTask
                                                          .value!
                                                          .getStageProgressStatus(
                                                          3,
                                                          taskListController
                                                              .taskListState
                                                              .currentTask
                                                              .value!
                                                              .stage!),
                                                      color: Colors.yellow
                                                          .shade700,
                                                      minHeight: 12,
                                                      backgroundColor:
                                                      Colors.yellow.shade200,
                                                    )),
                                              ),
                                              // Четвертый этап
                                              Expanded(
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 4,
                                                        right: 12,
                                                        bottom: 5,
                                                        top: 12),
                                                    child: LinearProgressIndicator(
                                                      value: taskListController
                                                          .taskListState
                                                          .currentTask
                                                          .value!
                                                          .getStageProgressStatus(
                                                          4,
                                                          taskListController
                                                              .taskListState
                                                              .currentTask
                                                              .value!
                                                              .stage!),
                                                      color: Colors.yellow
                                                          .shade700,
                                                      minHeight: 12,
                                                      backgroundColor:
                                                      Colors.yellow.shade200,
                                                    )),
                                              ),
                                            ],
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween),
                                      Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(16, 8, 16, 0),
                                          child: LimitedBox(
                                              maxHeight: 450.0,
                                              child: AttribValue(
                                                task: taskListController
                                                    .taskListState
                                                    .currentTask
                                                    .value!,
                                              ))),
                                    ],
                                  )),
                            ),
                            Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 12),
                              child: WorksTab(),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Card(
                                child: Container(
                                    height: 100.0,
                                    width: 100.0,
                                    child: ObjectAttachWidget(taskListController
                                        .taskListState.currentTask.value!.id)),
                                elevation: 3,
                              ),
                            ),
                        GetBuilder<CommentController>(
                            init: CommentController(),
                                builder: (historyEventController) {
                                  return Padding(
                                      padding: EdgeInsets.only(
                                          left: 12, right: 12, bottom: 12),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount: historyEventController
                                                .getComments()
                                                    .length,
                                                controller: historyScrollController,
                                                itemBuilder: (
                                                    BuildContext context,
                                                    int index) {
                                                  return InkWell(
                                                      child: HistoryEventCard(
                                                          maxLines: 10,
                                                          comment:
                                                          historyEventController
                                                                  .getComments()[
                                                          index]),
                                                      onTap: () {
                                                        historyEventController
                                                            .selectedComment =
                                                        historyEventController
                                                                .getComments()[
                                                            index];
                                                        GetDelegate routerDelegate =
                                                        Get.find();
                                                        routerDelegate.toNamed(
                                                            CommentPage
                                                                .routeName);
                                                      });
                                                }),
                                          ),
                                          // Текстовое поле ввода комментария
                                          Padding(
                                            padding: EdgeInsets.only(top: 16),
                                            child: Focus(
                                              onFocusChange: (value) {
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 100), () {
                                                  historyEventController
                                                  .onTextFieldFocused = value;
                                                });
                                              },
                                              child: TextField(
                                                  textInputAction:
                                                  TextInputAction.send,
                                                  keyboardType: TextInputType
                                                      .text,
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
                                                              .isAlarmComment
                                                              ? Icons
                                                              .notifications
                                                              : Icons
                                                              .notifications_off,
                                                          // size: 30,
                                                          color: Colors.black),
                                                      onPressed: () {
                                                        historyEventController
                                                            .isAlarmComment =
                                                        !historyEventController
                                                            .isAlarmComment;
                                                      },
                                                    ),
                                                    isCollapsed: false,
                                                  ),
                                                  onSubmitted: (text) {
                                                    historyEventController
                                                        .addComment(
                                                        commentTextController
                                                            .text,
                                                        historyEventController
                                                            .isAlarmComment,
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
                                                  minLines: 1,
                                                  maxLines: 5,
                                                  controller:
                                                  commentTextController),
                                            ),
                                          ),
                                          Visibility(
                                              visible: historyEventController
                                              .onTextFieldFocused,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 8, right: 16),
                                                child: Row(
                                                    children: [
                                                      TextButton(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .only(
                                                              top: 4,
                                                              right: 8,
                                                              left: 8,
                                                              bottom: 4),
                                                          child: const Text(
                                                              'Отправить',
                                                              style: TextStyle(
                                                                  color:
                                                                  Colors.black,
                                                                  fontSize: 14)),
                                                        ),
                                                        style: ButtonStyle(
                                                            shape: MaterialStateProperty
                                                                .all<
                                                                RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        32))),
                                                            padding: MaterialStateProperty
                                                                .all<
                                                                EdgeInsets>(
                                                                EdgeInsets.all(
                                                                    2)),
                                                            backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                Colors.yellow
                                                                    .shade700)),
                                                        onPressed: () {
                                                          historyEventController
                                                              .addComment(
                                                              commentTextController
                                                                  .text,
                                                              historyEventController
                                                              .isAlarmComment,
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
                                                            curve: Curves
                                                                .easeOut,
                                                            duration:
                                                            const Duration(
                                                                milliseconds:
                                                                300),
                                                          );
                                                          FocusManager
                                                              .instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                      ),
                                                    ],
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.end),
                                              ))
                                        ],
                                      ));
                                }),
                            MarkTypeFilter()
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
    TaskListController taskListController = Get.find();
    return GetBuilder<CommentController>(
        init: CommentController(),
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
                                    PopupMenuItem(
                                      child: ListTile(
                                          leading:
                                          Icon(Icons.check_circle_outline),
                                          title: Text('Завершить этап'),
                                          onTap: () async {
                                            // если завершаем последний этап, отобразим дилог закрытия для выбора ШЗ
                                            // у нарядов ТО этапов нет, поэтому всегда переходим к диалогу закрытию
                                            if (task.stage == null ||
                                                task.stage!.isLast) {
                                              Navigator.pop(context, "");
                                              showAdaptiveDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return CloseTaskDialog();
                                                  });
                                            } else {
                                              Navigator.pop(context, "");
                                              try {
                                                await asyncShowProgressIndicatorOverlay(
                                                    asyncFunction: () {
                                                      return taskListController
                                                          .completeStage(
                                                          taskListController
                                                              .taskListState
                                                              .currentTask
                                                              .value!
                                                              .id);
                                                    });
                                              } catch (e) {
                                                // TODO сообщение об ошибке
                                              } finally {
                                                // TODO обновление сведений
                                              }
                                            }
                                          }),
                                      value: 1,
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
                                      value: 2,
                                    ),
                                    // Данная кнопка оставляет системный комментарий
                                    PopupMenuItem(
                                        value: 3,
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
                                                taskListController
                                                    .taskListState
                                                    .currentTask
                                                    .value!);
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

/// Вывод строки Параметр: Значение для версии 1.0
/// Тут мы не используем группы, они нам не нужны
/// ListView.separated выбран для реализации кнопки показать все
class AttribValue extends StatelessWidget {
  final Task task;
  TaskListController taskListController = Get.find();

  AttribValue({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    LinkedHashMap<String, Object?> attributes = task.getAttrValuesByTask();

    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          if (attributes.keys.elementAt(index) == 'Примечание' &&
              attributes.values
                  .elementAt(index)
                  .toString()
                  .length > 100) {
            return TextButton(
                child: taskListController.maxLines == 5
                    ? Text("прочитать полностью ↓",
                    style: TextStyle(fontWeight: FontWeight.w100))
                    : Text("скрыть ↑",
                    style: TextStyle(fontWeight: FontWeight.w100)),
                onPressed: () {
                  taskListController.maxLines == 5
                      ? taskListController.viewFullCommentary()
                      : taskListController.hideCommentary();
                });
          }
          return Divider(
              height: 0, thickness: 0, color: themeData.highlightColor);
        },
        itemCount: attributes.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(children: [
            Row(children: [
              Expanded(
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: RichText(
                          maxLines: taskListController.maxLines,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFF646363),
                                  fontWeight: FontWeight.normal),
                              children: <TextSpan>[
                                TextSpan(
                                    text:
                                    "${attributes.keys.elementAt(index)}:   "),
                                TextSpan(
                                    text: attributes.values.elementAt(index) ==
                                        null
                                        ? ""
                                        : (attributes.values
                                        .elementAt(index)
                                        .runtimeType ==
                                        DateTime
                                        ? DateFormat("dd.MM.yyyy HH:mm")
                                        .format(DateTime.parse(
                                        attributes.values
                                            .elementAt(index)
                                            .toString()))
                                        : attributes.values
                                        .elementAt(index)
                                        .toString()),
                                    style: TextStyle(color: Colors.black))
                              ]))))
            ]),
          ]);
        });
  }
}

/// Ниже старая реализация гибких атрибутов через группы, остается тут на случай если она нам еще понадобится
// TODO: Используется в закрытии наряда НИ надо будет поправить потом?
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
      // Container(
      //     padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
      //     child: Text(attrGroup,
      //         style: const TextStyle(fontSize: 18, color: Colors.grey))),
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
