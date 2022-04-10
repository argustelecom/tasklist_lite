import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/presentation/controllers/tasklist_controller.dart';
import 'package:tasklist_lite/presentation/dialogs/works_manager_dialog.dart';

import '../../../domain/entities/work.dart';
import '../../dialogs/adaptive_dialog.dart';
import '../crazy_highlight.dart';

class WorkCard extends StatelessWidget {
  final Work work;

  const WorkCard({Key? key, required this.work}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    Widget? workStatus = Row();
    if (work.notRequired) {
      workStatus = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.close,
            color: Color(0xFF646363),
            size: 12,
          ),
          SizedBox(width: 8),
          Text("Не требуется",
              style: TextStyle(color: Color(0xFF646363), fontSize: 12))
        ],
      );
    } else if (work.workDetail == null || work.workDetail!.isEmpty) {
      workStatus = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.done,
            color: Color(0xFF287BF6),
            size: 12,
          ),
          SizedBox(width: 8),
          Text("Не выполнена",
              style: TextStyle(color: Color(0xFF287BF6), fontSize: 12))
        ],
      );
    } else if (work.workDetail != null && work.workDetail!.isNotEmpty) {
      workStatus = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.done_all,
            color: Color(0xFF2FB62C),
            size: 12,
          ),
          SizedBox(width: 8),
          Text("Выполнена",
              style: TextStyle(color: Color(0xFF2FB62C), fontSize: 12))
        ],
      );
    }

    return Card(
        child: InkWell(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Expanded(
                        child: GetBuilder<TaskListController>(
                            builder: (taskListController) {
                          return CrazyHighlight(
                            text: work.workType.name,
                            term: taskListController.searchWorksText,
                            textStyle: TextStyle(
                                color: themeData.colorScheme.onPrimary,
                                fontSize: 16),
                          );
                        }),
                      )
                    ]),
                    SizedBox(height: 8),
                    workStatus
                  ],
                )),
            onTap: () async {
              showAdaptiveDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return WorksManagerDialog(work: work);
                  });
            }));
  }
}
