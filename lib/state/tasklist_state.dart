import 'package:flutter/material.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';

/// #TODO: что делать с копипастом?
/// https://medium.com/flutter/managing-flutter-application-state-with-inheritedwidgets-1140452befe1
///
/// ************************************************************************************************
/// Состояние списка задач. Не является состоянием одного виджета, поэтому не stateful widget. Как
/// потому что одна страница списка задач состоит из кучки виджетов, так и потому что экземпляр этого
/// класса включает в себя состояние нескольких страниц -- помимо страницы списка задач, еще и
/// страницы формы задачи.
///
class TaskListState {
  const TaskListState(
      {required this.openedTasks,
      required this.closedTasks,
      this.currentDate,
      required this.currentTask,
      this.searchText,
      this.assignedSwitch = true});

  /// открытые задачи. Их перечень не зависит от выбранного числа и обновляется только по необходимости
  /// (когда на сервере будут изменения)
  final List<Task> openedTasks;

  /// закрытые за выбранный день задачи. Как только день перевыбран, должны быть переполучены в репозитории
  /// (в его функции также может входить кеширование)
  final List<Task> closedTasks;

  /// выбранный в календаре день
  /// если не выбран, считается "сегодня" (тут есть тех. сложности, т.к. для inherited widget нужно, чтобы
  /// конструктор initialState был константным, а DateTime.now() никак не константный)
  final DateTime? currentDate;

  /// выбранный таск.
  final Task currentTask;

  /// значение в поле ввода текста. в getTasks отдаются только таски, содержащие в названии этот текст
  final String? searchText;

  /// значение, соответствующее значению переключателя "назначенные/неназначенные"
  final bool assignedSwitch;

  /// #TODO: сюда просится автоматический тест
  /// задачи, которые должны отображаться в списке задач, с учетом фильтров
  /// #TODO: учесть фильтр по
  List<Task> getTasks() {
    List<Task> resultList = List.of({});
    resultList.addAll(openedTasks);
    resultList.addAll(closedTasks);
    String searchString = searchText ?? "";
    return List.of(
        resultList.where((element) => element.name.contains(searchString)));
  }

  @override
  bool operator ==(Object other) {
    return other is TaskListState &&
        this.openedTasks == other.openedTasks &&
        this.closedTasks == other.closedTasks &&
        this.currentDate == other.currentDate &&
        this.currentTask == other.currentTask &&
        this.searchText == other.searchText;
  }

  @override
  int get hashCode => hashValues(
      openedTasks, closedTasks, currentDate, currentTask, searchText);

  static TaskListState of(BuildContext context) {
    // тут реализацию пришлось подглядеть в GalleryOptions, т.к. каноничная дает ошибки компиляции
    // каноничная -- это https://gist.github.com/HansMuller/29b03fc5e2285957ad7b0d6a58faac35
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>();

    // #TODO: в GalleryOptions без восклицательного знака
    return scope!.modelBindingState.currentModel;
  }

  static void update(BuildContext context, TaskListState newModel) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>();
    scope!.modelBindingState.updateModel(newModel);
  }

  TaskListState copyWith(
      {List<Task>? openedTasks,
      List<Task>? closedTasks,
      DateTime? currentDate,
      Task? currentTask,
      String? searchText}) {
    return TaskListState(
        openedTasks: openedTasks ?? this.openedTasks,
        closedTasks: closedTasks ?? this.closedTasks,
        currentDate: currentDate ?? this.currentDate,
        currentTask: currentTask ?? this.currentTask,
        searchText: searchText ?? this.searchText);
  }
}

class _ModelBindingScope extends InheritedWidget {
  _ModelBindingScope({
    // #TODO: оригинальный пример делался еще без null safety. Праавильно ли просто добавить вопросик? надо получше разобраться с null safety
    Key? key,
    // #TODO: разобраться в разнице между @requred и required. Первое, похоже, теперь рудимент
    required this.modelBindingState,
    required Widget child,
  }) : super(key: key, child: child);

  final _ModelBindingState modelBindingState;

  @override
  bool updateShouldNotify(_ModelBindingScope oldWidget) => true;
}

// #TODO: вот роль ModelBinding во всем этом деле не ясна. Хочется уменьшить количество классов. Зачем этот публичный класс?
// upd: ващета он используется как корневой виджет дерева, чтобы потом через of всегда находился экземпляр. Но как он связан со Scope,
// по классу которого происходит поиск в of?
class ModelBinding extends StatefulWidget {
  ModelBinding({
    Key? key,
    this.initialModel,
    required this.child,
  }) : super(key: key);

  final TaskListState? initialModel;
  final Widget child;

  _ModelBindingState createState() => _ModelBindingState();
}

class _ModelBindingState extends State<ModelBinding> {
  TaskListState currentModel = TaskListState(
    openedTasks: List.of({}),
    closedTasks: List.of({}),
    currentTask: Task(name: 'АВР 20776 наладочные работы', id: 667),
    currentDate: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    currentModel = widget.initialModel ??
        TaskListState(
            openedTasks: new List.of({}),
            closedTasks: List.of({}),
            // #TODO: сделать общую const переменную
            currentTask: Task(name: 'АВР 20776 наладочные работы', id: 667));
  }

  void updateModel(TaskListState newModel) {
    if (newModel != currentModel) {
      setState(() {
        currentModel = newModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModelBindingScope(
      modelBindingState: this,
      child: widget.child,
    );
  }
}
