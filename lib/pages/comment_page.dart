import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:tasklist_lite/crazylib/history_event_card.dart';
import 'package:tasklist_lite/crazylib/reflowing_scaffold.dart';
import 'package:tasklist_lite/state/history_event_controller.dart';

class CommentPage extends StatefulWidget {
  static const String routeName = 'Comment';

  @override
  State<StatefulWidget> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return GetBuilder<HistoryEventController>(
        init: HistoryEventController(),
        builder: (historyEventController) {
          return ReflowingScaffold(
              appBar: AppBar(
                title: Text("Комментарий"),
                leading: IconButton(
                  icon: Icon(Icons.chevron_left_outlined),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Padding(
                  padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: Expanded(
                      child: ListView(children: [
                        HistoryEventCard(maxLines: 500,
                            comment: historyEventController.selectedComment)
                      ],)
                      )));
        });
  }
}
