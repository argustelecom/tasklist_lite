import 'package:get/get.dart';
import 'package:tasklist_lite/data/repositories/notify_remote_client.dart';
import 'package:tasklist_lite/data/repositories/task_remote_client.dart';
import 'package:tasklist_lite/domain/entities/notify.dart';
import 'package:tasklist_lite/presentation/state/application_state.dart';

import '../fixture/notification_fixtures.dart';

class NotificationRepository extends GetxService {
  ///Возвращаем стрим с фикстурой, но в будущем можно будет и уведомления с сервера
  Stream<List<Notify>> streamOpenedNotifications(
      String basicAuth, String serverAddress) {
    ApplicationState applicationState = Get.find();
    if (applicationState.inDemonstrationMode.value) {
      NotificationFixtures notificationFixtures = Get.find();
      return notificationFixtures.streamOpenedNotification();
    }
    NotifyRemoteClient notifyRemoteClient =
        NotifyRemoteClient(basicAuth, serverAddress);
    Future<List<Notify>> result = notifyRemoteClient.getNotify();
    return result.asStream();
  }

  void readNotify(String basicAuth, String serverAddress, Notify notify) {
    ApplicationState applicationState = Get.find();
    if (!applicationState.inDemonstrationMode.value) {
      TaskRemoteClient taskRemoteClient =
          TaskRemoteClient(basicAuth, serverAddress);
      taskRemoteClient.readNotify(notify.id);
    }
  }
}
