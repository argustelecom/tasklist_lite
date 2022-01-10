import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tasklist_lite/crazylib/bottom_button_bar.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/notification_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/notify.dart';
import 'package:tasklist_lite/crazylib/notification_card.dart';


class NotificationsPage extends StatefulWidget {
  static const String routeName = 'Notifications';

  NotificationsPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  List<Notify> test1 = new NotificationFixtures().getNotify();
  final dt = new DateTime.now();
  final dt1 = new DateTime.now().subtract(Duration(days:1));

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    ApplicationState applicationState = ApplicationState.of(context);
    return Scaffold(
        appBar: AppBar(
          title: new Text("Уведомления"),
        ),
        body:Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.98,
              child: Text("СЕГОДНЯ - $dt",
                textAlign:  TextAlign.center,), //Сюда выводим вчерашнюю дату
              decoration: BoxDecoration(
                  color: themeData.cardColor,
                  shape: BoxShape.rectangle
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
            SizedBox(
              height: 400.0,// #TODO: Если высоту не указать, не сможет создать виджет.
              child: ListView.builder(
                shrinkWrap: false,
                itemCount: test1.length,
                itemBuilder: (BuildContext context, int index) {
                  return NotificationCard(notify: test1[index]);
                },
              ),
            ),
            Container(
                  width: MediaQuery.of(context).size.width * 0.98,
                  child: Text("ВЧЕРА - $dt1",
                        textAlign:  TextAlign.center,), //Сюда выводим вчерашнюю дату
                  decoration: BoxDecoration(
                  color: themeData.cardColor,
                  shape: BoxShape.rectangle
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
            Container(
                width: MediaQuery.of(context).size.width * 0.98,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ExpansionTile(
                  title: Text("10.00", style: TextStyle(fontStyle: FontStyle.italic)) ,
                  subtitle: Text("АВР-25836974(45-33)"),
                  children: [
                    ListTile(
                        title: Text("Осталось 30 минут до окончания этапа работ по наряду АВР-25836974(45-33)")
                    )
                  ],
                ),

                decoration: BoxDecoration(
                    color: themeData.cardColor,
                    shape: BoxShape.rectangle)
            ),
          ],
        ),

        bottomNavigationBar: BottomButtonBar());
  }
}
