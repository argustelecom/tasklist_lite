import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tasklist_lite/crazylib/bottom_button_bar.dart';
import 'package:tasklist_lite/state/application_state.dart';

class NotificationsPage extends StatefulWidget {
  static const String routeName = 'notifications';

  NotificationsPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    ApplicationState applicationState = ApplicationState.of(context);
    return Scaffold(
        appBar: AppBar(
          title: new Text(NotificationsPage.routeName),
        ),
        bottomNavigationBar: BottomButtonBar());
  }
}
