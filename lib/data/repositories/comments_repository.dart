import 'package:get/get.dart';
import 'package:tasklist_lite/core/state/current_app_info.dart';
import 'package:tasklist_lite/data/repositories/task_remote_client.dart';
import 'package:tasklist_lite/domain/entities/comment.dart';

import '../../domain/entities/task.dart';
import '../fixture/comments_fixtures.dart';

class CommentRepository extends GetxService {
  /// Добавляем новый коммент
  addNewComment(Task? task, String comment, bool isAlarm) {
    CurrentAppInfo currentAppInfo = Get.find();
    CommentsFixtures commentsFixtures = Get.find();
    if (currentAppInfo.isAppInDemonstrationMode()) {
      return Future.value(commentsFixtures.getComments(task));
    }
    TaskRemoteClient taskRemoteClient = TaskRemoteClient();
    taskRemoteClient.addComment(task!.id, comment, isAlarm);
  }

  ///Возвращаем стрим с комментами
  Stream<List<Comment>> streamComments(Task? task) {
    CurrentAppInfo currentAppInfo = Get.find();
    if (currentAppInfo.isAppInDemonstrationMode()) {
      CommentsFixtures commentsFixtures = Get.find();
      return commentsFixtures.streamComments(task);
    }
    TaskRemoteClient taskRemoteClient = TaskRemoteClient();
    if (task != null) {
      Future<List<Comment>> result = taskRemoteClient.getCommentByTask(task.id);
      return result.asStream();
    } else {
      return Stream.empty();
    }
  }
}
