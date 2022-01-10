import 'package:tasklist_lite/tasklist/model/notify.dart';


/// Служба, возвращающая набор нотификаций по переданному идентификатору задачи
class NotificationFixtures {

 static List<Notify> firstNotifyFixture = List.of(
     {new Notify(id: 1, time: "16.00", text: "Назначена задача АВР-123564" , task: 2, number: 'АВР-123564'),
       new Notify(id :2, time: "14.00", text: "Назначена задача АВР-78945646" , task: 3, number:'АВР-78945646'),
       new Notify(id: 3, time: "11.00", text: "Осталось 30 минут до окончания этапа работ по наряду АВР-25836974(45-33)" , task: 4, number: 'АВР-25836974')
     });

 // static List<Notify> secondNotifyFixture = List.of(
 //     {new Notify(id: 3, time: "15.00", text: "Осталось 30 минут до окончания этапа работ по наряду АВР-25836974(45-33)" , task: 4, number: 'АВР-25836974')
 //
 //     }
 // ) пока пусть полежит

 List<Notify> getNotify() {
            return firstNotifyFixture;
        }
}
