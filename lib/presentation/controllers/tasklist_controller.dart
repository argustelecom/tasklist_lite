import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide Worker;
import 'package:tasklist_lite/data/fixture/task_fixtures.dart';
import 'package:tasklist_lite/data/repositories/idle_time_reason_repository.dart';
import 'package:tasklist_lite/data/repositories/task_repository.dart';
import 'package:tasklist_lite/domain/entities/close_code.dart';
import 'package:tasklist_lite/domain/entities/task.dart';
import 'package:tasklist_lite/presentation/state/application_state.dart';
import 'package:tasklist_lite/presentation/widgets/crazy_progress_dialog.dart';

import '../../core/resubscribe.dart';
import '../../data/repositories/close_code_repository.dart';
import '../../data/repositories/comments_repository.dart';
import '../../data/repositories/work_repository.dart';
import '../../domain/entities/idle_time.dart';
import '../../domain/entities/work.dart';
import '../../domain/entities/worker.dart';
import '../state/auth_state.dart';
import '../state/tasklist_state.dart';

/// содержит state списка задач и (возможно в будущем) формы задачи
class TaskListController extends GetxController {
  AuthState authState = Get.find();
  ApplicationState _applicationState = Get.find();

  TaskListState taskListState = Get.put(TaskListState());

  /// значение в поле ввода текста. в getTasks отдаются только таски, содержащие в названии этот текст
  String _searchText = "";

  String get searchText => _searchText;

  // в данном случае сеттер не только меняет внутренее состояние контрооллера, но и отвечает также за сигнал
  // о необходимости обновления. #TODO: пока не ясно, насколько это нормально и правильно
  set searchText(String value) {
    _searchText = value.toLowerCase();
    update();
  }

  /// признак раскрытости inline-календаря в списке задач.
  /// Это state презентации, он не нуждается в персисте в локальную хранилку, поэтому
  /// живет в контроллере, а не в соответствующем state-классе.
  bool _calendarOpened = false;
  bool _datePickerBarExpanded = false;
  bool _searchBarExpanded = false;

  bool get calendarOpened => _calendarOpened;

  set calendarOpened(bool value) {
    _calendarOpened = value;
    update();
  }

  bool get datePickerBarExpanded => _datePickerBarExpanded;

  set datePickerBarExpanded(bool value) {
    _datePickerBarExpanded = value;
    update();
  }

  bool get searchBarExpanded => _searchBarExpanded;

  set searchBarExpanded(bool value) {
    _searchBarExpanded = value;
    update();
  }

  /// #TODO: сюда просится автоматический тест
  /// задачи, которые должны отображаться в списке задач, с учетом фильтров
  List<Task> getTasks() {
    /// хотим отображать сначала открытые, упорядоченные по КС (без КС в конце)...
    /// добавляем сортировку по id для нарядов без КС
    List<Task> resultList = List.of({});
    taskListState.openedTasks.sort((a, b) => a.dueDate == null
        ? b.dueDate == null
            ? a.id.compareTo(b.id)
            : 1
        : b.dueDate == null
            ? -1
            : a.dueDate!.compareTo(b.dueDate!));
    resultList.addAll(taskListState.openedTasks);

    /// ...затем закрытые, упорядоченные по дате закрытия
    // #TODO: возможно, дата закрытия с сервера по задачам не получается.
    // иначе сложно объснитьь, почему в закрытых тасках эта дата null
    // в любом случае, надо проверять, что там на сервере. Затычки ниже
    // нерабочие, просто чтобы не падало.
    taskListState.closedTasks.sort((a, b) => a.closeDate == null
        ? b.closeDate == null
            ? a.id.compareTo(b.id)
            : 1
        : b.closeDate == null
            ? -1
            : a.closeDate!.compareTo(b.closeDate!));
    resultList.addAll(taskListState.closedTasks);
    return List.of(resultList
        // фильтруем по наличию введенного (в поле поиска) текста в названии и других полях задачи
        .where((element) => (element.name.toLowerCase().contains(searchText) ||
            element.flexibleAttribs[TaskFixtures.foreignOrderIdFlexAttrName]
                .toString()
                .toLowerCase()
                .contains(searchText) ||
            element.flexibleAttribs[TaskFixtures.objectNameFlexAttrName]
                .toString()
                .toLowerCase()
                .contains(searchText) ||
            element.flexibleAttribs[TaskFixtures.orderOperatorNameFlexAttrName]
                .toString()
                .toLowerCase()
                .contains(searchText) ||
            element
                .getAddressDescription()
                .toLowerCase()
                .contains(searchText))));
  }

  StreamSubscription? _openedTasksSubscription;
  StreamSubscription? _closedTasksSubscription;
  StreamSubscription? _currentDateSubscription;
  StreamSubscription? _idleTimeReasonsSubscription;
  StreamSubscription? _closeCodesSubscription;

  TaskRepository taskRepository = Get.find();
  IdleTimeReasonRepository idleTimeReasonRepository = Get.find();
  CloseCodeRepository closeCodeRepository = Get.find();
  CommentRepository historyEventRepository = Get.find();

