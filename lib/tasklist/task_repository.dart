import 'dart:async';

import 'package:get/get.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/task_remote_client.dart';

import 'fixture/idle_time_reason_fixtures.dart';
import 'model/idle_time.dart';
import 'model/task.dart';

class TaskRepository extends GetxService {
  // TODO переделать текущую реализацию вывова TaskRemoteClient,
  //  необходимо избавиться от постоянного создания TaskRemoteClient при вызове методов

  ///****************************************************************************
  /// Возвращает reactive поток с открытыми задачами для слоя представления. Может получать
  /// задачи как из бакенда на сервере, так и из фикстуры
  ///****************************************************************************
  Stream<List<Task>> streamOpenedTasks(
      String? basicAuth, String? serverAddress) {
    ApplicationState applicationState = Get.find();
    if (applicationState.inDemonstrationMode.value) {
      TaskFixtures taskFixtures = Get.find();
      return taskFixtures.streamOpenedTasks();
    }
    // в общем случае сюда могут прийти basicAuth и serverAddress равные null
    // но это только в деморежиме ( то есть до вызова remote не дойдет)
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth!, serverAddress!);
    Future<List<Task>> result = taskRemoteClient.getOpenedTasks();
    return result.asStream();
  }

  ///****************************************************************************
  /// Возвращает reactive поток с закрытыми задачами для слоя представления. Может получать
  /// задачи как из бакенда на сервере, так и из фикстуры
  ///****************************************************************************
  Stream<List<Task>> streamClosedTasks(
      String? basicAuth, String? serverAddress, DateTime day) {
    ApplicationState applicationState = Get.find();
    if (applicationState.inDemonstrationMode.value) {
      TaskFixtures taskFixtures = Get.find();
      return taskFixtures.streamClosedTasks(day);
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth!, serverAddress!);
    Future<List<Task>> result = taskRemoteClient.getClosedTasks(day);

    return result.asStream();
  }

  Future<IdleTime?> registerIdle(
      String basicAuth,
      String serverAddress,
      int taskInstanceId,
      int reasonId,
      DateTime beginTime,
      DateTime? endTime) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем созданный простой
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));
      return new IdleTime(
          id: 1,
          reason: IdleTimeReasonFixtures.idleTimeReason_1,
          startDate: beginTime,
          endDate: endTime);
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    return await taskRemoteClient.registerIdle(
        taskInstanceId, reasonId, beginTime, endTime);
  }

  Future<IdleTime?> finishIdle(String basicAuth, String serverAddress,
      int taskInstanceId, DateTime beginTime, DateTime endTime) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем завершенный простой
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));
      return new IdleTime(
          id: 1,
          reason: IdleTimeReasonFixtures.idleTimeReason_1,
          startDate: beginTime,
          endDate: endTime);
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    return await taskRemoteClient.finishIdle(
        taskInstanceId, beginTime, endTime);
  }

  Future<bool?> completeStage(String basicAuth, String serverAddress,
      int taskInstanceId) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем успех
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));
      return true;
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    return await taskRemoteClient.endStage(taskInstanceId);
  }

  Future<bool?> completeOrder(String basicAuth, String serverAddress,
      int taskInstanceId, int closeCodeId) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем успех
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));
      return true;
    }
    TaskRemoteClient taskRemoteClient =
    TaskRemoteClient(basicAuth, serverAddress);
    return await taskRemoteClient.completeOrder(taskInstanceId, closeCodeId);
  }
}
