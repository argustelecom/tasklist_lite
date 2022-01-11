import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tasklist_lite/state/tasklist_state.dart';
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
    // размеры сознательно здесь не заданы, чтобы можно было масштабировать карточку снаружи, по размерам parent`а
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
        child: Card(
            child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, top: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                  "Назначение наряда бригаде",
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
                  SizedBox(
                    width: 300,
                    child:
                        // обеспечит подсветку текста, введенного в строку поиска, и присутствующего среди названий заадач
                        SubstringHighlight(
                      text: task.name,
                      term: TaskListState.of(context).searchText ?? "",
                      //softWrap: true,
                      textStyle:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),

                  Text(task.dueDate ?? "11:00"),
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
                      task.address ??
                          "Курганская обл., г.Курган, ул.Гайдара, д.53",
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
                  Text("СКВ: 1ч"),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          // #TODO: зачем это: https://stackoverflow.com/questions/66476548/flutter-textbutton-padding  ??
                          MaterialStateProperty.all<Color>(Colors.yellowAccent),
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
                ],
              ),
            ),
          ],
        )));
  }
}
