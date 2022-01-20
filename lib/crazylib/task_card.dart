import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';

/// визуальное представление задачи в списке задач
/// #TODO: также используется и в старой карусели в AlternativeTaskListPage, но никто даже не смотрел, как оно там выглядит
class TaskCard extends StatelessWidget {
  final Task task;
  final String taskPageRoutName;

  const TaskCard({Key? key, required this.task, required this.taskPageRoutName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return
        //использует state списка задач, например, для highlight`а текста, вводимого в search bar
        // что выражается вот в такой зависимости от контроллера
        GetBuilder<TaskListController>(
      builder: (controller) {
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
            // размеры сознательно здесь не заданы, чтобы можно было масштабировать карточку снаружи, по размерам parent`а
            child: Card(
                child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          task.taskType ?? "",
                          // #TODO: почему не работает?
                          textAlign: TextAlign.end,
                        ),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // #TODO: sized box и softwrap здесь нужны для переноса
                      // и все прекрсано, но хорошо бы ширину относительно получать, относительно ширины parent`а
                      Expanded(
                        child:
                            // обеспечит подсветку текста, введенного в строку поиска, и присутствующего среди названий заадач
                            SubstringHighlight(
                          text: task.desc ?? task.name,
                          term: controller.searchText,
                          //softWrap: true,
                          textStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      Text(task.getDueDateShortText()),
                      IconButton(
                          iconSize: 40,
                          tooltip: 'Форма задачи',
                          icon: const Icon(Icons.chevron_right_outlined),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              this.taskPageRoutName,
                              arguments: this.task,
                            );
                          }),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // #TODO: sized box и softwrap здесь нужны для переноса
                      // и все прекрсано, но хорошо бы ширину относительно получать, относительно ширины parent`а
                      SizedBox(
                        width: 250,
                        child: Text(
                          task.getAddressDescription(),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              // #TODO: зачем это: https://stackoverflow.com/questions/66476548/flutter-textbutton-padding  ??
                              MaterialStateProperty.all<Color>(
                                  Colors.yellowAccent),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(2)),
                        ),
                        child: Text(
                          "Вернуть группе",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () => {print("login")},
                      ),
                      Text(task.getTimeLeftText(),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            )));
      },
    );
  }
}
