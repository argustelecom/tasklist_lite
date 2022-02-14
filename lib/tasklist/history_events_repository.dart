import 'package:get/get.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/history_events_fixtures.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';

import 'package:tasklist_lite/tasklist/model/history_event.dart';

import 'model/task.dart';

class HistoryEventRepository extends GetxService {

  /// Получаем из фикстуры список исторических событий
  List<HistoryEvent> getHistoryEvent(Task task) {
    ApplicationState applicationState = Get.find();
    HistoryEventsFixtures historyEventsFixtures = Get.find();
    if (applicationState.currentTaskFixture == CurrentTaskFixture.thirdFixture){
    return historyEventsFixtures
        .getHistoryEvents(task);}
    return historyEventsFixtures
        .getHistoryEvents(task);

  }

  /// Добавляем новый коммент
  addNewComment(HistoryEvent historyEvent){
    getHistoryEvent(historyEvent.task).add(historyEvent);
  }

}
