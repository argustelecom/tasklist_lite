import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:tasklist_lite/core/state/current_app_info.dart';
import 'package:tasklist_lite/data/remote/task_remote_client.dart';

import '../../domain/entities/mark.dart';
import '../../domain/entities/task.dart';
import '../fixture/mark_fixtures.dart';

class MarkRepository extends GetxService {
  Future<List<Mark>> getMarks(Task? task) async {
    CurrentAppInfo currentAppInfo = Get.find();

    /// если включен деморежим, получаем данные из фикстур
    if (currentAppInfo.isAppInDemonstrationMode()) {
      Get.put(MarkFixtures());
      MarkFixtures markFixtures = Get.find();
      return Future.value(markFixtures.markFixture);
    }
    TaskRemoteClient taskRemoteClient = TaskRemoteClient();
    return await taskRemoteClient.getMarks(task!.id);
  }

  Stream<List<Mark>> streamMarks(Task? task) {
    CurrentAppInfo currentAppInfo = Get.find();
    if (currentAppInfo.isAppInDemonstrationMode()) {
      Get.put(MarkFixtures());
      MarkFixtures markFixtures = Get.find();
      return markFixtures.streamComments(task);
    }
    TaskRemoteClient taskRemoteClient = TaskRemoteClient();
    if (task != null) {
      return taskRemoteClient.streamMarks(task);
    } else {
      return Stream.empty();
    }
  }
}
