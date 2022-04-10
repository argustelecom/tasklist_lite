import 'package:get/get.dart';
import 'package:tasklist_lite/data/repositories/task_remote_client.dart';
import 'package:tasklist_lite/domain/entities/comment.dart';
import 'package:tasklist_lite/presentation/state/application_state.dart';

import '../../domain/entities/task.dart';
import '../fixture/comments_fixtures.dart';

class CommentRepository extends GetxService {
  /// Добавляем новый коммент
  addNewComment(String basicAuth, String serverAddress, Task? task,
      String comment, bool isAlarm) {
    ApplicationState applicationState = Get.find();
    CommentsFixtures commentsFixtures = Get.find();
    if (applicationState.inDemonstrationMode.value) {
      return Future.value(commentsFixtures.getComments(task));
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
      CommentsFixtures commentsFixtures = Get.find();
      return commentsFixtures.streamComments(task);
    }
    TaskRemoteClient taskRemoteClient =
        TaskRemoteClient(basicAuth, serverAddress);
    if (task != null) {
      Future<List<Comment>> result = taskRemoteClient.getCommentByTask(task.id);
      return result.asStream();
    } else {
      return Stream.empty();
    }
  }
}
