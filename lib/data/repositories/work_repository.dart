import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

import '../../domain/entities/work.dart';

class WorkRepository extends GetxService {
  List<Work> result = List.of({});

  @Deprecated("вроде вообще не нужен")
  List<Work> filterWorksByName(List<Work>? works, String searchText) {
    List<Work> result = [];
    if (works != null && works.isNotEmpty) {
      result =
          List.from(works.where((e) => e.workType.name.contains(searchText)));
    }
    return result;
  }

  // возвращает список работ, отсортированный по статусу:
  // еще не выполненные работы -> выполненные работы -> работы, которые выполнять не требуется
  @Deprecated("должен уйти в пользу WorksController.getWorks")
  List<Work> orderWorksByState(List<Work>? works) {
    List<Work> result = [];
    if (works != null && works.isNotEmpty) {
      result.addAll(works.where((e) =>
          !e.notRequired &&
          (e.workDetail != null && e.workDetail!.isNotEmpty)));
      result.addAll(works.where((e) =>
          !e.notRequired && (e.workDetail == null || e.workDetail!.isEmpty)));
      result.addAll(works.where((e) => e.notRequired));
    }
    return result;
  }
}
