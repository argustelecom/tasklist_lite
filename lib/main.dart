import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/themes/tasklist_theme_data.dart';

void main() {
  runApp(MyApp());
}

// #TODO: добавить поддержку темы dark
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // без встраивания Builder не работает, получаем unexpected null value
    // (внутри ApplicationState.of scope is null). Builder дает какой-то другой контекст по итогу, надо разобраться
    // https://stackguides.com/questions/69408608/flutter-dependoninheritedwidgetofexacttype-returns-null
    return ModelBinding(child: Builder(builder: (context) {
      return MaterialApp(
        title: 'Flutter Demo',
        home: MyHomePage(title: 'Flutter Demo Home Page'),
        // #TODO: приделать ui управления темами
        // #TODO: в galllery эти параметры прокидываются через GalleryOptions
        // это все описано в https://medium.com/flutter/managing-flutter-application-state-with-inheritedwidgets-1140452befe1
        // надо научиться в рантайме менять тему. См. также https://stackoverflow.com/questions/49164592/flutter-how-to-change-the-materialapp-theme-at-runtime
        themeMode: ApplicationState.of(context).themeMode,
        theme: TaskListThemeData.lightThemeData.copyWith(
          // #TODO: в galllery эти параметры прокидываются через GalleryOptions
          platform: defaultTargetPlatform,
        ),
        darkTheme: TaskListThemeData.darkThemeData.copyWith(
          // #TODO: в galllery эти параметры прокидываются через GalleryOptions
          platform: defaultTargetPlatform,
        ),
      );
    }));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;

  bool _settingsExpanded = false;
  ThemeMode? selectedThemeMode;

  late final AnimationController _settingsAnimationController =
      AnimationController(
    vsync: this,
    duration: Duration(seconds: 1),
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _settingsAnimationController,
    curve: Curves.fastOutSlowIn,
  );

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    // #TODO: прокинуть еще secondary (это иконка для опции)
    Map<ThemeMode, String> optionsMap = LinkedHashMap.of({
      ThemeMode.light: "Светлая",
      ThemeMode.dark: "Темная",
      ThemeMode.system: "По умолчанию"
    });

    // #TODO: ничо что прямт так в build? иначе не ясно, как достать context
    // при этом setState не вызывается
    // поразбираться, как это сделано в gallery
    selectedThemeMode = ApplicationState.of(context).themeMode;

    // опция: value, title,
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          actions: <Widget>[
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: InkWell(
                onTap: () {
                  if (!_settingsExpanded) {
                    _settingsAnimationController.forward();
                  } else {
                    _settingsAnimationController.reverse();
                  }
                  setState(() {
                    _settingsExpanded = !_settingsExpanded;
                  });
                },
                child: Icon(
                  Icons.settings,
                  color: themeData.colorScheme.onSurface,
                  size: 50,
                ),
              ),
            ),
          ]),
      body: Center(
        child: Stack(alignment: Alignment.center, children: <Widget>[
          Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
          ScaleTransition(
              scale: _animation,
              child: Dialog(
                backgroundColor: themeData.colorScheme.secondaryVariant,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                        color: themeData.colorScheme.onSecondary, width: 1)),
                child: ListView(
                  children: [
                    // заголовок
                    ListTile(
                        title: Row(children: [
                      Expanded(child: Text("Настройки")),
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () {
                            assert(_settingsExpanded);
                            _settingsAnimationController.reverse();
                            setState(() {
                              _settingsExpanded = !_settingsExpanded;
                            });
                          },
                          child: Icon(
                            Icons.close,
                            color: themeData.colorScheme.onSurface,
                            size: 50,
                          ),
                        ),
                      ),
                    ])),
                    ExpansionTile(
                      title: Text("Визуальная тема"),
                      children: [
                        ListView.builder(
                            itemCount: optionsMap.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              // #TODO: рисует красным и при этом работает
                              return RadioListTile(
                                value: optionsMap.keys.elementAt(index),
                                title: Text(
                                  optionsMap.values.elementAt(index),
                                  style:
                                      themeData.textTheme.bodyText1!.copyWith(
                                    color: themeData.colorScheme.onPrimary,
                                  ),
                                ),
                                groupValue: selectedThemeMode,
                                onChanged: (ThemeMode? newValue) {
                                  setState(() {
                                    selectedThemeMode = newValue;
                                  });
                                  ApplicationState.update(
                                      context,
                                      ApplicationState.of(context)
                                          .copyWith(themeMode: newValue));
                                },
                                activeColor: themeData.colorScheme.primary,
                                dense: true,
                                toggleable: true,
                              );
                            }),
                      ],
                      backgroundColor: themeData.colorScheme.onBackground,
                      collapsedBackgroundColor:
                          themeData.colorScheme.onBackground,
                      // иначе сливается с цветом фона
                      textColor: themeData.colorScheme.onSurface,
                      iconColor: themeData.colorScheme.onSurface,
                    )
                  ],
                ),
              )),
        ]),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
