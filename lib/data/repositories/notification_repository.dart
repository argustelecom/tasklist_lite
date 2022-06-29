import 'package:get/get.dart';
import 'package:tasklist_lite/core/state/current_app_info.dart';
import 'package:tasklist_lite/data/remote/notify_remote_client.dart';
import 'package:tasklist_lite/data/remote/task_remote_client.dart';
import 'package:tasklist_lite/domain/entities/notify.dart';

import '../fixture/notification_fixtures.dart';

class NotificationRepository extends GetxService {
  ///Возвращаем стрим с фикстурой, но в будущем можно будет и уведомления с сервера
  Stream<List<Notify>> streamOpenedNotifications() {
    CurrentAppInfo currentAppInfo = Get.find();
    if (currentAppInfo.isAppInDemonstrationMode()) {
      NotificationFixtures notificationFixtures = Get.find();
      return notificationFixtures.streamOpenedNotification();
    }
    NotifyRemoteClient notifyRemoteClient = NotifyRemoteClient();
    return notifyRemoteClient.streamNotify();
  }

  void readNotify(Notify notify) {
    CurrentAppInfo currentAppInfo = Get.find();
    if (!currentAppInfo.isAppInDemonstrationMode()) {
      TaskRemoteClient taskRemoteClient = TaskRemoteClient();
      taskRemoteClient.readNotify(notify.id);
    }
  }
}
