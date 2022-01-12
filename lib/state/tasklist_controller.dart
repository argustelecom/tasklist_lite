import 'dart:async';

import 'package:get/get.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:tasklist_lite/tasklist/task_repository.dart';

class TaskListController extends GetxController {
  /// открытые задачи. Их перечень не зависит от выбранного числа и обновляется только по необходимости
  /// (когда на сервере будут изменения)
  List<Task> openedTasks = List.of({});

  /// закрытые за выбранный день задачи. Как только день перевыбран, должны быть переполучены в репозитории
  /// (в его функции также может входить кеширование)
  List<Task> closedTasks = List.of({});

  /// выбранный в календаре день
  /// если не выбран, считается "сегодня" (тут есть тех. сложности, т.к. для inherited widget нужно, чтобы
  /// конструктор initialState был константным, а DateTime.now() никак не константный)
  DateTime _currentDate = DateTime.now();

  DateTime get currentDate => _currentDate;

  set currentDate(DateTime value) {
    _currentDate = value;
    update();
  }

  /// выбранный таск.
  Task? currentTask;

  /// значение в поле ввода текста. в getTasks отдаются только таски, содержащие в названии этот текст
  String _searchText = "";

  String get searchText => _searchText;

  // в данном случае сеттер не только меняет внутренее состояние контрооллера, но и отвечает также за сигнал
  // о необходимости обновления. #TODO: пока не ясно, насколько это нормально и правильно
  set searchText(String value) {
    _searchText = value;
    update();
  }

  /// значение, соответствующее значению переключателя "назначенные/неназначенные"
  bool assignedSwitch = false;

  /// #TODO: сюда просится автоматический тест
  /// задачи, которые должны отображаться в списке задач, с учетом фильтров
  /// #TODO: учесть фильтр по
  List<Task> getTasks() {
    List<Task> resultList = List.of({});
    resultList.addAll(openedTasks);
    resultList.addAll(closedTasks);
    return List.of(
        resultList.where((element) => element.name.contains(searchText)));
  }

  StreamSubscription? openedTasksSubscription;
  StreamSubscription? closedTasksSubscription;

  TaskRepository taskRepository = Get.find();

  StreamSubscription resubscribe(StreamSubscription? streamSubscription,
      Stream<List<Task>> stream, void onData(List<Task> event)) {
    streamSubscription?.cancel();
    return stream.listen(onData);
  }

  @override
  void onInit() {
    super.onInit();
    // берем stream`ы, на которых висят данные по открытым и закрытым задачам, и заводим их
    // на изменение соотв. полей контроллера списка.
    openedTasksSubscription = resubscribe(
        openedTasksSubscription, taskRepository.streamOpenedTasks(), (event) {
      this.openedTasks = event;
      update();
    });

    closedTasksSubscription = resubscribe(closedTasksSubscription,
        taskRepository.streamClosedTasks(this.currentDate), (event) {
      this.closedTasks = event;
      update();
    });
  }

  @override
  void onClose() {
    openedTasksSubscription?.cancel();
    closedTasksSubscription?.cancel();
    super.onClose();
  }

  ///***************************************************************************
  ///**  по замыслу, вызывается, когда изменились неявные зависимости контроллера
  /// Например, выбрана новая фикстура в настройках, что требует переподписки на
  /// stream`ы taskRepository
  ///***************************************************************************
  void didChangeDependencies() {
// фикстура затрагивает только открытые задачи, поэтому набор данных по закрытым не мог измениться
    openedTasksSubscription = resubscribe(
        openedTasksSubscription, taskRepository.streamOpenedTasks(), (event) {
      this.openedTasks = event;
      update();
    });
  }
}
