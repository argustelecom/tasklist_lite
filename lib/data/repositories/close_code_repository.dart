import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:tasklist_lite/data/repositories/task_remote_client.dart';
import 'package:tasklist_lite/presentation/state/application_state.dart';

import '../../domain/entities/close_code.dart';
import '../fixture/close_code_fixtures.dart';

class CloseCodeRepository extends GetxService {
  List<CloseCode> result = List.of({});

  Future<List<CloseCode>> getCloseCodes(
      String basicAuth, String serverAddress) {
    ApplicationState applicationState = Get.find();

    /// если включен деморежим, получаем данные из фикстур
    if (applicationState.inDemonstrationMode.value) {
      Get.put(CloseCodeFixtures());
      CloseCodeFixtures closeCodeFixtures = Get.find();
      return Future.value(closeCodeFixtures.getCloseCodes());
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    return taskRemoteClient.getCloseCodes().whenComplete(() => null);
  }
}
