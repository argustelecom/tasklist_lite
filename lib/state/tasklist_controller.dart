import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasklist_lite/tasklist/idle_time_reason_repository.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';
import 'package:tasklist_lite/tasklist/task_repository.dart';

/// содержит state списка задач и (возможно в будущем) формы задачи
class TaskListController extends GetxController {
  /// открытые задачи. Их перечень не зависит от выбранного числа и обновляется только по необходимости
  /// (когда на сервере будут изменения)
  List<Task> openedTasks = List.of({});

  /// закрытые за выбранный день задачи. Как только день перевыбран, должны быть переполучены в репозитории
  /// (в его функции также может входить кеширование)
  List<Task> closedTasks = List.of({});

  /// справочные значения причин простоя. Запрашиваем из репозитория при инициализации контролллера
  /// (далее берем из кэша)
  /// TODO возможно, стоит перенести
  List<String> idleTimeReasons = List.of({});

  /// выбранный в календаре день
  /// если не выбран, считается "сегодня" (тут есть тех. сложности, т.к. для inherited widget нужно, чтобы
  /// конструктор initialState был константным, а DateTime.now() никак не константный)
  DateTime _currentDate = DateUtils.dateOnly(DateTime.now());

  DateTime get currentDate => _currentDate;

  set currentDate(DateTime value) {
    _currentDate = value;
    closedTasksSubscription = resubscribe(closedTasksSubscription,
        taskRepository.streamClosedTasks(this.currentDate), (event) {
      this.closedTasks = event;
      update();
    });
    update();
  }

  /// выбранный таск.
  Task? currentTask;

  /// значение в поле ввода текста. в getTasks отдаются только таски, содержащие в названии этот текст
  String _searchText = "";

  /// значение, соответствующее значению переключателя "назначенные/неназначенные"
  bool _assignedSwitch = true;

  bool get assignedSwitch => _assignedSwitch;

  set assignedSwitch(bool value) {
    _assignedSwitch = value;
    // #TODO: хорошо бы update выполнять с указанием id подлежащих обновлению кусков
    // этим снизим потребление ресурсов на обновления.
    update();
  }

  String get searchText => _searchText;

  // в данном случае сеттер не только меняет внутренее состояние контрооллера, но и отвечает также за сигнал
  // о необходимости обновления. #TODO: пока не ясно, насколько это нормально и правильно
  set searchText(String value) {
    _searchText = value;
    update();
  }

  /// #TODO: сюда просится автоматический тест
  /// задачи, которые должны отображаться в списке задач, с учетом фильтров
  List<Task> getTasks() {
    /// хотим отображать сначала открытые, упорядоченные по КС (без КС в конце)...
    List<Task> resultList = List.of({});
    openedTasks.sort((a, b) => a.dueDate == null
        ? 1
        : b.dueDate == null
            ? -1
            : a.dueDate!.compareTo(b.dueDate!));
    resultList.addAll(openedTasks);

    /// ...затем закрытые, упорядоченные по дате закрытия
    closedTasks.sort((a, b) => a.closeDate!.compareTo(b.closeDate!));
    resultList.addAll(closedTasks);
    return List.of(resultList
        // фильтруем по наличию введенного (в поле поиска) текста в названии задачи
        .where((element) => element.name.contains(searchText))
        // фильтруем по признаку "назначенная/неназначенная"
        .where((element) => ((assignedSwitch && element.assignee != null) ||
            (!assignedSwitch && element.assignee == null)))
        // фильтруем по попаданию даты закрытия в текущий день
        .where((element) => ((!element.isClosed ||
            DateUtils.dateOnly(element.closeDate!).millisecondsSinceEpoch ==
                currentDate.millisecondsSinceEpoch))));
  }

  StreamSubscription? openedTasksSubscription;
  StreamSubscription? closedTasksSubscription;

  TaskRepository taskRepository = Get.find();
  IdleTimeReasonRepository idleTimeReasonRepository = Get.find();

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

    idleTimeReasons = idleTimeReasonRepository.getIdleTimeReasons();
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
}
