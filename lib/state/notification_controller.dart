import 'dart:async';

import 'package:get/get.dart';
import 'package:tasklist_lite/state/auth_state.dart';
import 'package:tasklist_lite/tasklist/model/notify.dart';
import 'package:tasklist_lite/tasklist/notification_repository.dart';

class NotificationController extends GetxController {
  /// Список уведомлений, которые еще не прочитаны. Его будем выводить на UI
  List<Notify> aliveNotifications = List.of({});

  /// Список уведомлений, которые уже прочитаны. Их пока просто храним.
  List<Notify> deadNotifications = List.of({});

  /// Для тех кто хочет знать, есть ли у нас сейчас живые уведомления
  haveNotifications() {
    return (aliveNotifications.length > 0);
  }

  /// Метод для добавления нового уведомления в список живых уведомлений. Пока нигде не применяется
  addAliveNotification(Notify notify) {
    aliveNotifications.add(notify);
    update();
  }

  /// Метод для удаления уведомления из списка живых уведомлений
  removeAliveNotification(Notify notify) {
    aliveNotifications.remove(notify);
    update();
  }

  /// Метод для добавления уведомления в список с прочитанными уведомлениями
  addDeadNotification(Notify notify) {
    deadNotifications.add(notify);
    update();
  }

  /// Метод для получения списка уведомлений
  List<Notify> getNotifications() {
    aliveNotifications.sort((a, b) => b.date.compareTo(a.date));
    return aliveNotifications;
  }

  /// Подписка на непрочитанные уведомления
  StreamSubscription? openedNotificationSubscription;

  /// Ищем репозиторий уведомлений
  NotificationRepository notificationRepository = Get.find();

  /// Метод переподписки, скидывает старый стрим и слушает новый
  StreamSubscription resubscribe(StreamSubscription? streamSubscription,
      Stream<List<Notify>> stream, void onData(List<Notify> event)) {
    streamSubscription?.cancel();
    return stream.listen(onData);
  }

  /// При инициализации ловим стрим и наполняем aliveNotifications
  @override
  void onInit() {
    super.onInit();
    // к authState можно так обращаться, т.к. он создается очень рано, вместе с AuthController`ом
    // еще до создания самого приложения в main.
    AuthState authState = Get.find();

    openedNotificationSubscription = resubscribe(
        openedNotificationSubscription,
        notificationRepository.streamOpenedNotifications(
            authState.authString.value!, authState.serverAddress.value!),
        (event) {
      //Только те, что отсутсвуют в deadNotifications
      List<Notify> newOpenNotify = event
          .where((element) =>
              !deadNotifications.map((e) => e.id).contains(element.id))
          .toList();
      this.aliveNotifications = newOpenNotify;
      update();
    });
  }

  /// Сбрасываем стрим
  @override
  void onClose() {
    openedNotificationSubscription?.cancel();
    super.onClose();
  }
}
