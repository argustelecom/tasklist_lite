import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/state/auth_controller.dart';

import 'bottom_button_bar.dart';

///*******************************************************
/// **           Боковая панель "drawer"                **
/// ******************************************************
///
/// -- используется почти на каждой странице,
/// -- если эта страница компонуется на широком экране,
///   а иначе должен быть заменен на BottomButtonBar
class WideScreenNavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Меню"),
        ),
        body: Column(
          children: [
            Expanded(child: GetX<AuthController>(builder: (authController) {
              return ListView(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                  shrinkWrap: true,
                  children: MenuAction.mainActionList
                      .map((e) => InkWell(
                          onTap: e.callback,
                          child: Row(children: [
                            IconButton(
                              onPressed: authController.isAuthenticated ||
                                      (e.caption == MenuAction.settingsCaption)
                                  ? e.callback
                                  : null,
                              icon: Icon(e.iconData),
                              iconSize: IconTheme.of(context).size ?? 24,
                              tooltip: e.caption,
                            ),
                            Text(e.caption)
                          ])))
                      .toList());
            })),
          ],
        ),
      ),
    );
  }
}
