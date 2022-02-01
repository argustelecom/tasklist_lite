import 'package:get/get.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/fixture/notification_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/notify.dart';


class NotificationRepository extends GetxService{

  ///Возвращаем стрим с фикстурой, но в будущем можно будет и уведомления с сервера
  Stream<List<Notify>> streamOpenedNotifications() {
    ApplicationState applicationState = Get.find();
    if (applicationState.currentTaskFixture != CurrentTaskFixture.noneFixture) {
      NotificationFixtures notificationFixtures = Get.find();
      return notificationFixtures
          .streamOpenedNotification(applicationState.currentTaskFixture);
    }
    // #TODO: Тут в будущем будем получать уведомления от сервера
    NotificationFixtures notificationFixtures = Get.find();
    return notificationFixtures.streamOpenedNotification(CurrentTaskFixture.thirdFixture);
  }
}