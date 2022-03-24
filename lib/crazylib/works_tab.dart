import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:tasklist_lite/crazylib/work_card.dart';

import '../state/tasklist_controller.dart';

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
    if (taskListController.taskListState.currentTask.value == null) {
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
              child: Text("Работы не найдены.", textAlign: TextAlign.center))
        else
          Expanded(
              child: Stack(children: [ListView.builder(
                  shrinkWrap: true,
                  itemCount: taskListController.getWorks().length,
                  itemBuilder: (context, index) {
                    return WorkCard(
                      work: taskListController
                          .getWorks()[index], //taskList[index],
                    );
                  })

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
          ])


                  )
      ]);
    });
  }
}
