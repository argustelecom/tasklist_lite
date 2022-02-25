import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tasklist_lite/crazylib/task_due_date_label.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:url_launcher/url_launcher.dart';

import '../tasklist/fixture/task_fixtures.dart';

/// визуальное представление задачи в списке задач
/// #TODO: также используется и в старой карусели в AlternativeTaskListPage, но никто даже не смотрел, как оно там выглядит
class TaskCard extends StatelessWidget {
  final Task task;
  final String taskPageRouteName;

  static const double taskCardElevation = 2;
  const TaskCard(
      {Key? key, required this.task, required this.taskPageRouteName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return
        //использует state списка задач, например, для highlight`а текста, вводимого в search bar
        // что выражается вот в такой зависимости от контроллера
        GetBuilder<TaskListController>(
      builder: (controller) {
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
                      controller.setCurrentTask(task);
                      Navigator.pushNamed(
                        context,
                        this.taskPageRouteName,
                        arguments: this.task,
                      );
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, top: 12, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // обеспечит подсветку текста, введенного в строку поиска, и присутствующего среди названий заадач
                              SubstringHighlight(
                                // если есть номер заявки оператора, отображаем его. Если нет, отображаем номер из Аргуса
                                // при этом, если показали номер Аргуса, не показываем его ниже (см. соответсна ниже)
                                text: task.flexibleAttribs[TaskFixtures
                                            .foreignOrderIdFlexAttrName]
                                        ?.toString() ??
                                    task.name,
                                term: controller.searchText,
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              SubstringHighlight(
                                text: task.flexibleAttribs[
                                            TaskFixtures.objectNameFlexAttrName]
                                        ?.toString() ??
                                    "",
                                term: controller.searchText,
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SubstringHighlight(
                                text: task.flexibleAttribs[TaskFixtures
                                            .foreignOrderIdFlexAttrName] !=
                                        null
                                    ? task.name
                                    : "",
                                term: controller.searchText,
                              ),
                              SubstringHighlight(
                                text: task.flexibleAttribs[TaskFixtures
                                            .orderOperatorNameFlexAttrName]
                                        ?.toString() ??
                                    "",
                                term: controller.searchText,
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
                              Text(
                                task.getAddressDescription(),
                                softWrap: true,
                              ),
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
                              // #TODO: согласно макету, по иконкой должно быть не равномерное подчеркивание,
                              // а тень, хитро полученная как тень рамки иконки в figma. Подобного эффекта пока
                              // достичь не удалось.
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
