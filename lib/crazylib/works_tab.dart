import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:tasklist_lite/crazylib/info_dialog.dart';
import 'package:tasklist_lite/crazylib/work_card.dart';
import 'package:tasklist_lite/tasklist/work_repository.dart';

import '../state/tasklist_controller.dart';
import '../tasklist/model/task.dart';
import '../tasklist/model/work.dart';
import 'crazy_progress_dialog.dart';

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
  TextEditingController textEditingController = new TextEditingController();
  ScrollController scrollController = new ScrollController();
  TaskListController taskListController = Get.find();
  WorkRepository workRepository = Get.find();

  late Task? task;
  List<Work>? works = [];
  bool _isScrolling = false;

  void onScroll() async {
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _isScrolling = true;
        });
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _isScrolling = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);
    task = taskListController.taskListState.currentTask.value;
    if (task != null) {
      works = workRepository.orderWorksByState(task!.works);
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
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
                controller: textEditingController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Наименование работы",
                  fillColor: themeData.bottomAppBarColor,
                  border: InputBorder.none,
                  filled: true,
                  suffixIcon: (textEditingController.text == "")
                      ? IconButton(
                          tooltip: 'Поиск',
                          icon: const Icon(Icons.search_outlined),
                          onPressed: () {},
                        )
                      : IconButton(
                          tooltip: 'Очистить',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            textEditingController.text = "";
                          },
                        ),
                  isCollapsed: false,
                ),
                onChanged: (value) {
                  textEditingController.value = TextEditingValue(
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
              child: Stack(children: [
            ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                itemCount: works!.length,
                itemBuilder: (context, index) {
                  return WorkCard(
                    work: works![index], //taskList[index],
                  );
                }),
            Positioned(
                bottom: 15,
                right: 5,
                child: FloatingActionButton.extended(
                    backgroundColor: Colors.yellow.shade700,
                    elevation: 7,
                    extendedPadding: EdgeInsets.all(8),
                    isExtended: _isScrolling ? false : true,
                    label: Text(
                      "Не требуются   ",
                      style:
                          TextStyle(letterSpacing: -0.1, color: Colors.black),
                    ),
                    icon: Stack(children: [
                      Icon(Icons.build_circle_outlined,
                          color: Color(0xFF323232)),
                      Icon(Icons.block, color: Color(0xFF323232))
                    ]),
                    onPressed: () async {
                      if (task!.works != null && task!.works!.isNotEmpty) {
                        List<int> workTypes = task!.works!
                            .where((e) =>
                                (e.workDetail == null ||
                                    e.workDetail!.isEmpty) &&
                                !e.notRequired)
                            .expand((e) => [e.workType.id])
                            .toList();
                        try {
                          await asyncShowProgressIndicatorOverlay(
                              asyncFunction: () {
                            return taskListController.markWorksNotRequired(
                                task!.id, workTypes);
                          });
                        } catch (e) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return InfoDialog(
                                  body: Text("Произошла ошибка: \"$e\"",
                                      maxLines: 7, overflow: TextOverflow.clip),
                                );
                              });
                        } finally {
                          // TODO обновление сведений
                        }
                      }
                    }))
          ]))
      ]);
    });
  }
}
