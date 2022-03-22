import 'package:flutter/material.dart';
import 'package:tasklist_lite/crazylib/widescreen_navigation_drawer.dart';
import 'package:tasklist_lite/layout/adaptive.dart';

import 'bottom_button_bar.dart';
import 'crazy_progress_dialog.dart';

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
    return CrazyProgressDialog(
        child: isDisplayDesktop(context)
            ? Material(
                color: Theme.of(context).bottomAppBarColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    WideScreenNavigationDrawer(),
                    // Тут поменял SizedBox на Expanded, чтобы не было щели
                    Expanded(
                        // #TODO: хардкодная ширина списка (отчасти оправданно, но выглядит мерзко)
                        // Material здесь нужен по двум причинам:
                        // -- он дает фон (такой же как Scaffold)
                        // -- некоторые компоненты, например, Slider или TextField, должны иметь Material в родителях
                        // (когда компонуем с использованием Scaffold, это дает Scaffold)
                        child: Material(
                            // такоей же, как дефолтный у Drawer`а
                            elevation: 16,
                            child: Column(
                              children: [
                                appBar ?? AppBar(),
                                // Expanded (наследник Flexible) здесь нужен, чтобы вложенные колонки и строки
                                // (а body чаще всего строится как Column) могли наследовать Constraints, пришедшие сверху,
                                // а также (благодаря свойствам Expanded) захватывать все пространство. Первое важнее,
                                // если не решим, будем получать RenderFlex children have non-zero flex but incoming height constraints are unbounded.
                                // см. ссылку  https://stackoverflow.com/questions/57803737/flutter-renderflex-children-have-non-zero-flex-but-incoming-height-constraints
                                // и прекрасную цитату оттуда:
                                /* Note that a Flex class or sub-class (like Column) should not be child of other Flex classes, and their parent class needs to be
                                of type Flexible (i.e. inherit it, like Expanded), else, Flex-class gets unbounded (and remaining space cannot be calculated)
                                which causes no direct issue till yet another child tries to calculate and/or fill space.
                             */
                                Expanded(child: body),
                              ],
                            )))
                  ],
                ))
            : Scaffold(
                appBar: appBar,
                body: body,
                bottomNavigationBar: bottomNavigationBar ?? BottomButtonBar()));
  }
}
