import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:tasklist_lite/crazylib/work_card.dart';

import '../state/tasklist_controller.dart';
import '../tasklist/model/task.dart';
import '../tasklist/model/work.dart';
import 'crazy_progress_dialog.dart';
import 'info_dialog.dart';

/// #TODO[НИ]:
/// -- вынести state и поведение, посвященное работам, из taskListController в новый workController
/// (хотя бы потому, что taskLIstController уже перегружен и трещит
/// -- устранить все методы а-ля workRepository.orderWorksByState. Контроллер должен иметь state, а
/// подобную сортировку, фильтрацию и т.п. надо делать или в геттере этого state, или в отдельном методе
/// getWorks. Тогда в момент установки state не надо ничего вычислять и сортировать. Все это делается
/// только если понадобится (то есть как следствие build`а зависимых от state виджетов)
/// -- логику изменения state надо прятать в соотв. методы контроллера, а не делать в методе build
/// виджета. Вот такого в дереве виджетов встречаться не должно:
/// works = workRepository.filterWorksByName(task!.works, value);
/// #TODO: а еще теперь может быть stateless
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
  TaskListController taskListController = Get.find();
  ScrollController scrollController = new ScrollController();
  bool _isScrolling = false;

  void onScroll() async {
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
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    if (taskListController.taskListState.currentTask.value == null) {
      return Padding(
          padding: EdgeInsets.all(12),
          child: Text(
              "Что-то пошло не так. Вернитесь на главную страницу и попробуйте снова."));
    }

    return GetBuilder<TaskListController>(builder: (taskListController) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Card(
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "Наименование работы",
                      fillColor: themeData.bottomAppBarColor,
                      border: InputBorder.none,
                      filled: true,
                      suffixIcon: (taskListController.searchWorksText == "")
                          ? IconButton(
                              tooltip: 'Поиск',
                              icon: const Icon(Icons.search_outlined),
                              onPressed: () {},
                            )
                          : IconButton(
                              tooltip: 'Очистить',
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                taskListController.searchWorksText = "";
                              },
                            ),
                      isCollapsed: false,
                    ),
                    onChanged: (value) {
                      taskListController.searchWorksText = value;
                    },
                  ),
                )),
            if (taskListController.getWorks().isEmpty)
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child:
                      Text("Работы не найдены.", textAlign: TextAlign.center))
            else
              Expanded(
                  child: Stack(children: [
                ListView.builder(
                    controller: scrollController,
                    shrinkWrap: true,
                    itemCount: taskListController.getWorks().length,
                    itemBuilder: (context, index) {
                      return WorkCard(
                          work: taskListController.getWorks()[index]);
                    }),
                Positioned(
                    bottom: 20,
                    right: 5,
                    child: FloatingActionButton.extended(
                        backgroundColor: Colors.yellow.shade700,
                        elevation: 7,
                        extendedPadding: EdgeInsets.all(8),
                        isExtended: _isScrolling ? false : true,
                        label: Text(
                          "Не требуются   ",
                          style: TextStyle(
                              letterSpacing: -0.1, color: Colors.black),
                        ),
                        icon: Stack(children: [
                          Icon(Icons.build_circle_outlined,
                              color: Color(0xFF323232)),
                          Icon(Icons.block, color: Color(0xFF323232))
                        ]),
                        onPressed: () async {
                          if (taskListController.getWorks().isNotEmpty) {
                            List<WorkType> workTypes = taskListController
                                .getWorks()
                                .where((e) =>
                                    (e.workDetail == null ||
                                        e.workDetail!.isEmpty) &&
                                    !e.notRequired)
                                .expand((e) => [e.workType])
                                .toList();
                            if (workTypes.isNotEmpty)
                              try {
                                await asyncShowProgressIndicatorOverlay(
                                    asyncFunction: () {
                                  return taskListController
                                      .markWorksNotRequired(workTypes);
                                });
                                Task task = taskListController
                                    .taskListState.currentTask.value!;
                                task.works!.removeWhere(
                                    (e) => workTypes.contains(e.workType));
                                task.works!.addAll(workTypes
                                    .expand((e) => [
                                          new Work(
                                              workType: e,
                                              notRequired: true,
                                              workDetail: [])
                                        ])
                                    .toList());
                                taskListController
                                    .taskListState.currentTask.value = task;
                                taskListController.update();
                              } catch (e) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return InfoDialog(
                                          text: "Произошла ошибка: \"$e\"");
                                    });
                              }
                          }
                        }))
              ]))
          ]));
    });
  }
}
