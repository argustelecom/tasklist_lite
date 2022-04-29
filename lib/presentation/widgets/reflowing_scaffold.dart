import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tasklist_lite/presentation/adaptive.dart';
import 'package:tasklist_lite/presentation/widgets/widescreen_navigation_drawer.dart';

import 'bars/bottom_button_bar.dart';
import 'crazy_progress_dialog.dart';

// "appBar" для широких экранов.  Вызывается из ReflowingScaffold в случае isDisplayDesktop,
// напрямую использовать не нужно. Задает цвет фона как primary с opacity ("разбавленный" основной цвет).
class WideScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> children;
  final double height;
  WideScreenAppBar({required this.children, this.height = 150});
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
            appBarTheme: Theme.of(context).appBarTheme.copyWith(
                // #TODO: тут что-то странное с opacity. Либо здесь, либо ниже (где задается цвет Material-подстилки) в случае
                // указания цвета с opacity, этот самый opacity кем-то (каким-то кодом) подкручивается, в итоге, чтобы оба цвета
                // соответствовали, приходится задавать разный opacity: 0.01 здесь и 0.1 ниже. Если задавать цвет без opacity,
                // этой проблемы нет. Пока оставим так, будет с чем поразбираться в будущем.
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.01), elevation: 0)),
        child: Scaffold(
          body: Material(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

///*******************************************************************************
///**           Отзывчивый (responsive, на размеры экрана) Scaffold             **
///*******************************************************************************
///
/// на малых экранах для компоновки содержимого использует обычный Scaffold.
/// а вот на широких экранах компонует содержимое и заголовка (appbar) и тушки (body),
/// как три колонки с полями по краям. Ширина колонок может быть задана вызывающим,
/// но лучше использовать уже откалиброванную ширину, проставленную как дефолтные
/// значения leftWidth, bodyWidht, rightWidth. Ширина колонок для appBar и body
/// одинаковая, поэтому выглядит все так, как будто это просто трехколоночная компоновка.
/// На практике, надо задавать содержимое для appBarLeft, appBar, appBarRight,
/// bodyLeft, body, bodyRight. Что-то из этого может быть не задано для получения
/// соответствующего вида. Например, слева хорошо показывать только меню (оно уже
/// будет показано по дефолту).
///
/// ResponsiveScaffold уже есть(https://pub.dev/packages/responsive_scaffold), но
/// достичь им нужного reflow-эффекта не получилось.
class ReflowingScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? appBarLeft;
  final Widget? appBarRight;
  final Widget body;
  final Widget? bodyLeft;
  final Widget? bodyRight;
  final double leftWidth;
  final double bodyWidth;
  final double rightWidth;

  final Widget? bottomNavigationBar = null;

  ReflowingScaffold({
    this.appBar,
    this.appBarLeft,
    this.appBarRight,
    required this.body,
    this.bodyLeft,
    this.bodyRight,

    /// размеры подобраны так, чтобы при переходе через isDisplayDesktop() содержимое отображалось без артефактов,
    /// связанных с невлезанием на экран. Меняй их осторожно и только если это действительно нужно.
    this.leftWidth = 230,
    this.bodyWidth = 585,
    this.rightWidth = 200,
    //  bottomBar наш Scaffold больше не получает, т.к. имеет Drawer-аналог только для BottomButtonBar
    // #TODO: а хорошо бы на вход получать список действий, а-ля BottomButtonBar.mainActionList
    // и уже по нему генерить и подвал, и Drawer
    //this.bottomNavigationBar
  });

  @override
  Widget build(BuildContext context) {
    return CrazyProgressDialog(
        child: isDisplayDesktop(context)
            ? Scaffold(
                appBar: isDisplayDesktop(context)
                    ? WideScreenAppBar(
                        children: [
                          Expanded(child: Column()),
                          Container(
                              constraints: BoxConstraints(
                                  maxWidth: leftWidth, minWidth: leftWidth),
                              child: appBarLeft),
                          Container(
                            constraints: BoxConstraints(
                                maxWidth: bodyWidth, minWidth: bodyWidth - 150),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [appBar ?? AppBar()],
                            ),
                          ),
                          Container(
                              constraints: BoxConstraints(
                                  minWidth: rightWidth, maxWidth: rightWidth),
                              child: appBarRight),
                          Expanded(child: Column()),
                        ],
                      )
                    : appBar,
                body: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Column()),
                    // Expanded(child: Column()),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: leftWidth, minWidth: leftWidth),
                      child: bodyLeft ?? WideScreenNavigationDrawer(),
                    ),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: bodyWidth, minWidth: bodyWidth - 150),
                      child: body,
                    ),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: rightWidth, minWidth: rightWidth),
                      child: bodyRight,
                    ),
                    //  Expanded(child: Column()),
                    Expanded(child: Column()),
                  ],
                ),
              )
            : Scaffold(
                appBar: appBar,
                body: body,
                bottomNavigationBar: bottomNavigationBar ?? BottomButtonBar()));
  }
}
