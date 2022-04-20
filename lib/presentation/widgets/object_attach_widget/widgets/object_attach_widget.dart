import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/presentation/controllers/tasklist_controller.dart';
import 'package:tasklist_lite/presentation/widgets/expandable_fab_widget/action_button_widget.dart';
import 'package:tasklist_lite/presentation/widgets/expandable_fab_widget/expandable_fab_widget.dart';
import 'package:tasklist_lite/presentation/widgets/object_attach_widget/object_attach_controller.dart';
import 'package:tasklist_lite/presentation/widgets/object_attach_widget/widgets/file_card_widget.dart';
import 'package:tasklist_lite/presentation/dialogs/info_dialog.dart';

/// Основное тело виджета ObjectAttachWidget
/// предоставляет средства(пользовательский интерфейс) для прикладывания/удаления/скачивания вложений
class ObjectAttachWidget extends StatelessWidget {
  TaskListController taskListController = Get.find();

  @override
  Widget build(BuildContext context) {
    if (taskListController.taskListState.currentTask.value == null) {
      return Padding(
          padding: EdgeInsets.all(12),
          child: Text(
              "Что-то пошло не так. Вернитесь на главную страницу и попробуйте снова."));
    }

    return GetBuilder<ObjectAttachController>(
        init: ObjectAttachController(
            taskListController.taskListState.currentTask.value!.id),
        builder: (_) {
          return Padding(
              padding: EdgeInsets.only(left: 12,right: 12,top: 8),
              child: FutureBuilder(
                  future: _.objectAttachList.value,
                  builder: (context, ps) {
                    if (ps.connectionState == ConnectionState.done &&
                        ps.hasData) {
                      return Stack(children: <Widget>[
                        Align(
                            alignment: Alignment.topCenter,
                            child: ListView.builder(
                                itemCount: (ps.data as List).length,
                                itemBuilder: (context, index) {
                                  return FileCardWidget(
                                      (ps.data as List)[index]);
                                })),
                        Positioned(
                            bottom: 20,
                            right: 5,
                            child: Container(
                                width: 100,
                                height: 100,
                                child: !kIsWeb
                                    // Для мобильного формата заводим три кнопки для разного способа
                                    // доступа к файлам
                                    ? ExpandableFab(distance: 112.0, children: [
                                        ActionButton(
                                            icon: const Icon(
                                              Icons.panorama,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              try {
                                                await _.pickImage();
                                              } catch (e) {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return InfoDialog(
                                                          text:
                                                              "Произошла ошибка: \"$e\"");
                                                    });
                                              }
                                            }),
                                        ActionButton(
                                            icon: const Icon(
                                              Icons.camera,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              try {
                                                await _.pickCamera();
                                              } catch (e) {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return InfoDialog(
                                                          text:
                                                              "Произошла ошибка: \"$e\"");
                                                    });
                                              }
                                            }),
                                        ActionButton(
                                            icon: const Icon(
                                              Icons.article_outlined,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              try {
                                                await _.pickFiles();
                                              } catch (e) {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return InfoDialog(
                                                          text:
                                                              "Произошла ошибка: \"$e\"");
                                                    });
                                              }
                                            })
                                      ])
                                    // Для WEB достаточно одной кнопки так как навигация в рамках ОС достаточно удобна и
                                    // есть встроенные средства фильтрации
                                    : SizedBox.expand(
                                        child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: FloatingActionButton(
                                                child:
                                                    const Icon(Icons.add_sharp),
                                                backgroundColor:
                                                    Colors.yellow.shade700,
                                                onPressed: () async {
                                                  try {
                                                    await _.pickFiles();
                                                  } catch (e) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return InfoDialog(
                                                              text:
                                                                  "Произошла ошибка: \"$e\"");
                                                        });
                                                  }
                                                })))))
                      ]);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }));
        });
  }
}
