import 'dart:async';

import 'package:get/get.dart' hide Worker;
import 'package:tasklist_lite/data/repositories/task_remote_client.dart';
import 'package:tasklist_lite/domain/entities/worker.dart';
import 'package:tasklist_lite/presentation/state/application_state.dart';

import '../../domain/entities/close_code.dart';
import '../../domain/entities/idle_time.dart';
import '../../domain/entities/stage.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/work.dart';
import '../fixture/task_fixtures.dart';
import '../fixture/work_type_fixtures.dart';

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

  Future<Task> registerIdle(String basicAuth, String serverAddress, Task task,
      IdleTimeReason reason, DateTime beginTime, DateTime? endTime) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем созданный простой
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));
      IdleTime newIdleTime = new IdleTime(
          id: 1, reason: reason, startDate: beginTime, endDate: endTime);
      if (task.idleTimeList == null || task.idleTimeList!.isEmpty) {
        task.idleTimeList = [newIdleTime];
      } else {
        task.idleTimeList!.add(newIdleTime);
      }
      return task;
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    return await taskRemoteClient.registerIdle(
        task.id, reason.id, beginTime, endTime);
  }

  Future<Task> finishIdle(String basicAuth, String serverAddress, Task task,
      DateTime beginTime, DateTime endTime) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем завершенный простой
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));
      int i = task.idleTimeList!.indexWhere((e) => e.endDate == null);
      IdleTime newIdleTime = task.idleTimeList![i];
      newIdleTime.endDate = DateTime.now();
      task.idleTimeList!.replaceRange(i, i + 1, [newIdleTime]);
      return task;
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    return await taskRemoteClient.finishIdle(task.id, beginTime, endTime);
  }

  Future<Task> completeStage(
      String basicAuth, String serverAddress, Task task) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем успех
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));
      if (task.stage != null) {
        Stage stage;
        switch (task.stage!.number) {
          case 1:
            stage = Stage(
                name: "Выезд на объект",
                number: 2,
                isLast: false,
                dueDate: task.stage!.dueDate);
            break;
          case 2:
            stage = Stage(
                name: "Прибытие на объект",
                number: 3,
                isLast: false,
                dueDate: task.stage!.dueDate);
            break;
          case 3:
            stage = Stage(
                name: "Выполнение работ",
                number: 4,
                isLast: true,
                dueDate: task.stage!.dueDate);
            break;
          default:
            stage = task.stage!;
        }
        task.stage = stage;
      }
      return task;
    }

    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);

    return await taskRemoteClient.endStage(task.id);
  }

  Future<Task> closeOrder(String basicAuth, String serverAddress, Task task,
      CloseCode closeCode) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем успех
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));
      task.stage = null;
      task.isClosed = true;
      task.closeDate = DateTime.now();
      return task;
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    return await taskRemoteClient.closeOrder(task.id, closeCode.id);
  }

  Future<Work> registerWorkDetail(
      String basicAuth,
      String serverAddress,
      Task task,
      WorkType workType,
      bool notRequired,
      double? amount,
      List<Worker>? workers) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем успех
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));

      if (notRequired) {
        return new Work(workType: workType, workDetail: [], notRequired: true);
      }

      double marksPerWorker = workType.marks * amount! / workers!.length;
      Map<Worker, double> workerMarks = Map<Worker, double>.fromIterable(
          workers,
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
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    List<int> workersIds = (workers != null && workers.isNotEmpty)
        ? workers.expand((e) => [e.id]).toList()
        : [];
    return await taskRemoteClient.registerWorkDetail(
        task.id, workType.id, notRequired, amount, workersIds);
  }

  Future<Work> deleteWorkDetail(String basicAuth, String serverAddress,
      Task task, WorkDetail workDetail) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем успех
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));
      return new Work(workType: WorkTypeFixtures.workType_1);

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
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    return await taskRemoteClient.deleteWorkDetail(task.id, workDetail.id);
  }

  Future<bool> markWorksNotRequired(String basicAuth, String serverAddress,
      Task task, List<WorkType> workTypes) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, возвращаем успех
    if (applicationState.inDemonstrationMode.value) {
      await new Future.delayed(const Duration(seconds: 3));
      return true;
    }

    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    return await taskRemoteClient.markWorksNotRequired(
        task.id, workTypes.expand((e) => [e.id]).toList());
  }
}
