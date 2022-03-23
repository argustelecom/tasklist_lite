import 'package:get/get.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/comments_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/comment.dart';
import 'package:tasklist_lite/tasklist/task_remote_client.dart';

import 'model/task.dart';
import 'notify_remote_client.dart';

class CommentRepository extends GetxService {
  /// Добавляем новый коммент
  addNewComment(String basicAuth, String serverAddress, Task? task,
      String comment, bool isAlarm) {
    ApplicationState applicationState = Get.find();
    CommentsFixtures historyEventsFixtures = Get.find();
    if (applicationState.inDemonstrationMode.value) {
      return Future.value(historyEventsFixtures.getComments(task));
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    taskRemoteClient.addComment(task!.id, comment, isAlarm);
  }

  ///Возвращаем стрим с комментами
  Stream<List<Comment>> streamComments(
      String basicAuth, String serverAddress, Task? task) {
    ApplicationState applicationState = Get.find();
    if (applicationState.inDemonstrationMode.value) {
      CommentsFixtures historyEventsFixtures = Get.find();
      return historyEventsFixtures.streamComments(task);
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    Future<List<Comment>> result =
        taskRemoteClient.getCommentByTask(task!.id);
    return result.asStream();
  }
}
