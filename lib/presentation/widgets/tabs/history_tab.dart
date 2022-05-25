import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/nav2/get_router_delegate.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../controllers/comment_controller.dart';
import '../../controllers/text_field_colorizer.dart';
import '../../pages/comment_page.dart';
import '../cards/comment_card.dart';

/// Вкладка история для taskPage

class HistoryTab extends StatelessWidget {
  //Создаем кастомный TextEditingController. Используем для управления стилями текста в TextField и не только
  TextEditingController commentTextController = TextFieldColorizer(
    {
      r'_(.*?)\_': TextStyle(
          fontStyle: FontStyle.italic, shadows: kElevationToShadow[2]),
      '~(.*?)~': TextStyle(
          decoration: TextDecoration.lineThrough,
          shadows: kElevationToShadow[2]),
      r'\*(.*?)\*': TextStyle(
          fontWeight: FontWeight.bold, shadows: kElevationToShadow[2]),
    },
  );

  // Это дефолтный скроллконтрроллер, используем на вкладке история, чтобы перематывать на последнее событие т.к. это удобно для пользователя
  ScrollController commentScrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return GetBuilder<CommentController>(
        init: CommentController(),
        builder: (commentController) {
          return Padding(
              padding: EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 8),
              child: Column(
                children: [
                  commentController.getComments().length > 0
                      ? Expanded(
                          child: ListView.builder(
                              itemCount:
                                  commentController.getComments().value.length,
                              controller: commentScrollController,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                    child: CommentCard(
                                        maxLines: 3,
                                        comment: commentController
                                            .getComments()
                                            .value[index]),
                                    onTap: () {
                                      commentController.selectedComment =
                                          commentController
                                              .getComments()
                                              .value[index];
                                      GetDelegate routerDelegate = Get.find();
                                      routerDelegate
                                          .toNamed(CommentPage.routeName);
                                    });
                              }),
                        )
                      : Expanded(
                          child: Padding(
                              padding: EdgeInsets.only(top: 8, bottom: 450),
                              child: Text("История пуста",
                                  textAlign: TextAlign.center))),
                  // Текстовое поле ввода комментария
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Focus(
                      onFocusChange: (value) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          commentController.onTextFieldFocused = value;
                        });
                      },
                      child: TextField(
                          textInputAction: TextInputAction.send,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            hintText: "Ваш комментарий",
                            hintStyle: TextStyle(fontSize: 14),
                            fillColor: themeData.bottomAppBarColor,
                            border: InputBorder.none,
                            filled: true,
                            suffixIcon: IconButton(
                              tooltip: 'С уведомлением',
                              icon: Icon(
                                  commentController.isAlarmComment
                                      ? Icons.notifications
                                      : Icons.notifications_off,
                                  // size: 30,
                                  color: Colors.black),
                              onPressed: () {
                                commentController.isAlarmComment =
                                    !commentController.isAlarmComment;
                              },
                            ),
                            isCollapsed: false,
                          ),
                          onSubmitted: (text) {
                            commentController.addComment(
                              commentTextController.text,
                              commentController.isAlarmComment,
                            );
                            commentTextController.clear();
                            commentScrollController.animateTo(
                              commentScrollController.position.maxScrollExtent,
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 300),
                            );
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          minLines: 1,
                          maxLines: 5,
                          controller: commentTextController),
                    ),
                  ),
                  Visibility(
                      visible: commentController.onTextFieldFocused,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8, right: 16),
                        child: Row(children: [
                          TextButton(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 4, right: 8, left: 8, bottom: 4),
                              child: const Text('Отправить',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14)),
                            ),
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32))),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.all(2)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.yellow.shade700)),
                            onPressed: () {
                              commentController.addComment(
                                commentTextController.text,
                                commentController.isAlarmComment,
                              );
                              commentTextController.clear();
                              commentScrollController.animateTo(
                                commentScrollController
                                    .position.maxScrollExtent,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          ),
                        ], mainAxisAlignment: MainAxisAlignment.end),
                      ))
                ],
              ));
        });
  }
}
