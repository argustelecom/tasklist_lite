import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';
import 'package:tasklist_lite/tasklist/mark_repository.dart';
import 'package:tasklist_lite/tasklist/model/mark.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';

import '../tasklist/fixture/mark_fixtures.dart';

class MarkController extends GetxController {
  /// Ищем нужные нам оценки
  MarkRepository markRepository = Get.find();
  TaskListController taskListController = Get.find();

  /// Инициализируем список оценок
  @override
  void onInit() {
    initMarks(taskListController.taskListState.currentTask.value);
  }

  /// Данный метод отвечает за первичное наполнение листа с оценками
  initMarks(Task? task) {
    markList = markRepository.getMarks(task);
  }

  /// Лист с оценками по наряду
  List<Mark> markList = List.of({});

  /// Метод для получения оценок
  getMarks(int index) {
    markList = List.from(markRepository.getMarks(taskListController.taskListState.currentTask.value));
    if (index == 1) {markList.removeWhere((element) => element.type == "Списание");}
    if (index == 2) {markList.removeWhere((element) => element.type == "Начисление");}
    markList.sort((a, b) => a.date.compareTo(b.date));
    return markList;
  }

  /// Метод для получения оценок
  getMarksDefault() {
    markList = List.from(markRepository.getMarks(taskListController.taskListState.currentTask.value));
    markList.sort((a, b) => a.date.compareTo(b.date));
    return markList;
  }
}
