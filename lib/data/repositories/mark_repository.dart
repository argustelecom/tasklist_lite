import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:tasklist_lite/data/repositories/task_remote_client.dart';
import 'package:tasklist_lite/presentation/state/application_state.dart';

import '../../domain/entities/mark.dart';
import '../../domain/entities/task.dart';
import '../fixture/mark_fixtures.dart';

class MarkRepository extends GetxService {
  Future<List<Mark>> getMarks(
      String basicAuth, String serverAddress, Task? task) async {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, получаем данные из фикстур
    if (applicationState.inDemonstrationMode.value) {
      Get.put(MarkFixtures());
      MarkFixtures markFixtures = Get.find();
      return Future.value(markFixtures.markFixture);
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    return await taskRemoteClient.getMarks(task!.id);
  }

  Stream<List<Mark>> streamMarks(
      String basicAuth, String serverAddress, Task? task) {
    ApplicationState applicationState = Get.find();
    if (applicationState.inDemonstrationMode.value) {
      Get.put(MarkFixtures());
      MarkFixtures markFixtures = Get.find();
      return markFixtures.streamComments(task);
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    Future<List<Mark>> result = taskRemoteClient.getMarks(task!.id);
    return result.asStream();
  }
}