  @override
  void onInit() {
    super.onInit();

    /// kostd, 19.04.2022: ждем, когда state, влияющий на CurrentAuthInfo, CurrentAppInfo, будет проинициализирован.
    /// После этого подписываемся на все наши подписки, считая, что настройки подключения уже известны слою данных.
    /// Недостаток этого решения -- в случае, если настройки подключения изменятся в ходе жизни нашегго контроллера,
    /// мы не заметим этого, и ui продолжит смотреть на старые данные (до переподключения). Но настройки меняются
    /// только на странице входа, в это время наш TaskListController вообще уничтожается, т.к. на странице входа нет
    /// ui, смотряшего на контроллер. Поэтому в нашем случае это работает.

    authState.initCompletedFuture.whenComplete(() {
      return _applicationState.initCompletedFuture.whenComplete(() {
        _openedTasksSubscription = resubscribe<List<Task>>(
            _openedTasksSubscription, taskRepository.streamOpenedTasks(),
            (event) {
          taskListState.openedTasks.value = event;
          update();
        }, showProgress: true);

        /// добавлено чтобы провоцировать event в _currentDateSubscription при инициализации, т.к. в случае, если евент не случится
        /// мы не доходим до _closedTasksSubscription
        WidgetsBinding.instance!.addPostFrameCallback((Duration duration) {
          taskListState.currentDate.refresh();
        });

        _currentDateSubscription = resubscribe<DateTime>(
            _currentDateSubscription, taskListState.currentDate.stream,
            (dateTimeValue) {
          _closedTasksSubscription = resubscribe<List<Task>>(
              _closedTasksSubscription,
              taskRepository.streamClosedTasks(taskListState.currentDate.value),
              (event) {
            taskListState.closedTasks.value = event;
            update();
          }, showProgress: true);
        });

        _idleTimeReasonsSubscription = resubscribe<List<IdleTimeReason>>(
            _idleTimeReasonsSubscription,
            idleTimeReasonRepository.getIdleTimeReasons().asStream(), (event) {
          taskListState.idleTimeReasons.value = event;
          update();
        });

        _closeCodesSubscription = resubscribe<List<CloseCode>>(
            _closeCodesSubscription,
            closeCodeRepository.getCloseCodes().asStream(), (event) {
          taskListState.closeCodes.value = event;
          update();
        });

        return true;
      });
    });
  }

  Future<Task> registerIdle(
      IdleTimeReason reason, DateTime beginTime, DateTime? endTime) async {
    return await asyncShowProgressIndicatorOverlay(asyncFunction: () async {
      return await taskRepository.registerIdle(
          taskListState.currentTask.value!, reason, beginTime, endTime);
    });
  }

  Future<Task> finishIdle(DateTime beginTime, DateTime endTime) async {
    return await asyncShowProgressIndicatorOverlay(asyncFunction: () async {
      return await taskRepository.finishIdle(
          taskListState.currentTask.value!, beginTime, endTime);
    });
  }

  Future<Task> completeStage() async {
    return await asyncShowProgressIndicatorOverlay(asyncFunction: () async {
      return await taskRepository
          .completeStage(taskListState.currentTask.value!);
    });
  }

  Future<Task> closeOrder(CloseCode closeCode) async {
    return await asyncShowProgressIndicatorOverlay(asyncFunction: () async {
      return await taskRepository.closeOrder(
          taskListState.currentTask.value!, closeCode);
    });
  }

  Future<Work> registerWorkDetail(WorkType workType, bool notRequired,
      double? amount, List<Worker>? workers) async {
    return await asyncShowProgressIndicatorOverlay(asyncFunction: () async {
      return await taskRepository.registerWorkDetail(
          taskListState.currentTask.value!,
          workType,
          notRequired,
          amount,
          workers);
    });
  }

  Future<Work> deleteWorkDetail(WorkDetail workDetail) async {
    return await asyncShowProgressIndicatorOverlay(asyncFunction: () async {
      return await taskRepository.deleteWorkDetail(
          taskListState.currentTask.value!, workDetail);
    });
  }

  Future<bool> markWorksNotRequired(List<WorkType> workTypes) async {
    return await asyncShowProgressIndicatorOverlay(asyncFunction: () async {
      return await taskRepository.markWorksNotRequired(
          taskListState.currentTask.value!, workTypes);
    });
  }

  String _searchWorksText = "";

  String get searchWorksText => _searchWorksText;

  set searchWorksText(String value) {
    _searchWorksText = value.toLowerCase();
    update();
  }

  List<Work> getWorks() {
    WorkRepository workRepository = Get.find();
    List<Work> sortedWorks = workRepository
        .orderWorksByState(taskListState.currentTask.value?.works);

    return sortedWorks
        .where((element) =>
            element.workType.name.toLowerCase().contains(searchWorksText))
        .toList();
  }

  @override
  void onClose() {
    _openedTasksSubscription?.cancel();
    _closedTasksSubscription?.cancel();
    _currentDateSubscription?.cancel();
    _idleTimeReasonsSubscription?.cancel();
    _closeCodesSubscription?.cancel();
    super.onClose();
  }

  /// Храним сколько максимально строк может быть для адресного примечания, а также можем изменить
  int _maxLinesAddressCommentary = 3;

  int get maxLinesAddressCommentary => _maxLinesAddressCommentary;

  set maxLinesAddressCommentary(int value) {
    _maxLinesAddressCommentary = value;
    update();
  }

  /// Храним сколько максимально строк может быть для примечания, а также можем изменить
  int _maxLinesCommentary = 3;

  int get maxLinesCommentary => _maxLinesCommentary;

  set maxLinesCommentary(int value) {
    _maxLinesCommentary = value;
    update();
  }
}
