import 'dart:collection';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/crazylib/expansion_radio_tile.dart';
import 'package:tasklist_lite/crazylib/inspector_panel.dart';
import 'package:tasklist_lite/layout/tasklist_multi_child_layout_delgate.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/tasklist/fixture/task_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:tasklist_lite/tasklist/task_repository.dart';
import 'package:tasklist_lite/theme/tasklist_theme_data.dart';

import 'crazylib/crazy_dialog.dart';
import 'crazylib/task_card.dart';
import 'layout/adaptive.dart';

void main() {
  runApp(MyApp());
}

// #TODO: сделать автотесты
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // без встраивания Builder не работает, получаем unexpected null value
    // (внутри ApplicationState.of scope is null). Builder дает какой-то другой контекст по итогу, надо разобраться
    // https://stackguides.com/questions/69408608/flutter-dependoninheritedwidgetofexacttype-returns-null
    return ModelBinding(child: Builder(builder: (context) {
      return GetMaterialApp(
        title: 'Список задач исполнителя',
        home: MyHomePage(title: 'Список задач'),
        themeMode: ApplicationState.of(context).themeMode,
        theme: TaskListThemeData.lightThemeData.copyWith(
          platform: defaultTargetPlatform,
        ),
        // чтобы таким образом добавить зависимости в контекст, пришлось делать не MaterialApp, а именно GetMaterialApp
        //https://medium.com/flutter-community/the-flutter-getx-ecosystem-dependency-injection-8e763d0ec6b9
        // #TODO: чтобы делать lazuPut, надо делать и отдельный класс-потомок Bindings (т.к. #lazyPut void, а BindingBuilder`у нужны экземпляры зависимостей)
        // а еще в dart низя делать анонимный класс (но можно анонимную функцию), что огорчает
        initialBinding: BindingsBuilder(
            () => {Get.put(TaskRepository()), Get.put(TaskFixtures())}),
        darkTheme: TaskListThemeData.darkThemeData.copyWith(
          platform: defaultTargetPlatform,
        ),
      );
    }));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    ApplicationState applicationState = ApplicationState.of(context);
    // подход с inherited widget реализован так, что инстанс ApplicationState пересоздается
    // каждый раз при вызове update (см. код ModelBinding, _ModelBindingState), а Get#put
    // не кладет в контекст, если объект такого типа уже есть в контексте. Поэтому превентивно
    // почистим объект из контекста, чтобы перед обращением к TaskRepository там лежал актуальный
    // экземпляр ApplicationState.
    // #TODO: Такой себе мостик между inherited widget и Get
    Get.delete<ApplicationState>();
    Get.put(applicationState);
    TaskRepository taskRepository = Get.find();
    List<Task> taskList = taskRepository.getTasks();
    // очень непривычно, тут низя в операции map обернуть тело анонимной функции в фигурные скобки {}
    // в java это была бы просто группировка операций в единый блок, а здесь этим объявляется Set :/
    List<Text> taskDescs = taskList.map((task) => Text(task.name)).toList();
    return Scaffold(
        appBar: AppBar(
            title: Text(
              widget.title,
            ),
            actions: <Widget>[
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: InkWell(
                  onTap: () {
                    showCrazyDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CrazyDialog(
                            title: Text("Настройки"),
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                ExpansionRadioTile<ThemeMode>(
                                    title: Text("Визуальная тема"),
                                    selectedObject:
                                        ApplicationState.of(context).themeMode,
                                    optionsMap: LinkedHashMap.of({
                                      ThemeMode.light: "Светлая",
                                      ThemeMode.dark: "Темная",
                                      ThemeMode.system: "По умолчанию"
                                    }),
                                    onChanged: (ThemeMode? newValue) {
                                      ApplicationState.update(
                                          context,
                                          ApplicationState.of(context)
                                              .copyWith(themeMode: newValue));
                                    }),
                                ExpansionRadioTile<CurrentTaskFixture>(
                                    title: Text("Источник данных"),
                                    selectedObject: ApplicationState.of(context)
                                        .currentTaskFixture,
                                    optionsMap: LinkedHashMap.of({
                                      CurrentTaskFixture.firstFixture:
                                          "Первая фикстура",
                                      CurrentTaskFixture.secondFixture:
                                          "Вторая фикстура",
                                      CurrentTaskFixture.thirdFixture:
                                          "Третья фикстура",
                                      CurrentTaskFixture.noneFixture:
                                          "Фикстура не выбрана (удаленный источник данных)"
                                    }),
                                    onChanged: (CurrentTaskFixture? newValue) {
                                      ApplicationState.update(
                                          context,
                                          ApplicationState.of(context).copyWith(
                                              currentTaskFixture: newValue));
                                    }),
                              ],
                            ),
                          );
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
          child: Padding(
            // #TODO: размер отступа должен зависеть от размера экрана
            padding: EdgeInsets.all(8),
            child: Container(
              // должен реаизовать паттерн reflow https://material.io/archive/guidelines/layout/responsive-ui.html#responsive-ui-patterns
              child: CustomMultiChildLayout(
                delegate: TasklistMultiChildLayoutDelegate(context),
                children: <Widget>[
                  LayoutId(
                    id: carouselLayoutId,
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: themeData.colorScheme.secondaryVariant),
                      child: Center(
                        child: CarouselSlider.builder(
                          options: CarouselOptions(
                              height: carouselHeight,
                              // обеспечивает появление на экране сразу 1/viewportFraction item`ов
                              viewportFraction:
                                  isDisplayDesktop(context) ? 0.4 : 0.8),
                          itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex) {
                            return Container(
                              height: carouselHeight,
                              width: 400,
                              child: TaskCard(task: taskList[itemIndex]),
                            );
                          },
                          itemCount: taskList.length,
                        ),
                      ),
                    ),
                  ),
                  LayoutId(
                      id: taskDetailsLayoutId,
                      child: InspectorPanel(
                        title: "Детальная информация о задаче",
                        child: Text("Детальная информация о задаче"),
                        // первый expand initially распахнут всегда. Остальные initially распахнуты,
                        // только если большой экран (isDisplayDesktop), а иначе свернуты
                        initiallyExpanded: true,
                      )),
                  LayoutId(
                      id: taskFiltersLayoutId,
                      child: InspectorPanel(
                        title: "Панель фильтров списка задач",
                        child: Text("Панель фильтров списка задач"),
                        initiallyExpanded: isDisplayDesktop(context),
                      )),
                  LayoutId(
                      id: taskExtrasLayoutId,
                      child: InspectorPanel(
                        title: "Дополнительная панель списка задач",
                        child: Text("Дополнительная панель списка задач"),
                        initiallyExpanded: isDisplayDesktop(context),
                      )),
                ],
              ),
            ),
          ),
        )

        /*Center(
        child: Stack(alignment: Alignment.center, children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Список Ваших задач:',
              ),
              ...taskDescs,
            ],
          ),
        ]),
      ),*/
        //#TODO: drop this
        /*floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), */ // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
