import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/crazylib/bottom_button_bar.dart';
import 'package:tasklist_lite/crazylib/task_card.dart';
import 'package:tasklist_lite/crazylib/top_user_bar.dart';
import 'package:tasklist_lite/pages/task_page.dart';
// #TODO: жуткий костыль, на время повторного изучения state management
import 'package:tasklist_lite/state/application_state.dart' hide ModelBinding;
import 'package:tasklist_lite/state/tasklist_state.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:tasklist_lite/tasklist/task_repository.dart';

class TaskListPage extends StatefulWidget {
  static const String routeName = 'tasklist';

  TaskListPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

// #TODO: кривое получение контекста (т.к. не в build), а также избыточный копипаст-код
// в TaskListState заставляет задуматься, насколько inherited widget подходит как state management для наших задач
// а еще были проблемы из-за того, что конструктор для initialState в inherited wodget`е должен быть const. Например,
// у dateTime вообще нет ни одного способа создать const экземпляр.
class _TaskListPageState extends State<TaskListPage> {
  StreamSubscription? openedTasksSubscription;
  StreamSubscription? closedTasksSubscription;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ApplicationState applicationState = ApplicationState.of(context);
    Get.delete<ApplicationState>();
    Get.put(applicationState);
    TaskRepository taskRepository = Get.find();
    // берем stream`ы, на которых висят данные по открытым и закрытым задачам, и заводим их
    // на изменение соотв. полей состояния списка.
    Stream<List<Task>> openedTasksStream = taskRepository.streamOpenedTasks();

    // #TODO: недостаточно делать cancel в момент переключения на новый stream. Нужна осознанная
    // политика dispose
    openedTasksSubscription?.cancel();
    openedTasksSubscription = openedTasksStream.listen((event) {
      setState(() {
        TaskListState.update(
            context, TaskListState.of(context).copyWith(openedTasks: event));
      });
    });
    // #TODO: стримить закрытые таски не то чтобы и нужно, т.к. вряд ли они часто появляются неожиданно
    // можно было бы обойтись обычным query
    // #TODO: копипаст. От него разумнее всего избавиться, используя stream builder`ы, https://habr.com/ru/post/450950/
    // #TODO: подписка на closed должна прекращаться при дополнительном условии -- если поменяли дату в календаре
    // потому что тогда нужно стримить уже за другой день
    Stream<List<Task>> closedTasksStream = taskRepository.streamClosedTasks(
        TaskListState.of(context).currentDate ?? DateTime.now());
    closedTasksSubscription?.cancel();
    closedTasksSubscription = closedTasksStream.listen((event) {
      setState(() {
        TaskListState.update(
            context, TaskListState.of(context).copyWith(closedTasks: event));
      });
    });
  }

  @override
  void dispose() {
    // #TODO: а еще отличный пример со StreamBuilder приведен https://habr.com/ru/post/450950/
    // он хорош тем, что избавляет от необходимости контролировать ЖЦ уведомлений и вызывать им cancel
    openedTasksSubscription?.cancel();
    closedTasksSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    ApplicationState applicationState = ApplicationState.of(context);

    // #TODO: это текущее значение фильтра назначенные/неназначенные.
    double val = 1;

    // #TODO: для минимально симпатичной компоновки для больших экранов
    // можно попробовать например Row(Drawer, <column с содержимым Scaffold>),
    // но имея Scaffold на экране, сверстать что-то внятное для большого экрана не получится
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
                onChanged: (value) {
                  TaskListState.update(context,
                      TaskListState.of(context).copyWith(searchText: value));
                },
              ),
            ),
            SizedBox(
                // ListView с неизвестным заранее числом элементов не  может посчитать свой размер по вертикали, поэтому должны ограничивать его явно
                height: 600.0,
                child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                    shrinkWrap: true,
                    itemCount: TaskListState.of(context).getTasks().length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: TaskListState.of(context)
                            .getTasks()[index], //taskList[index],
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
                      tooltip: DateFormat("dd MMMM yyyy").format(
                          TaskListState.of(context).currentDate != null
                              ? TaskListState.of(context)
                                  .currentDate!
                                  .subtract(Duration(days: 1))
                              : DateTime.now().subtract(Duration(days: 1))),
                      icon: const Icon(Icons.chevron_left_outlined),
                      onPressed: () {
                        TaskListState.update(
                            context,
                            TaskListState.of(context).copyWith(
                                currentDate:
                                    TaskListState.of(context).currentDate !=
                                            null
                                        ? TaskListState.of(context)
                                            .currentDate!
                                            .subtract(Duration(days: 1))
                                        : DateTime.now()
                                            .subtract(Duration(days: 1))));
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: new Icon(
                            Icons.date_range_outlined,
                          ),
                          onPressed: () async {
                            // #TODO: так и не нашел способа сделать не круглым индикатор даты.
                            // #TODO: так и не нашел способа изменить размер. Способ, аналогичный
                            // theme, не работает, все размеры в sized box`ах игнорируются
                            // похоже, когда аналитики озвучат требования к календарю, придется здесь
                            // заюзать более кастомизируемый компонент
                            final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    TaskListState.of(context).currentDate ??
                                        DateTime.now(),
                                firstDate: DateTime(2021),
                                lastDate: DateTime(2024),
                                helpText: "Укажите день",
                                cancelText: "Отмена",
                                confirmText: "Ок",
                                locale: const Locale("ru", "RU"),
                                builder: (context, child) {
                                  // вот только таким хитрым способом можно повлиять на цвета показываемого date picker`а
                                  return Theme(
                                      data: Theme.of(context).copyWith(
                                        /*   это если вдруг захочется цвет фона поменять dialogBackgroundColor:
                                            themeData.bottomAppBarColor,*/
                                        colorScheme: ColorScheme.light(
                                            primary: Colors.green),
                                        buttonTheme: ButtonThemeData(
                                            textTheme: ButtonTextTheme.primary),
                                      ),
                                      child: child ?? new Text(""));
                                });
                            if (picked != null &&
                                picked !=
                                    TaskListState.of(context).currentDate) {
                              TaskListState.update(
                                  context,
                                  TaskListState.of(context)
                                      .copyWith(currentDate: picked));
                            }
                          },
                        ),
                        Text(DateFormat('dd MMMM yyyy', "ru_RU").format(
                            TaskListState.of(context).currentDate ??
                                DateTime.now())),
                      ],
                    ),
                    IconButton(
                      tooltip: DateFormat("dd MMMM yyyy").format(
                          TaskListState.of(context).currentDate != null
                              ? TaskListState.of(context)
                                  .currentDate!
                                  .add(Duration(days: 1))
                              : DateTime.now().add(Duration(days: 1))),
                      icon: const Icon(Icons.chevron_right_outlined),
                      onPressed: () {
                        TaskListState.update(
                            context,
                            TaskListState.of(context).copyWith(
                                currentDate: TaskListState.of(context)
                                            .currentDate !=
                                        null
                                    ? TaskListState.of(context)
                                        .currentDate!
                                        .add(Duration(days: 1))
                                    : DateTime.now().add(Duration(days: 1))));
                      },
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
