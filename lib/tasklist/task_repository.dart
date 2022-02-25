import 'dart:async';

import 'package:get/get.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/task_remote_client.dart';

import 'model/task.dart';

class TaskRepository extends GetxService {
  // TODO переделать текущую реализацию вывова TaskRemoteClient,
  //  необходимо избавиться от постоянного создания TaskRemoteClient при вызове методов

  List<Task> getTasks(String basicAuth, String serverAddress) {
    /// получим таски из backend`а по graphQL, а если ничего не получим,
    /// то из соответствующего (то есть выбранного в настройках) профиля фикстурки
    // #TODO: пока не делаем это, надо отладить взаимодействие с сервером
    // TODO: проверить
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    List<Task> result = taskRemoteClient.getOpenedTasks() as List<Task> ;
    if (result.isNotEmpty) {
      return result;
    }
    // прочитаем значение опции и используем соответствующую фикстуру
    ApplicationState applicationState = Get.find();
    TaskFixtures taskFixtures = Get.find();
    return taskFixtures.getTasks();
  }

  ///****************************************************************************
  /// Возвращает reactive поток с открытыми задачами для слоя представления. Может получать
  /// задачи как из бакенда на сервере, так и из фикстуры
  ///****************************************************************************
  Stream<List<Task>> streamOpenedTasks(String basicAuth, String serverAddress) {
    ApplicationState applicationState = Get.find();
    if (applicationState.inDemonstrationMode) {
      TaskFixtures taskFixtures = Get.find();
      return taskFixtures.streamOpenedTasks();
    }

    Future<List<Task>> result = Future(() => List.of({}));
    try {
      TaskRemoteClient taskRemoteClient =
          TaskRemoteClient(basicAuth, serverAddress);
      result = taskRemoteClient.getOpenedTasks();
    } catch (e) {
      // TODO fix me do nothing
    }
    return result.asStream();
  }

  ///****************************************************************************
  /// Возвращает reactive поток с закрытыми задачами для слоя представления. Может получать
  /// задачи как из бакенда на сервере, так и из фикстуры
  ///****************************************************************************
  Stream<List<Task>> streamClosedTasks(
      String basicAuth, String serverAddress, DateTime day) {
    ApplicationState applicationState = Get.find();
    if (applicationState.inDemonstrationMode) {
      TaskFixtures taskFixtures = Get.find();
      return taskFixtures.streamClosedTasks(day);
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    Future<List<Task>> result = taskRemoteClient.geClosedTasks(day);
    return result.asStream();
  }
}
