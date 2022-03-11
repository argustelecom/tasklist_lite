import 'package:flutter/material.dart';

/// слизано с SimpleDialog, который живет в dialog.dart. Только контент другой
/// #TODO: наверняка можно поизящней
/// #TODO: после перевода на навигацию 2.0 не проверялся(и не адаптировался), мб поэтому в чем-то не работает
class CrazyDialog extends StatelessWidget {
  const CrazyDialog({
    Key? key,
    this.title,
    this.child,
  }) : super(key: key);

  /// Typically a [Text] widget.
  final Widget? title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    Widget? titleWidget;
    if (title != null) {
      titleWidget = ListTile(
        title: Row(children: [
          Expanded(child: title == null ? Text("Заголовок") : title!),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                // этого достаточно для закрытия диалога, т.к. открывался он через #push
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.close,
                color: themeData.colorScheme.onSurface,
                size: 50,
              ),
            ),
          ),
        ]),
      );
    }
    return Dialog(
        backgroundColor: themeData.colorScheme.secondaryVariant,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side:
                BorderSide(color: themeData.colorScheme.onSecondary, width: 1)),
        child: ListView(children: [
          // заголовок
          if (title != null) titleWidget!, child!
        ]));
  }
}

Widget _buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  late final Animation<double> _animation = CurvedAnimation(
    parent: animation,
    curve: Curves.fastOutSlowIn,
  );
  return ScaleTransition(scale: _animation, child: child);
}

class CrazyDialogRoute<T> extends RawDialogRoute<T> {
  CrazyDialogRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    CapturedThemes? themes,
    Color barrierColor = Colors.black54,
    bool barrierDismissible = true,
    String? barrierLabel,
    bool useSafeArea = true,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (BuildContext buildContext, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            final Widget pageChild = Builder(builder: builder);
            Widget dialog = themes?.wrap(pageChild) ?? pageChild;

            return dialog;
          },
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel ??
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration: const Duration(seconds: 1),
          transitionBuilder: _buildMaterialDialogTransitions,
          settings: settings,
        );
}

Future<T?> showCrazyDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black54,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).context,
  );

  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push<T>(CrazyDialogRoute<T>(
    context: context,
    builder: builder,
    barrierColor: barrierColor!,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    settings: routeSettings,
    themes: themes,
  ));
}
