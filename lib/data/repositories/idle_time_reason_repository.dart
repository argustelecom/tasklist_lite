import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:tasklist_lite/data/repositories/task_remote_client.dart';
import 'package:tasklist_lite/presentation/state/application_state.dart';

import '../../domain/entities/idle_time.dart';
import '../fixture/idle_time_reason_fixtures.dart';

class IdleTimeReasonRepository extends GetxService {
  List<IdleTimeReason> result = List.of({});

  Future<List<IdleTimeReason>> getIdleTimeReasons(
      String basicAuth, String serverAddress) {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, получаем данные из фикстур
    if (applicationState.inDemonstrationMode.value) {
      Get.put(IdleTimeReasonFixtures());
      IdleTimeReasonFixtures idleTimeReasonFixtures = Get.find();
      return Future.value(idleTimeReasonFixtures.getIdleTimeReasons());
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    return taskRemoteClient.getIdleTimeReason().whenComplete(() => null);
  }
}
