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
    List<Task> result = taskRemoteClient.getTasks();
    if (result.isNotEmpty) {
      return result;
    }
    // прочитаем значение опции и используем соответствующую фикстуру
    ApplicationState applicationState = Get.find();
    TaskFixtures taskFixtures = Get.find();
    return taskFixtures.getTasks(applicationState.currentTaskFixture);
  }
}
