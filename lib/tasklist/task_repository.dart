import 'dart:async';

import 'package:get/get.dart' hide Worker;
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/fixture/worker_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/worker.dart';
import 'package:tasklist_lite/tasklist/task_remote_client.dart';

import 'fixture/idle_time_reason_fixtures.dart';
import 'fixture/work_type_fixtures.dart';
import 'model/idle_time.dart';
import 'model/task.dart';
import 'model/work.dart';

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

  Future<bool?> completeStage(
      String basicAuth, String serverAddress, int taskInstanceId) async {
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

  Future<Work> registerWorkDetail(
      String basicAuth,
      String serverAddress,
      int taskInstanceId,
      int workTypeId,
      bool notRequired,
      double? amount,
      List<int>? workers) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем успех
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));

      WorkType workType =
          WorkTypeFixtures.workTypes.firstWhere((e) => e.id == workTypeId);
      if (notRequired) {
        return new Work(workType: workType, workDetail: [], notRequired: true);
      }

      double marksPerWorker = workType.marks * amount! / workers!.length;
      Iterable<Worker> workerList = workers.expand(
          (e1) => [WorkerFixtures.workers.firstWhere((e2) => e2.id == e1)]);
      Map<Worker, double> workerMarks = Map<Worker, double>.fromIterable(
          workerList,
          key: (item) => item,
          value: (item) => marksPerWorker);

      return new Work(workType: workType, workDetail: [
        new WorkDetail(
            id: 1,
            amount: amount,
            date: DateTime.now(),
            workerMarks: workerMarks)
      ]);
    }

    /// TODO: если деморежим выключен, нужно отправлять graphQL запрос
    throw Exception("API в разработке");
  }

  Future<Work?> deleteWorkDetail(String basicAuth, String serverAddress,
      int taskInstanceId, int workDetailId) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем успех
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));
      return null;

      // можно раскомментировать для отладки кейса, когда удалена не последняя отметка
      // return new Work(workType: WorkTypeFixtures.workType_1, workDetail: [
      //   new WorkDetail(
      //       id: 1,
      //       amount: 2,
      //       date: DateTime.now(),
      //       workerMarks: {WorkerFixtures.worker_1: 10})
      // ]);
    }

    /// TODO: если деморежим выключен, нужно отправлять graphQL запрос
    throw Exception("API в разработке");
  }
}
