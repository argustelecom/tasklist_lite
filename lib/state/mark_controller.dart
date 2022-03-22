import 'dart:async';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:tasklist_lite/state/tasklist_controller.dart';
import 'package:tasklist_lite/tasklist/mark_repository.dart';
import 'package:tasklist_lite/tasklist/model/mark.dart';
import 'auth_state.dart';

class MarkController extends GetxController {
  /// Ищем нужные нам оценки
  MarkRepository markRepository = Get.find();
  TaskListController taskListController = Get.find();
  AuthState authState = Get.find();

  /// Подписка на комментарии
  StreamSubscription? markSubscription;

  /// Метод переподписки, скидывает старый стрим и слушает новый
  StreamSubscription resubscribe(
      StreamSubscription? streamSubscription,
      Stream<List<Mark>> stream,
      void onData(List<Mark> event)) {
    streamSubscription?.cancel();
    return stream.listen(onData);
  }

  /// Инициализируем список оценок
  @override
  void onInit() {
    super.onInit();

    markSubscription = resubscribe(
        markSubscription,
        markRepository.streamMarks(
            authState.authString.value!,
            authState.serverAddress.value!,
            taskListController.taskListState.currentTask.value), (event) {
      List<Mark> marks = event;
      this.markList = marks;
      update();
    });
  }

  /// Сбрасываем стрим
  @override
  void onClose() {
    markSubscription?.cancel();
    super.onClose();
  }

  /// Лист с оценками по наряду
  List<Mark> markList = List.of({});

  /// Метод для получения оценок
  getMarks(int index) {
    if (index == 1) {
      return markList.where((element) => element.type == "Добавление").toList();
    }
    if (index == 2) {
      return markList.where((element) => element.type == "Списание").toList();
    }
    return markList;
  }
}
