import '../../domain/entities/work.dart';

class WorkTypeFixtures {
  static final workType_1 = new WorkType(
      id: 1,
      name:
          "1.2. Диагностика, замена оборудования на АМС (включая интеграцию и настройку)",
      marks: 4);
  static final workType_2 = new WorkType(
      id: 2,
      name:
          "3.3.3. Аварийно-восстановительные работы по обеспечению временного электроснабжения продолжительностью более 72 часов (1 работа = дизеление в течение 24ч по истечение первых 72ч)",
      marks: 3);
  static final workType_3 = new WorkType(
      id: 3, name: "5.9. Замена, ремонт распределительного щита", marks: 4);
  static final workType_4 = new WorkType(
      id: 4,
      name: "6.3. Ремонт, перемещение, замена наружного кабель-роста",
      marks: 5);
  static final workType_5 = new WorkType(
      id: 5, name: "3.5. Юстировка РРЛ пролета (диам. от 1 до 1,8м)", marks: 4);
  static final workType_6 =
      new WorkType(id: 6, name: "3.6. Замена пролета", units: "м.", marks: 5);

  static final List<WorkType> workTypes = List.of(
      {workType_1, workType_2, workType_3, workType_4, workType_5, workType_6});
}
