import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tasklist_lite/crazylib/task_due_date_label.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/task_page.dart';
import '../tasklist/fixture/task_fixtures.dart';

class CrazyHighlight extends StatelessWidget {
  final String text;
  final String term;
  final double? width;
  final TextStyle? textStyle;
  final TextStyle? textStyleHighlight;

  CrazyHighlight(
      {required this.text,
      required this.term,
      this.width,
      this.textStyle,
      this.textStyleHighlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: width ?? MediaQuery.of(context).size.width * 0.6,
      ),
      child: SubstringHighlight(
        text: text,
        term: term,
        textStyle: textStyle ?? TextStyle(color: Theme.of(context).hintColor),
        textStyleHighlight:
            textStyleHighlight ?? TextStyle(color: Colors.yellow.shade700),
      ),
    );
  }
}

/// визуальное представление задачи в списке задач
class TaskCard extends StatelessWidget {
  final Task task;

  static const double taskCardElevation = 2;
  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return GetBuilder<TaskListController>(
      builder: (taskListController) {
        // размеры сознательно здесь не заданы, чтобы можно было масштабировать карточку снаружи, по размерам parent`а
        return Card(
          color: (task.isClosed ? Color(0xFFE5E4E4) : themeData.cardColor),
          elevation: taskCardElevation,
          // без обертывания строки в IntrinsicHeight, не получилось увидеть VerticalDivider
          // https://stackoverflow.com/questions/49388281/flutter-vertical-divider-and-horizontal-divider
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      taskListController.taskListState.currentTask.value = task;
                      GetDelegate routerDelegate = Get.find();
                      routerDelegate.toNamed(TaskPage.routeName,
                          arguments: this.task);
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, top: 12, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // обеспечит подсветку текста, введенного в строку поиска, и присутствующего среди названий заадач
                              CrazyHighlight(
                                // если есть номер заявки оператора, отображаем его. Если нет, отображаем номер из Аргуса
                                // при этом, если показали номер Аргуса, не показываем его ниже (см. соответсна ниже)
                                text: task.flexibleAttribs[TaskFixtures
                                            .foreignOrderIdFlexAttrName]
                                        ?.toString() ??
                                    task.name,
                                term: taskListController.searchText,
                                textStyle: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              CrazyHighlight(
                                text: task.flexibleAttribs[
                                            TaskFixtures.objectNameFlexAttrName]
                                        ?.toString() ??
                                    "",
                                term: taskListController.searchText,
                                width: MediaQuery.of(context).size.width * 0.3,
                                textStyle: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CrazyHighlight(
                                text: task.flexibleAttribs[TaskFixtures
                                            .foreignOrderIdFlexAttrName] !=
                                        null
                                    ? task.name
                                    : "",
                                term: taskListController.searchText,
                              ),
                              CrazyHighlight(
                                text: task.flexibleAttribs[TaskFixtures
                                            .orderOperatorNameFlexAttrName]
                                        ?.toString() ??
                                    "",
                                width: MediaQuery.of(context).size.width * 0.3,
                                term: taskListController.searchText,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 4, left: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [TaskDueDateLabel(task: task)],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16, bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CrazyHighlight(
                                  text: task.getAddressDescription(),
                                  term: taskListController.searchText),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: VerticalDivider(),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 12, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                            if ((task.latitude != null) &&
                                (task.longitude != null)) {
                              baseUrl = baseUrl +
                                  "&pt=" +
                                  task.latitude.toString() +
                                  "," +
                                  task.longitude.toString();
                            } else if (task.address != null) {
                              // если координаты не заданы, поищем по адресу
                              baseUrl = baseUrl + "&text=" + task.address!;
                            }
                            final String encodedURl = Uri.encodeFull(baseUrl);
                            // тут можно было бы проверить через canLaunch, но вроде не обязательно
                            // в крайнем случае откроет просто карту в неподходящем месте
                            launch(encodedURl);
                          },
                          icon: Column(
                            children: [
                              Expanded(
                                child: Icon(
                                  Icons.place,
                                  color: themeData.colorScheme.primary,
                                ),
                              ),
                              // #TODO: согласно макету, под иконкой должно быть не равномерное подчеркивание,
                              // а тень, хитро полученная как тень рамки иконки в figma. Подобного эффекта пока
                              // достичь не удалось.
                              // Еще вариант -- такая вот иконка https://www.iconfinder.com/icons/2344289/gps_location_map_place_icon
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
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
                      Text(task.flexibleAttribs[
                                  TaskFixtures.distanceToObjectFlexAttrName]
                              ?.toString() ??
                          "")
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
