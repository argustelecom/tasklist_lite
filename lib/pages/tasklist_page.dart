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
import 'package:tasklist_lite/state/tasklist_controller.dart';

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
    // #TODO: это текущее значение фильтра назначенные/неназначенные.
    double val = 1;

    // #TODO: для минимально симпатичной компоновки для больших экранов
    // можно попробовать например Row(Drawer, <column с содержимым Scaffold>),
    // но имея Scaffold на экране, сверстать что-то внятное для большого экрана не получится
    return GetBuilder<TaskListController>(
      init: TaskListController(),
      builder: (controller) {
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
                      controller.searchText = value;
                    },
                  ),
                ),
                SizedBox(
                    // ListView с неизвестным заранее числом элементов не  может посчитать свой размер по вертикали, поэтому должны ограничивать его явно
                    height: 600.0,
                    child: ListView.builder(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                        shrinkWrap: true,
                        itemCount: controller.getTasks().length,
                        itemBuilder: (context, index) {
                          return TaskCard(
                            task:
                                controller.getTasks()[index], //taskList[index],
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
                          tooltip: DateFormat("dd MMMM yyyy", "ru_RU").format(
                              controller.currentDate
                                  .subtract(Duration(days: 1))),
                          icon: const Icon(Icons.chevron_left_outlined),
                          onPressed: () {
                            controller.currentDate = controller.currentDate
                                .subtract(Duration(days: 1));
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
                                    initialDate: controller.currentDate,
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
                                                textTheme:
                                                    ButtonTextTheme.primary),
                                          ),
                                          child: child ?? new Text(""));
                                    });
                                if (picked != null &&
                                    picked != controller.currentDate) {
                                  // #TODO: мб как минимум через setter вызывать? почему setState не нужен?
                                  controller.currentDate = picked;
                                }
                              },
                            ),
                            Text(DateFormat('dd MMMM yyyy', "ru_RU")
                                .format(controller.currentDate)),
                          ],
                        ),
                        IconButton(
                          tooltip: DateFormat("dd MMMM yyyy", "ru_RU").format(
                              controller.currentDate.add(Duration(days: 1))),
                          icon: const Icon(Icons.chevron_right_outlined),
                          onPressed: () {
                            controller.currentDate =
                                controller.currentDate.add(Duration(days: 1));
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
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 32),
                              child: Text(
                                "Назначенные ",
                                style: TextStyle(
                                    color: Colors.deepPurpleAccent,
                                    fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 32),
                              child: Text(
                                "Неназначенные ",
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 16),
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
      },
    );
  }
}
