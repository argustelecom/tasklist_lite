import 'package:duration/duration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/idle_time_reason_repository.dart';
import 'package:tasklist_lite/tasklist/model/idleTime.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';

class IdleTimeManagerDialog extends StatefulWidget {
  IdleTimeManagerDialog({
    Key? key,
    required this.task,
    this.idleTime,
  }) : super(key: key);

  final Task task;
  IdleTime? idleTime;

  @override
  _IdleTimeManagerDialogState createState() => _IdleTimeManagerDialogState();
}

class _IdleTimeManagerDialogState extends State<IdleTimeManagerDialog> {
  @override
  Widget build(BuildContext context) {
    IdleTime? _idleTime = widget.idleTime;

    String? _reason;
    DateTime? _startDate;
    DateTime? _endDate;

    if (_idleTime != null) {
      _reason = _idleTime.reason;
      _startDate = _idleTime.startDate;
      if (_idleTime.endDate != null) _endDate = _idleTime.endDate;
    }

    ThemeData themeData = Theme.of(context);
    ApplicationState applicationState = ApplicationState.of(context);
    Get.put(IdleTimeReasonRepository());
    IdleTimeReasonRepository idleTimeReasonRepository = Get.find();
    List<String> idleTimeReasons =
        idleTimeReasonRepository.getIdleTimeReasons();

    Widget? dialog;
    if (_idleTime == null) {
      dialog = Column(children: [
        /// TODO вынести компоненты в библиотеку компонентов
        // разделитель
        Container(
            width: 60,
            height: 30,
            child: Divider(color: Colors.black, height: 10, thickness: 2)),
        // заголовок
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.timer_sharp,
            color: Colors.black,
            size: 30,
          ),
          Text("   Регистрация простоя",
              style: TextStyle(fontWeight: FontWeight.bold))
        ]),
        // тело диалога
        Padding(
            padding: EdgeInsets.fromLTRB(20, 40, 20, 15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Причина простоя*",
                      style: TextStyle(color: Colors.black54))),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                      //width: 300,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: DropdownButton<String>(
                        value: _reason,
                        hint: Text("   Выберите причину"),
                        itemHeight: 40,
                        underline: SizedBox(),
                        // нужен, чтобы избежать возможного overflow
                        isExpanded: true,
                        items: idleTimeReasons.map((String reason) {
                          return new DropdownMenuItem<String>(
                              value: reason, child: new Text(reason));
                        }).toList(),
                        onChanged: (String? newReason) {
                          setState(() {
                            if (newReason != null) _reason = newReason;
                          });
                        },
                      ))),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Начало простоя*",
                      style: TextStyle(color: Colors.black54))),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(children: [
                    Container(
                        width: 120,
                        margin: EdgeInsets.only(right: 30),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Row(children: [
                          IconButton(
                            icon: new Icon(Icons.access_time),
                            onPressed: () async {
                              final TimeOfDay? time1 = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                      hour: DateTime.now().hour,
                                      minute: DateTime.now().minute),
                                  helpText: "Укажите время",
                                  cancelText: "Отмена",
                                  confirmText: "Ок",
                                  builder: (context, child) {
                                    // вот только таким хитрым способом можно повлиять на цвета показываемого date picker`а
                                    return Theme(
                                        data: Theme.of(context).copyWith(
                                          /*   это если вдруг захочется цвет фона поменять dialogBackgroundColor:
                                            themeData.bottomAppBarColor,*/
                                          colorScheme: ColorScheme.light(
                                              primary: Colors.green),
                                          buttonTheme: ButtonThemeData(
                                              textTheme:
                                                  ButtonTextTheme.primary),
                                        ),
                                        child: child ?? new Text(""));
                                  });
                              if (time1 != null) {
                                this.setState(() {
                                  if (_startDate == null) {
                                    _startDate = DateTime.now();
                                  }
                                  _startDate = DateUtils.dateOnly(_startDate!)
                                      .add(hours(time1.hour))
                                      .add(minutes(time1.minute));
                                });
                              }
                            },
                          ),
                          Text(
                              (_startDate != null)
                                  ? DateFormat('HH:mm').format(_startDate!)
                                  : DateFormat('HH:mm').format(DateTime.now()),
                              style: TextStyle(fontSize: 14))
                        ])),
                    Container(
                        width: 150,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.all(Radius.circular(4))),
                        child: Row(children: [
                          IconButton(
                            icon: new Icon(
                              Icons.today,
                            ),
                            onPressed: () async {
                              final DateTime? date1 = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2021),
                                  lastDate: DateTime(2024),
                                  helpText: "Укажите день",
                                  cancelText: "Отмена",
                                  confirmText: "Ок",
                                  locale: const Locale("ru", "RU"),
                                  builder: (context, child) {
                                    // вот только таким хитрым способом можно повлиять на цвета показываемого date picker`а
                                    return Theme(
                                        data: Theme.of(context).copyWith(
                                          /*   это если вдруг захочется цвет фона поменять dialogBackgroundColor:
                                            themeData.bottomAppBarColor,*/
                                          colorScheme: ColorScheme.light(
                                              primary: Colors.green),
                                          buttonTheme: ButtonThemeData(
                                              textTheme:
                                                  ButtonTextTheme.primary),
                                        ),
                                        child: child ?? new Text(""));
                                  });
                              if (date1 != null) {
                                if (_startDate == null)
                                  _startDate = DateTime.now();
                                _startDate = date1
                                    .add(hours(_startDate!.hour))
                                    .add(minutes(_startDate!.minute));
                              }
                            },
                          ),
                          Text(
                              (_startDate != null)
                                  ? DateFormat('dd.MM.yyyy').format(_startDate!)
                                  : DateFormat('dd.MM.yyyy')
                                      .format(DateTime.now()),
                              style: TextStyle(fontSize: 14))
                        ]))
                  ])),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Окончание простоя",
                      style: TextStyle(color: Colors.black54))),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(children: [
                    Container(
                        width: 120,
                        margin: EdgeInsets.only(right: 30),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Row(children: [
                          IconButton(
                            icon: new Icon(
                              Icons.access_time,
                            ),
                            onPressed: () async {
                              final TimeOfDay? time2 = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                      hour: DateTime.now().hour,
                                      minute: DateTime.now().minute),
                                  helpText: "Укажите время",
                                  cancelText: "Отмена",
                                  confirmText: "Ок",
                                  builder: (context, child) {
                                    // вот только таким хитрым способом можно повлиять на цвета показываемого date picker`а
                                    return Theme(
                                        data: Theme.of(context).copyWith(
                                          /*   это если вдруг захочется цвет фона поменять dialogBackgroundColor:
                                            themeData.bottomAppBarColor,*/
                                          colorScheme: ColorScheme.light(
                                              primary: Colors.green),
                                          buttonTheme: ButtonThemeData(
                                              textTheme:
                                                  ButtonTextTheme.primary),
                                        ),
                                        child: child ?? new Text(""));
                                  });
                              if (time2 != null) {
                                if (_endDate == null) _endDate = DateTime.now();
                                _endDate = DateUtils.dateOnly(_endDate!)
                                    .add(hours(time2.hour))
                                    .add(minutes(time2.minute));
                              }
                            },
                          ),
                          Text(
                              (_startDate != null)
                                  ? DateFormat('HH:mm').format(_endDate!)
                                  : "",
                              style: TextStyle(fontSize: 14))
                        ])),
                    Container(
                        width: 150,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Row(children: [
                          IconButton(
                            icon: new Icon(
                              Icons.today,
                            ),
                            onPressed: () async {
                              final DateTime? date2 = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2021),
                                  lastDate: DateTime(2024),
                                  helpText: "Укажите день",
                                  cancelText: "Отмена",
                                  confirmText: "Ок",
                                  locale: const Locale("ru", "RU"),
                                  builder: (context, child) {
                                    // вот только таким хитрым способом можно повлиять на цвета показываемого date picker`а
                                    return Theme(
                                        data: Theme.of(context).copyWith(
                                          /*   это если вдруг захочется цвет фона поменять dialogBackgroundColor:
                                            themeData.bottomAppBarColor,*/
                                          colorScheme: ColorScheme.light(
                                              primary: Colors.green),
                                          buttonTheme: ButtonThemeData(
                                              textTheme:
                                                  ButtonTextTheme.primary),
                                        ),
                                        child: child ?? new Text(""));
                                  });
                              if (date2 != null) {
                                if (_endDate == null) _endDate = DateTime.now();
                                _endDate = date2
                                    .add(hours(_endDate!.hour))
                                    .add(minutes(_endDate!.minute));
                              }
                            },
                          ),
                          Text(
                              (_endDate != null)
                                  ? DateFormat('dd.MM.yyyy').format(_endDate!)
                                  : "",
                              style: TextStyle(fontSize: 14))
                        ]))
                  ])),
              Container(
                  padding: EdgeInsets.fromLTRB(10, 80, 0, 20),
                  alignment: Alignment.bottomCenter,
                  constraints: BoxConstraints(maxHeight: double.infinity),
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.yellow.shade700),
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(horizontal: 80, vertical: 16)),
                        elevation: MaterialStateProperty.all(3.0),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)))),
                    child: Text(
                      "Зарегистрировать",
                      style: TextStyle(
                          inherit: false,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 16),
                    ),
                    // TODO: обращение к контроллеру/репозиторию для валидации и формирования запроса
                    //  пока просто закрываем
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ))
            ]))
      ]);
    }
    return Dialog(
        backgroundColor: themeData.colorScheme.secondaryVariant,
        insetPadding: EdgeInsets.fromLTRB(0, 85, 0, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
        child: dialog!);
  }
}

Widget _buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  late final Animation<double> _animation = CurvedAnimation(
    parent: animation,
    curve: Curves.fastLinearToSlowEaseIn,
  );
  return ScaleTransition(
      scale: _animation, child: child, alignment: Alignment.bottomCenter);
}

class IdleTimeManagerDialogRoute<T> extends RawDialogRoute<T> {
  IdleTimeManagerDialogRoute({
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
          transitionDuration: const Duration(milliseconds: 500),
          transitionBuilder: _buildMaterialDialogTransitions,
          settings: settings,
        );
}

Future<T?> showIdleTimeManagerDialog<T>({
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
      .push<T>(IdleTimeManagerDialogRoute<T>(
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
