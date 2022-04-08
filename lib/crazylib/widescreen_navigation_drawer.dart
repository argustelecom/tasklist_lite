import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/state/auth_controller.dart';

import '../layout/adaptive.dart';
import 'bottom_button_bar.dart';

///*******************************************************
/// **           Боковая панель "drawer"                **
/// ******************************************************
///
/// -- используется почти на каждой странице,
/// -- если эта страница компонуется на широком экране,
///   а иначе должен быть заменен на BottomButtonBar
class WideScreenNavigationDrawer extends StatelessWidget {
  const WideScreenNavigationDrawer();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GetX<AuthController>(builder: (authController) {
          GetDelegate routerDelegate = Get.find();
          return authController.authState.isAuthenticated.value
              ? ListView(
                  padding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: isDisplayDesktop(context) ? 8 : 32),
                  shrinkWrap: true,
                  children: MenuAction.mainActionList
                      .map((e) => InkWell(
                          onTap: e.callback,
                          child: Row(children: [
                            IconButton(
                              onPressed: e.callback,
                              icon: e.icon != null
                                  ? e.icon!
                                  : Image.asset(
                                      e.assetPath!,
                                      color: (routerDelegate.history.last
                                                  .currentPage?.name ==
                                              e.routeName)
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                    ),
                              iconSize: IconTheme.of(context).size ?? 24,
                              color: (routerDelegate
                                          .history.last.currentPage?.name ==
                                      e.routeName)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onPrimary,
                              tooltip: e.caption,
                            ),
                            Text(
                              e.caption,
                              style: TextStyle(
                                color: (routerDelegate
                                            .history.last.currentPage?.name ==
                                        e.routeName)
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          ])))
                      .toList())
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 100,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        child:
                            Text("Меню будет доступно после входа в систему."),
                      ),
                    ),
                  ));
        })
      ],
    );
  }
}
