import 'package:tasklist_lite/tasklist/model/notify.dart';


/// Служба, возвращающая набор нотификаций
class NotificationFixtures {

 static List<Notify> firstNotifyFixture = List.of(
     { new Notify(id: 1, time: "17.00", text: "Назначена задача АВР-123564", date: DateTime.now(), task: 2, number: 'АВР-123564'),
       new Notify(id: 1, time: "16.00", text: "Назначена задача АВР-123564", date: DateTime.now(), task: 2, number: 'АВР-123564'),
       new Notify(id :2, time: "15.00", text: "Назначена задача АВР-78945646" , date: DateTime.now().subtract(Duration(days:1)), task: 3, number:'АВР-78945646'),
       new Notify(id :2, time: "14.00", text: "Назначена задача АВР-78945646" , date: DateTime.now().subtract(Duration(days:1)), task: 3, number:'АВР-78945646'),
       new Notify(id: 3, time: "12.00", text: "Осталось 30 минут до окончания этапа работ по наряду АВР-25836974(45-33)" ,date: DateTime.now().subtract(Duration(days:2)), task: 4, number: 'АВР-25836974'),
       new Notify(id: 3, time: "11.00", text: "Осталось 30 минут до окончания этапа работ по наряду АВР-25836974(45-33)" ,date: DateTime.now().subtract(Duration(days:2)), task: 4, number: 'АВР-25836974')

     });

 List<Notify> getNotify() {
            return firstNotifyFixture;
        }
}
