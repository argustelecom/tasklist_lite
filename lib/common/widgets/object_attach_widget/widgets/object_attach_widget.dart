import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/common/widgets/expandable_fab_widget/action_button_widget.dart';
import 'package:tasklist_lite/common/widgets/expandable_fab_widget/expandable_fab_widget.dart';
import 'package:tasklist_lite/common/widgets/object_attach_widget/object_attach_controller.dart';
import 'package:tasklist_lite/common/widgets/object_attach_widget/widgets/file_card_widget.dart';


/// Основное тело виджета ObjectAttachWidget
/// один входной параметр objectId - объект, для которого будут получаться и отображаться вложения
/// предоставляет средства(пользовательский интерфейс) для прикладывания/удаления/скачивания вложений
class ObjectAttachWidget extends StatelessWidget {
  final int objectId;

  ObjectAttachWidget(this.objectId);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ObjectAttachController>(
        init: ObjectAttachController(objectId),
        builder: (_) {
          return FutureBuilder(
              future: _.objectAttachList.value,
              builder: (context, ps) {
                if (ps.connectionState == ConnectionState.done && ps.hasData) {
                  return Stack(children: <Widget>[
                    Align(
                        alignment: Alignment.topCenter,
                        child: ListView.builder(
                            itemCount: (ps.data as List).length,
                            itemBuilder: (context, index) {
                              return FileCardWidget((ps.data as List)[index]);
                            })),
                    !kIsWeb
                    // Для мобильного формата заводим три кнопки для разного способа
                    // доступа к файлам
                        ? Align(
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
                          )
                    // Для WEB достаточно одной кнопки так как навигация в рамках ОС достаточно удобна и
                    // есть встроенные средства фильтрации
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                              onPressed: () => {_.pickFiles()},
                              child: const Icon(Icons.add_sharp),
                              backgroundColor: Colors.yellow.shade700,
                            ),
                          ),
                  ]);
                }
                else {
                  return Center(child: CircularProgressIndicator());
                }
              });
        });
  }
}
