import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tasklist_lite/crazylib/widescreen_navigation_drawer.dart';
import 'package:tasklist_lite/layout/adaptive.dart';

import 'bottom_button_bar.dart';

///*******************************************************************************
///**           Отзывчивый (responsive, на размеры экрана) Scaffold             **
///*******************************************************************************
///
/// на малых экранах для компоновки содержимого использует обычный Scaffold
/// а вот на широких экранах компонует содержимое как два отдельных column`а,
/// в левом Drawer с навигацией а в правом -- по существу, содержимое Scaffold
///
/// ResponsiveScaffold уже есть(https://pub.dev/packages/responsive_scaffold), но
/// достичь им нужного reflow-эффекта не получилось.
class ReflowingScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;

  final Widget? bottomNavigationBar = null;

  ReflowingScaffold({
    this.appBar,
    required this.body,
    //  bottomBar наш Scaffold больше не получает, т.к. имеет Drawer-аналог только для BottomButtonBar
    // #TODO: а хорошо бы на вход получать список действий, а-ля BottomButtonBar.mainActionList
    // и уже по нему генерить и подвал, и Drawer
    //this.bottomNavigationBar
  });

  @override
  Widget build(BuildContext context) {
    return isDisplayDesktop(context)
        ? Material(
            color: Theme.of(context).bottomAppBarColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                WideScreenNavigationDrawer(),
                SizedBox(
                    // #TODO: хардкодная ширина списка (отчасти оправданно, но выглядит мерзко)
                    width: 600,
                    // Material здесь нужен по двум причинам:
                    // -- он дает фон (такой же как Scaffold)
                    // -- некоторые компоненты, например, Slider или TextField, должны иметь Material в родителях
                    // (когда компонуем с использованием Scaffold, это дает Scaffold)
                    child: Material(
                        // такоей же, как дефолтный у Drawer`а
                        elevation: 16,
                        child: Column(
                          children: [appBar ?? AppBar(), body],
                        )))
              ],
            ))
        : Scaffold(
            appBar: appBar,
            body: body,
            bottomNavigationBar: bottomNavigationBar ?? BottomButtonBar());
  }
}
