import 'package:get/get.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/notification_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/notify.dart';
import 'package:tasklist_lite/tasklist/notify_remote_client.dart';

class NotificationRepository extends GetxService {
  ///Возвращаем стрим с фикстурой, но в будущем можно будет и уведомления с сервера
  Stream<List<Notify>> streamOpenedNotifications(String basicAuth, String serverAddress) {
    ApplicationState applicationState = Get.find();
    if (applicationState.inDemonstrationMode) {
      NotificationFixtures notificationFixtures = Get.find();
      return notificationFixtures.streamOpenedNotification();
    }
    NotifyRemoteClient notifyRemoteClient = NotifyRemoteClient(basicAuth, serverAddress);
    Future<List<Notify>> result = notifyRemoteClient.getNotify();
    return result.asStream();

  }
}
