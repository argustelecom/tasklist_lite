import 'package:get/get.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/history_events_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/history_event.dart';
import 'package:tasklist_lite/tasklist/task_remote_client.dart';

import 'model/task.dart';

class HistoryEventRepository extends GetxService {
  /// Получаем список исторических событий
  Future<List<HistoryEvent>> getHistoryEvent(String basicAuth, String serverAddress, Task task) {
    ApplicationState applicationState = Get.find();
    HistoryEventsFixtures historyEventsFixtures = Get.find();
    if (applicationState.inDemonstrationMode.value) {
      return Future.value(historyEventsFixtures.getHistoryEvents(task)) ;
    }
    TaskRemoteClient taskRemoteClient = TaskRemoteClient(basicAuth, serverAddress);
    return taskRemoteClient.getCommentByTask(task.id);

  }

  /// Добавляем новый коммент
  addNewComment(String basicAuth, String serverAddress, Task task, String comment, bool isAlarm) {
    ApplicationState applicationState = Get.find();
    HistoryEventsFixtures historyEventsFixtures = Get.find();
    if (applicationState.inDemonstrationMode.value) {
      return Future.value(historyEventsFixtures.getHistoryEvents(task)) ;
    }
    TaskRemoteClient taskRemoteClient = TaskRemoteClient(basicAuth, serverAddress);
    taskRemoteClient.addComment(task.id, comment,isAlarm);
  }
}
