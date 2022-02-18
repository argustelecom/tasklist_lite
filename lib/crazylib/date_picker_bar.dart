import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';

// может являться stateless,  только потому что свой state держит в TaskListController
/// рефакторинг -- вынос кода: панель с фильтром по дате из страницы списка задач
/// это пока не самостоятельный компонент DatePickerBar, но может стать таковым, если
///  будет нужно
@Deprecated(
    "Заменен на TasklistFilterBar. По славной традиции, не выброшен, а оставлен на будущее. Куча хлама еще не так велика.")
class DatePickerBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskListController>(builder: (taskListController) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
        child: Card(
            child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: DateFormat("dd MMMM yyyy", "ru_RU").format(
                    taskListController.currentDate.subtract(Duration(days: 1))),
                icon: const Icon(Icons.chevron_left_outlined),
                onPressed: () {
                  taskListController.currentDate = taskListController
                      .currentDate
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
                          initialDate: taskListController.currentDate,
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
                                  colorScheme:
                                      ColorScheme.light(primary: Colors.green),
                                  buttonTheme: ButtonThemeData(
                                      textTheme: ButtonTextTheme.primary),
                                ),
                                child: child ?? new Text(""));
                          });
                      if (picked != null &&
                          picked != taskListController.currentDate) {
                        // #TODO: мб как минимум через setter вызывать? почему setState не нужен?
                        taskListController.currentDate = picked;
                      }
                    },
                  ),
                  Text(DateFormat('dd MMMM yyyy', "ru_RU")
                      .format(taskListController.currentDate)),
                ],
              ),
              IconButton(
                tooltip: DateFormat("dd MMMM yyyy", "ru_RU").format(
                    taskListController.currentDate.add(Duration(days: 1))),
                icon: const Icon(Icons.chevron_right_outlined),
                onPressed: () {
                  taskListController.currentDate =
                      taskListController.currentDate.add(Duration(days: 1));
                },
              ),
            ],
          ),
        ])),
      );
    });
  }
}
