import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../layout/adaptive.dart';

class AdaptiveDialog extends StatelessWidget {
  IconData? titleIcon;
  Color? titleIconColor;
  String titleText;
  Widget body;
  Widget? buttonBar;
  Size? desktopViewSize;
  double? mobileViewTopOffset;

  AdaptiveDialog(
      {this.titleIcon,
      this.titleIconColor,
      required this.titleText,
      required this.body,
      this.buttonBar = const Center(),
      this.desktopViewSize,
      this.mobileViewTopOffset,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size defaultSize = Size(600.0, 500.0);
    ThemeData themeData = Theme.of(context);
    titleIconColor = (titleIconColor != null)
        ? titleIconColor
        : themeData.colorScheme.onSurface;
    desktopViewSize = (desktopViewSize != null) ? desktopViewSize : defaultSize;
    mobileViewTopOffset = (mobileViewTopOffset != null)
        ? mobileViewTopOffset
        : (MediaQuery.of(context).size.height - 60) /
            MediaQuery.of(context).size.height;

    Widget mobileDialog = DraggableScrollableSheet(
        initialChildSize: mobileViewTopOffset!,
        builder: (context, scrollController) {
          return Container(
              decoration: BoxDecoration(
                  color: themeData.cardColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6))),
              padding: EdgeInsets.only(bottom: 24),
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Column(children: [
                    // декоративный элемент шторки, разделитель
                    // упаковываем в контейнер заданного размера, чтобы получить нужную ширину разделителя и отступы
                    Container(
                        width: 60,
                        height: 30,
                        child: Divider(
                            color: themeData.colorScheme.onSurface,
                            thickness: 2)),
                    // заголовок
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(
                        titleIcon,
                        color: titleIconColor,
                        size: 30,
                      ),
                      SizedBox(width: 20),
                      Text(titleText,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 20 + 30),
                    ]),
                    SizedBox(height: 32),
                    // тело
                    Expanded(
                        child: ListView(children: [
                      Material(
                          color: Colors.transparent,
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: body))
                    ])),
                    // панель кнопок
                    Container(
                        padding: EdgeInsets.only(top: 18),
                        alignment: Alignment.bottomCenter,
                        child: buttonBar!)
                  ])));
        });

    Widget desktopDialog = Center(
        child: SizedBox.fromSize(
            size: desktopViewSize,
            child: Card(
                color: themeData.cardColor,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(children: [
                      // заголовок
                      Row(children: [
                        SizedBox(width: 32 + 20),
                        Spacer(),
                        Icon(
                          titleIcon,
                          color: titleIconColor,
                          size: 30,
                        ),
                        SizedBox(width: 20),
                        Text(titleText,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 50),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            GetDelegate routerDelegate = Get.find();
                            routerDelegate.popRoute();
                          },
                          child: Icon(
                            Icons.close,
                            color: themeData.colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 32)
                      ]),
                      SizedBox(height: 32),
                      // тело
                      Expanded(
                          child: ListView(children: [
                        Material(
                            color: Colors.transparent,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: body))
                      ])),
                      // панель кнопок
                      Container(
                          padding: EdgeInsets.only(top: 18),
                          alignment: Alignment.bottomCenter,
                          child: buttonBar)
                    ])))));

    return isDisplayDesktop(context) ? desktopDialog : mobileDialog;
  }
}

Future<T?>? showAdaptiveDialog<T>(
    {required BuildContext context, required WidgetBuilder builder}) {
  if (isDisplayDesktop(context)) {
    showDialog(context: context, builder: builder);
  } else {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: builder);
  }
}
