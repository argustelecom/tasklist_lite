import 'package:get/get.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/task_remote_client.dart';

import 'model/task.dart';

class TaskRepository extends GetxService {
  TaskRemoteClient taskRemoteClient = TaskRemoteClient();

  List<Task> getTasks() {
    /// получим таски из backend`а по graphQL, а если ничего не получим,
    /// то из соответствующего (то есть выбранного в настройках) профиля фикстурки
    // #TODO: пока не делаем это, надо отладить взаимодействие с сервером
    /* List<Task> result = taskRemoteClient.getOpenedTasks();
    if (result.isNotEmpty) {
      return result;
    }*/
    // прочитаем значение опции и используем соответствующую фикстуру
    ApplicationState applicationState = Get.find();
    TaskFixtures taskFixtures = Get.find();
    return taskFixtures.getTasks(applicationState.currentTaskFixture);
  }

  ///****************************************************************************
  /// Возвращает reactive поток с открытыми задачами для слоя представления. Может получать
  /// задачи как из бакенда на сервере, так и из фикстуры
  ///****************************************************************************
  Stream<List<Task>> streamOpenedTasks() {
    ApplicationState applicationState = Get.find();
    if (applicationState.currentTaskFixture != CurrentTaskFixture.noneFixture) {
      TaskFixtures taskFixtures = Get.find();
      return taskFixtures
          .streamOpenedTasks(applicationState.currentTaskFixture);
    }
    // #TODO: обращение к TaskRemoteClient еще не реализовано
    TaskFixtures taskFixtures = Get.find();
    return taskFixtures.streamOpenedTasks(CurrentTaskFixture.thirdFixture);
  }

  ///****************************************************************************
  /// Возвращает reactive поток с закрытыми задачами для слоя представления. Может получать
  /// задачи как из бакенда на сервере, так и из фикстуры
  ///****************************************************************************
  Stream<List<Task>> streamClosedTasks(DateTime day) {
    ApplicationState applicationState = Get.find();
    if (applicationState.currentTaskFixture != CurrentTaskFixture.noneFixture) {
      TaskFixtures taskFixtures = Get.find();
      return taskFixtures.streamClosedTasks(
          applicationState.currentTaskFixture, day);
    }
    // #TODO: обращение к TaskRemoteClient еще не реализовано
    TaskFixtures taskFixtures = Get.find();
    return taskFixtures.streamClosedTasks(CurrentTaskFixture.thirdFixture, day);
  }
}
