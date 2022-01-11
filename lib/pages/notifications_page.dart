import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
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
  final dt = new  DateFormat('dd MMMM yyyy', "ru_RU").format(DateTime.now());
  final dt1 = new DateFormat('dd MMMM yyyy', "ru_RU").format(DateTime.now().subtract(Duration(days:1)));

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    ApplicationState applicationState = ApplicationState.of(context);
    return Scaffold(
        appBar: AppBar(
          title: new Text("Уведомления"),
        ),
        body:Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Text("СЕГОДНЯ - $dt",
                  textAlign:  TextAlign.center,), //Сюда выводим вчерашнюю дату
                decoration: BoxDecoration(
                    color: themeData.cardColor,
                    shape: BoxShape.rectangle
                ),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              ),
              SizedBox(
                height: 350.0,// #TODO: Если высоту не указать, не сможет создать виджет.
                child: ListView.builder(
                  shrinkWrap: false,
                  itemCount: test1.length,
                  itemBuilder: (BuildContext context, int index) {
                    return NotificationCard(notify: test1[index]);
                  },
                ),
              ),
              Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text("ВЧЕРА - $dt1",
                          textAlign:  TextAlign.center,), //Сюда выводим вчерашнюю дату
                    decoration: BoxDecoration(
                    color: themeData.cardColor,
                    shape: BoxShape.rectangle
                    ),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              ),
              SizedBox(
                height: 350.0,// #TODO: Если высоту не указать, не сможет создать виджет.
                child: ListView.builder(
                  shrinkWrap: false,
                  itemCount: test1.length,
                  itemBuilder: (BuildContext context, int index) {
                    return NotificationCard(notify: test1[index]);
                  },
                ),
              ),
            ],
          ),
          ),
        bottomNavigationBar: BottomButtonBar());
  }
}
