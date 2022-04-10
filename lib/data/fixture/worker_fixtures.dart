import 'package:tasklist_lite/domain/entities/worker.dart';

class WorkerFixtures {
  static final worker_1 = new Worker(
      id: 1,
      family: "Богданова",
      name: "Ирина",
      surname: "Леонидовна",
      tabNumber: "123045",
      mainWorksite: "О2О АВР");
  static final worker_2 = new Worker(
      id: 2,
      family: "Смирнова",
      name: "Светлана",
      surname: "Алексеевна",
      tabNumber: "100126",
      mainWorksite: "О2О АВР");
  static final worker_3 = new Worker(
      id: 3,
      family: "Синицын",
      name: "Владислав",
      surname: "Семенович",
      tabNumber: "088246",
      mainWorksite: "О2О РР");
  static final worker_4 = new Worker(
      id: 4,
      family: "Иванов",
      name: "Михаил",
      surname: "Владимирович",
      tabNumber: "765205",
      mainWorksite: "О2О ТО");
  static final worker_5 = new Worker(
      id: 5,
      family: "Морозов",
      name: "Сергей",
      surname: "Викторович",
      tabNumber: "440592",
      mainWorksite: "О2О ТО");

  static final List<Worker> workers =
      List.of({worker_1, worker_2, worker_3, worker_4, worker_5});
}
