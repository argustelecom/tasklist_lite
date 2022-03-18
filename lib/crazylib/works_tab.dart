import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:tasklist_lite/crazylib/work_card.dart';
import 'package:tasklist_lite/tasklist/work_repository.dart';

import '../state/tasklist_controller.dart';
import '../tasklist/model/task.dart';
import '../tasklist/model/work.dart';

class WorksTab extends StatefulWidget {
  WorksTab({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WorksTabState();
  }
}

class WorksTabState extends State<WorksTab> {
  TextEditingController controller = TextEditingController();
  TaskListController taskListController = Get.find();
  WorkRepository workRepository = Get.find();

  late Task? task;
  List<Work>? works = [];

  @override
  void initState() {
    super.initState();
    task = taskListController.taskListState.currentTask.value;
    if (task != null) {
      works = workRepository.orderWorksByState(task!.works);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    if (task == null) {
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
              "Что-то пошло не так. Вернитесь на главную страницу и попробуйте снова."));
    }

    return GetBuilder<TaskListController>(builder: (taskListController) {
      return Column(children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Card(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Наименование работы",
                  fillColor: themeData.bottomAppBarColor,
                  border: InputBorder.none,
                  filled: true,
                  suffixIcon: (controller.text == "")
                      ? IconButton(
                          tooltip: 'Поиск',
                          icon: const Icon(Icons.search_outlined),
                          onPressed: () {},
                        )
                      : IconButton(
                          tooltip: 'Очистить',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.text = "";
                          },
                        ),
                  isCollapsed: false,
                ),
                onChanged: (value) {
                  controller.value = TextEditingValue(
                      text: value,
                      selection: TextSelection.fromPosition(
                        TextPosition(offset: value.length),
                      ));
                  setState(() {
                    works =
                        workRepository.filterWorksByName(task!.works, value);
                  });
                },
              ),
            )),
        if (works == null || works!.isEmpty)
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("Работы не найдены.", textAlign: TextAlign.center))
        else
          Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: works!.length,
                  itemBuilder: (context, index) {
                    return WorkCard(
                      work: works![index], //taskList[index],
                    );
                  }))
      ]);
    });
  }
}
