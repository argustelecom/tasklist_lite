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
            GetX<AuthController>(builder: (authController) {
              return authController.isAuthenticated
                  ? Expanded(
                      child: ListView(
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                          shrinkWrap: true,
                          children: MenuAction.mainActionList
                              .map((e) => InkWell(
                                  onTap: e.callback,
                                  child: Row(children: [
                                    IconButton(
                                      onPressed: e.callback,
                                      icon: Icon(e.iconData),
                                      iconSize:
                                          IconTheme.of(context).size ?? 24,
                                      tooltip: e.caption,
                                    ),
                                    Text(e.caption)
                                  ])))
                              .toList()),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 100,
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Text(
                                "Меню будет доступно после входа в систему."),
                          ),
                        ),
                      ));
            }),
          ],
        ),
      ),
    );
  }
}
