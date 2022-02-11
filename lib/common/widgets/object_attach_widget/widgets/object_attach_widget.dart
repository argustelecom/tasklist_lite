import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/common/widgets/expandable_fab_widget/action_button_widget.dart';
import 'package:tasklist_lite/common/widgets/expandable_fab_widget/expandable_fab_widget.dart';
import 'package:tasklist_lite/common/widgets/object_attach_widget/object_attach_controller.dart';
import 'package:tasklist_lite/common/widgets/object_attach_widget/widgets/file_card_widget.dart';

class ObjectAttachWidget extends StatelessWidget {
  final int objectId;

  ObjectAttachWidget(this.objectId);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ObjectAttachController>(
        init: ObjectAttachController(objectId),
        builder: (_) {
          return Stack(children: <Widget>[
            Align(
                alignment: Alignment.topCenter,
                child: ListView.builder(
                    itemCount: _.objectAttachList.length,
                    itemBuilder: (context, index) {
                      return FileCardWidget(_.objectAttachList[index]);
                    })),
            Align(
              alignment: Alignment.bottomCenter,
              child: ExpandableFab(
                distance: 112.0,
                children: [
                  ActionButton(
                    onPressed: () => {_.pickImage()},
                    icon: const Icon(
                      Icons.panorama,
                      color: Colors.black,
                    ),
                  ),
                  ActionButton(
                    onPressed: () => {_.pickCamera()},
                    icon: const Icon(
                      Icons.camera,
                      color: Colors.black,
                    ),
                  ),
                  ActionButton(
                    onPressed: () => {_.pickFiles()},
                    icon: const Icon(
                      Icons.article_outlined,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ]);
        });
  }
}
