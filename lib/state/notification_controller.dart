import 'dart:async';
import 'package:get/get.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:tasklist_lite/tasklist/task_repository.dart';
import 'package:tasklist_lite/tasklist/fixture/notification_fixtures.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/notify.dart';
import 'package:tasklist_lite/crazylib/notification_card.dart';
import 'package:tasklist_lite/crazylib/date_row.dart';

class NotificationController extends GetxController {
  List <Notify> aliveNotifications = List.of({});
  List <Notify> deadNotifications = List.of({});
  List <DateRow> dateList = List.of({});

  addAliveNotification(Notify notify){
    aliveNotifications.add(notify);
    update();
  }

  removeAliveNotification(Notify notify){
    aliveNotifications.remove(notify);
    update();
  }

  addDeadNotifications(Notify notify){
    deadNotifications.add(notify);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    start();
  }

  List<Notify> getNotification() {
    return aliveNotifications;
  }

  start(){
    return aliveNotifications=List.of(NotificationFixtures.firstNotifyFixture);
  }

}
