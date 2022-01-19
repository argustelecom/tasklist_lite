import 'package:get/get.dart';
import 'package:tasklist_lite/tasklist/fixture/notification_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/notify.dart';


class NotificationController extends GetxController {

  /// Список уведомлений, которые еще не прочитаны. Его будем выводить на UI
  List <Notify> aliveNotifications = List.of({});

  /// Список уведомлений, которые уже прочитаны. Их пока просто храним.
  List <Notify> deadNotifications = List.of({});

  /// Для тех кто хочет знать, есть ли у нас сейчас живые уведомления
  haveNotification(){
    if (aliveNotifications.length>0){
      return true;
    }
    else {
      return false;}
  }

  /// Метод для добавления нового уведомления в список живых уведомлений. Пока нигде не применяется
  addAliveNotification(Notify notify){
    aliveNotifications.add(notify);
    update();
  }

  /// Метод для удаления уведомления из списка живых уведомлений
  removeAliveNotification(Notify notify){
    aliveNotifications.remove(notify);
    update();
  }

  /// Метод для добавления уведомления в список с прочитанными уведомлениями
  addDeadNotifications(Notify notify){
    deadNotifications.add(notify);
    update();
  }

  /// При инициализации странички всегда тащим данные с фикструры NotificationFixtures.firstNotifyFixture c помощью метода start()
  // #TODO: Переосмыслить и переделать в будущем
  @override
  void onInit() {
    super.onInit();
    start();

  }

  /// Метод для получения списка уведомлений
  List<Notify> getNotification() {
    return aliveNotifications;
  }

  /// Данный метод используем только для инициализации
  // #TODO: В будущем нужно тянуть нужную фикстуру, пока что там она всего одна
  start(){
    return aliveNotifications = NotificationFixtures.firstNotifyFixture;
  }

  }




