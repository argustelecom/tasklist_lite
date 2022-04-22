import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/presentation/adaptive.dart';
import 'package:tasklist_lite/presentation/widgets/cards/task_card.dart';

import '../../controllers/tasklist_controller.dart';

/// Панелька фильтров списка задач
/// в фильтры входят фильтр по подстроке в полях задачи (бывш. SearchBar)
/// и фильтр закрытых задач по выбранной дате (бывш. DatePickerBar)
/// Ее state состоит из двух признаков: searchBarExpanded и datePickerBarExpanded.
/// Если оба false, показаны одновременно строка поиска (на две трети ширины) и
/// кнопка выбора даты (на оставшуюся треть). Если searchBarExpanded, она занимает
/// всю строку, а компонент выбора даты не показан вообще. Если datePickerBarExpanded,
/// компонент выбора даты трансформируется в строку с кнопками перемотки даты, иконкой
/// календаря и расширенным текстом даты. Строка поиска в этом режиме спрятана.
/// К сожалению, пришлось state вынести в контроллер, т.к. к нему нужен доступ и
/// для компонента InlineCalendar. А так не хотелось использовать контроллеры для presentation
/// state. (Под presentation здесь имеется ввиду "такаятохреньVisible или другаяфигняExpanded)
class TasklistFiltersBar extends StatelessWidget
    implements PreferredSizeWidget {

  final _searchNode =  FocusNode();
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return GetBuilder<TaskListController>(builder: (taskListController) {
      return Column(children: [
        Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: SizedBox(
              // здесь вынуждены задать высоту, чтобы именно по ней выровнялись элементы строки.
              // Так как один из элементов строки -- это TextField в режиме expands, то есть требует
              // заданной высоты родителя. А не в режиме expands TextField ужмется не так, как другой элемент
              // строки -- TextButton. Короче, высота родителя здесь определяет высоту дочерних компонентов,
              // поэтому должна быть задана явно (ну или делать CustomMultiChildLayout).
              height: 45,
              child: Row(
                children: [
                  if (!taskListController.datePickerBarExpanded)
                    Expanded(
                        // когда никто не кликнут, строка поиска занимает две трети ширины, а поле с датой -- оставшуюся треть
                        flex: 2,
                        child: Card(
                          margin: EdgeInsets.only(
                              left: isDisplayDesktop(context) ? 8 : 12,
                              right: 12),
                          child: Focus(
                            onFocusChange: (value) {
                              taskListController.searchBarExpanded = value;
                            },
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: isDisplayDesktop(context) ? 8 : 12,
                                    right: 12),
                                child: TextSelectionTheme(
                                  data: TextSelectionTheme.of(context).copyWith(
                                    cursorColor: themeData.hintColor,
                                  ),
                                  child: TextField(
                                    expands: true,
                                    textInputAction: TextInputAction.search,
                                    maxLines: null,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      hintText: "Поиск",
                                      fillColor: themeData.bottomAppBarColor,
                                      border: InputBorder.none,
                                      filled: true,
                                      suffixIcon: IconButton(
                                        tooltip: 'Поиск',
                                        icon: const Icon(Icons.search_outlined),
                                        color: themeData.hintColor,
                                        onPressed: () {},
                                      ),
                                      isCollapsed: false,
                                    ),
                                    onSubmitted: (value) {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    },
                                    onChanged: (value) {
                                      taskListController.searchText = value;
                                    },
                                  ),
                                )),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.white38)),
                          elevation: TaskCard.taskCardElevation,
                        )),
                  if (!taskListController.searchBarExpanded)
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                          onTap: () {
                            taskListController.datePickerBarExpanded =
                                !taskListController.datePickerBarExpanded;
                            taskListController.calendarOpened = false;
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: taskListController.datePickerBarExpanded
                                  ? isDisplayDesktop(context)
                                      ? 8
                                      : 12
                                  : 8,
                              right: isDisplayDesktop(context) ? 16 : 12,
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                      color: Colors.yellow.shade700)),
                              // по дефолту карточка имеет margins в несколько пикселей,
                              // из-за этого выбивается из размера строки.  Чтобы выровнять, надо явно поставить 0
                              // Почему это называется margin, а не привычным padding -- хз, но пока догадался, потратил
                              // больше часа :'(
                              margin: EdgeInsets.symmetric(vertical: 0),
                              child: (!taskListController.datePickerBarExpanded)
                                  ? TextButton(
                                      onPressed: () {
                                        taskListController
                                                .datePickerBarExpanded =
                                            !taskListController
                                                .datePickerBarExpanded;
                                        taskListController.calendarOpened =
                                            !taskListController.calendarOpened;
                                      },
                                      child:
                                          // распахнет кнопку на всю высоту parent`а
                                          SizedBox.expand(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                              DateFormat('dd MMMM', "ru_RU")
                                                  .format(taskListController
                                                      .taskListState
                                                      .currentDate
                                                      .value),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  DefaultTextStyle.of(context)
                                                      .style),
                                        ),
                                      ),
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty
                                            .all<EdgeInsets>(EdgeInsets.symmetric(
                                                vertical: 16,
                                                // при бОльшем отступе дата не влезет, будет перенос на другую строоку.
                                                // Проверяять лучше по дате "09 сентября", она самая длинная
                                                horizontal: 12)),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          tooltip: DateFormat(
                                                  "dd MMMM yyyy", "ru_RU")
                                              .format(taskListController
                                                  .taskListState
                                                  .currentDate
                                                  .value
                                                  .subtract(Duration(days: 1))),
                                          icon: const Icon(
                                              Icons.chevron_left_outlined),
                                          onPressed: () {
                                            taskListController.taskListState
                                                    .currentDate.value =
                                                taskListController.taskListState
                                                    .currentDate.value
                                                    .subtract(
                                                        Duration(days: 1));
                                          },
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: new Icon(
                                                Icons.date_range_outlined,
                                              ),
                                              onPressed: () {
                                                taskListController
                                                        .calendarOpened =
                                                    !taskListController
                                                        .calendarOpened;
                                              },
                                            ),
                                            Text(
                                                DateFormat(
                                                        'dd MMMM yyyy', "ru_RU")
                                                    .format(taskListController
                                                        .taskListState
                                                        .currentDate
                                                        .value),
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style),
                                          ],
                                        ),
                                        IconButton(
                                          tooltip: DateFormat(
                                                  "dd MMMM yyyy", "ru_RU")
                                              .format(taskListController
                                                  .taskListState
                                                  .currentDate
                                                  .value
                                                  .add(Duration(days: 1))),
                                          icon: const Icon(
                                              Icons.chevron_right_outlined),
                                          onPressed: () {
                                            taskListController.taskListState
                                                    .currentDate.value =
                                                taskListController.taskListState
                                                    .currentDate.value
                                                    .add(Duration(days: 1));
                                          },
                                        ),
                                      ],
                                    ),
                            ),
                          )),
                    ),
                ],
              )),
        ),
      ]);
    });
  }

  @override
  Size get preferredSize => Size.fromHeight(150);
}

class InlineCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskListController>(builder: (taskListController) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Card(
          elevation: TaskCard.taskCardElevation,
          //  Изменить форму индикатора в календаре без особых извращений не выйдет.
          // См. камент в CalendarDatePicker.build:
          // The selected day gets a circle background highlight, and a
          // contrasting text color.
          // #TODO: можно конечно сделать свой flutter package, или pull request товарищам,
          // но пока есть более важные дела.
          child: CalendarDatePicker(
            initialDate: taskListController.taskListState.currentDate.value,
            firstDate: DateTime(2021),
            lastDate: DateTime(2024),
            onDateChanged: (picked) {
              taskListController.taskListState.currentDate.value = picked;
              taskListController.calendarOpened = false;
              taskListController.datePickerBarExpanded = false;
            },
          ),
        ),
      );
    });
  }
}
