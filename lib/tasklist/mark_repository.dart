import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:tasklist_lite/state/application_state.dart';

import 'fixture/mark_fixtures.dart';
import 'model/mark.dart';
import 'model/task.dart';

class MarkRepository extends GetxService {
  /// Получаем из фикстуры список исторических событий
  List<Mark> getMarks(Task? task) {
    ApplicationState applicationState = Get.find();
    MarkFixtures markFixtures = Get.find();
    if (applicationState.inDemonstrationMode.value) {
      return markFixtures.getMarks();
    }
    return markFixtures.getMarks();
  }
}
