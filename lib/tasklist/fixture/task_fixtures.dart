import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tasklist_lite/tasklist/fixture/idle_time_reason_fixtures.dart';
import 'package:tasklist_lite/tasklist/model/idle_time.dart';
import 'package:tasklist_lite/tasklist/model/stage.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';

/// Служба, возвращающая набор задач по переданному идентификатору фикстуры
class TaskFixtures {
  static const foreignOrderIdFlexAttrName = "Наряд/ID заявки оператора";
  static const objectNameFlexAttrName = "Объект/Название";
  static const orderOperatorNameFlexAttrName = "Наряд/Оператор";
  static const distanceToObjectFlexAttrName = "Объект/Пробег до объекта (км)";

  static final Task firstTask = new Task(
      id: 1,
      name: "АВР-24035",
      desc: "АВР-24035 (ВЛГ0127)",
      processTypeName: "Аварийно-восстановительные работы",
      taskType: "Выполнение работ",
      dueDate:
          DateUtils.dateOnly(DateTime.now()).add(const Duration(hours: 11)),
      assignee: "Богданова И.Л.",
      address: "г.Вологда, ул.Садовая, 101",
      latitude: "56.863148",
      longitude: "60.642127",
      comment: "По вопросам доступа Филиппов Е.А. +79207654321",
      createDate:
          DateUtils.dateOnly(DateTime.now()).add(const Duration(hours: -6)),
      isClosed: false,
      isOutdoor: true,
      ttmsId: "HM04598",
      stage: Stage(
          name: "Выезд на объект",
          number: 2,
          isLast: false,
          dueDate: DateUtils.dateOnly(DateTime.now())
              .add(const Duration(hours: 20))),
      flexibleAttribs: new LinkedHashMap.of({
        orderOperatorNameFlexAttrName: "Tele2",
        foreignOrderIdFlexAttrName: "INT33564",
        "Наряд/Договор": "№464527",
        "Наряд/Приоритет": "2",
        "Объект/Тип объекта": "Базовая станция",
        objectNameFlexAttrName: "ВЛГ0127",
        distanceToObjectFlexAttrName: "9 км",
      }),
      idleTimeList: [
        new IdleTime(
            id: 24,
            reason: IdleTimeReasonFixtures.idleTimeReason_2,
            startDate: DateUtils.dateOnly(DateTime.now())
                .add(const Duration(hours: -5)),
            endDate: DateUtils.dateOnly(DateTime.now())
                .add(const Duration(hours: -4))),
        new IdleTime(
            id: 25,
            reason: IdleTimeReasonFixtures.idleTimeReason_6,
            startDate: DateUtils.dateOnly(DateTime.now())
                .add(const Duration(hours: -3)))
      ]);

  static final Task secondTask = new Task(
      id: 2,
      name: "РР-27089",
      desc: "РР-27089 (ВОЛС Лосево-Песочное)",
      processTypeName: "Разовые работы",
      taskType: "Выезд на объект",
      dueDate:
          DateUtils.dateOnly(DateTime.now()).add(const Duration(hours: 15)),
      assignee: "Богданова И.Л., Смирнов С.А.",
      address: null,
      latitude: "56.888854",
      longitude: "60.612602",
      comment: "Муфта М172",
      stage: Stage(
          name: "В работе",
          number: 3,
          isLast: false,
          dueDate:
              DateUtils.dateOnly(DateTime.now()).add(const Duration(hours: 6))),
      createDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: 24 * 2 - 22)),
      isClosed: false,
      isOutdoor: true,
      flexibleAttribs: new LinkedHashMap.of({
        orderOperatorNameFlexAttrName: "Megafon",
        foreignOrderIdFlexAttrName: "INT35134",
        "Наряд/Договор": "№464527",
        "Наряд/Приоритет": "5",
        "Объект/Тип объекта": "ВОЛС",
        objectNameFlexAttrName: "ВОЛС Лосево-Песочное",
        distanceToObjectFlexAttrName: "73 км"
      }));

  static final Task thirdTask = new Task(
      id: 3,
      name: "РР-28050",
      desc: "РР-28050 (ВЛГ4032)",
      processTypeName: "Разовые работы",
      taskType: "Назначение наряда бригаде",
      dueDate:
          DateUtils.dateOnly(DateTime.now()).add(const Duration(hours: 22)),
      assignee: "Богданова И.Л.",
      address: "г.Вологда, ул.Лесопарковая, 9Б",
      latitude: null,
      longitude: null,
      comment:
          "ТРЦ Радуга. Работы только в ночное время. Дежурный инженер Семенов И.С. +79501234567",
      createDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: 24 * 2 - 22)),
      isClosed: false,
      isOutdoor: true,
      stage: Stage(
          name: "Ожидание закрытия в TTMS",
          number: 4,
          isLast: true,
          dueDate: DateUtils.dateOnly(DateTime.now())
              .add(const Duration(hours: -6))),
      flexibleAttribs: new LinkedHashMap.of({
        orderOperatorNameFlexAttrName: "Tele2",
        foreignOrderIdFlexAttrName: "INT36197",
        "Наряд/Договор": "№464527",
        "Наряд/Приоритет": "5",
        "Объект/Тип объекта": "Базовая станция",
        objectNameFlexAttrName: "ВЛГ4032",
        distanceToObjectFlexAttrName: "5 км"
      }));

  static final Task fourthTask = new Task(
      id: 4,
      name: "ТО-19099",
      desc: "ТО-19099 (ВЛГ0734)",
      processTypeName: "Техническое обслуживание",
      taskType: "Назначение наряда бригаде",
      dueDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: 24 * 1 + 16)),
      assignee: "Богданова И.Л.",
      address: "г.Вологда, ул.Северная, 27",
      latitude: null,
      longitude: null,
      comment: "",
      createDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: 24 * 2 - 22)),
      isClosed: false,
      isOutdoor: true,
      flexibleAttribs: new LinkedHashMap.of({
        orderOperatorNameFlexAttrName: "Tele2",
        foreignOrderIdFlexAttrName: "INT45090",
        "Наряд/Договор": "№464527",
        "Наряд/Приоритет": "5",
        "Объект/Тип объекта": "Базовая станция",
        objectNameFlexAttrName: "ВЛГ0734",
        distanceToObjectFlexAttrName: "12 км"
      }));

  static final Task fifthTask = new Task(
      id: 5,
      name: "РР-14569",
      desc: "РР-14569 (ВЛГ1077)",
      processTypeName: "Разовые работы",
      taskType: "Назначение наряда бригаде",
      dueDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: 24 * 3 + 15)),
      assignee: "Богданова И.Л.",
      address: "г.Вологда, пр.Мира, 16",
      latitude: null,
      longitude: null,
      comment: "",
      createDate:
          DateUtils.dateOnly(DateTime.now()).add(const Duration(hours: -12)),
      isClosed: false,
      isOutdoor: true,
      flexibleAttribs: new LinkedHashMap.of({
        orderOperatorNameFlexAttrName: "Tele2",
        foreignOrderIdFlexAttrName: "INT44785",
        "Наряд/Договор": "№464527",
        "Наряд/Приоритет": "3",
        "Объект/Тип объекта": "Базовая станция",
        objectNameFlexAttrName: "ВЛГ1077",
        distanceToObjectFlexAttrName: "21 км"
      }));

  static final Task sixthTask = new Task(
      id: 6,
      name: "АВР-10357",
      desc: "АВР-10357 (ВЛГ1379)",
      processTypeName: "Аварийно-восстановительные работы",
      taskType: "Закрыт",
      dueDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: -24 * 1 + 10)),
      assignee: "Богданова И.Л.",
      address: "г.Вологда, ул.Правды, 99",
      latitude: null,
      longitude: null,
      comment: "",
      createDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: -24 * 4 + 12)),
      closeDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: -24 * 1 + 10)),
      isClosed: true,
      isOutdoor: true,
      flexibleAttribs: new LinkedHashMap.of({
        orderOperatorNameFlexAttrName: "Tele2",
        foreignOrderIdFlexAttrName: "INT42748",
        "Наряд/Договор": "№464527",
        "Наряд/Приоритет": "3",
        "Объект/Тип объекта": "Базовая станция",
        objectNameFlexAttrName: "ВЛГ1379",
        distanceToObjectFlexAttrName: "2 км"
      }));

  static final Task seventhTask = new Task(
      id: 7,
      name: "РР-10346",
      desc: "РР-10346 (ВЛГ1027)",
      processTypeName: "Разовые работы",
      taskType: "Закрыт",
      dueDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: -24 * 1 + 13)),
      assignee: "Богданова И.Л.",
      address: "г.Вологда, ул.Нагорная, 17",
      latitude: null,
      longitude: null,
      comment: "",
      createDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: -24 * 4 + 12)),
      closeDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: -24 * 1 + 14)),
      isClosed: true,
      isOutdoor: true,
      flexibleAttribs: new LinkedHashMap.of({
        orderOperatorNameFlexAttrName: "Tele2",
        foreignOrderIdFlexAttrName: "INT34673",
        "Наряд/Договор": "№464836",
        "Наряд/Приоритет": "5",
        "Объект/Тип объекта": "Базовая станция",
        objectNameFlexAttrName: "ВЛГ1027",
        distanceToObjectFlexAttrName: "14 км"
      }));

  static final Task eighthTask = new Task(
      id: 8,
      name: "РР-11542",
      desc: "РР-11542 (ВЛГ2625)",
      processTypeName: "Разовые работы",
      taskType: "Закрыт",
      dueDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: -24 * 1 + 17)),
      assignee: "Богданова И.Л.",
      address: "г.Вологда, пер.Привокзальный, 3",
      latitude: null,
      longitude: null,
      comment: "",
      createDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: -24 * 4 + 12)),
      closeDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: -24 * 1 + 16)),
      isClosed: true,
      isOutdoor: true,
      flexibleAttribs: new LinkedHashMap.of({
        orderOperatorNameFlexAttrName: "Megafon",
        foreignOrderIdFlexAttrName: "INT38676",
        "Наряд/Договор": "№734577",
        "Наряд/Приоритет": "5",
        "Объект/Тип объекта": "Базовая станция",
        objectNameFlexAttrName: "ВЛГ2625",
        distanceToObjectFlexAttrName: "2 км"
      }));

  static final Task ninthTask = new Task(
      id: 9,
      name: "РР-13678",
      desc: "РР-13678 (ВЛГ2023)",
      processTypeName: "Разовые работы",
      taskType: "Закрыт",
      dueDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: -24 * 0 + 9)),
      assignee: "Богданова И.Л., Синицын В.С.",
      address: "г.Вологда, пр.Лесной, 113",
      latitude: null,
      longitude: null,
      comment: "",
      createDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: -24 * 4 + 12)),
      closeDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: -24 * 0 + 9)),
      isClosed: true,
      isOutdoor: true,
      flexibleAttribs: new LinkedHashMap.of({
        orderOperatorNameFlexAttrName: "Megafon",
        foreignOrderIdFlexAttrName: "INT33566",
        "Наряд/Договор": "№734577",
        "Наряд/Приоритет": "5",
        "Объект/Тип объекта": "Базовая станция",
        objectNameFlexAttrName: "ВЛГ2023",
        distanceToObjectFlexAttrName: "10 км"
      }));

  /// раньше были еще две фикстурки, а это была третьей
  final List<Task> taskFixture = List.of({
    firstTask,
    secondTask,
    thirdTask,
    fourthTask,
    fifthTask,
    sixthTask,
    seventhTask,
    eighthTask,
    ninthTask
  });

  final List<Task> taskFixtureAdditionalTasks = List.of({
    new Task(
        id: 11,
        name: "ТО-17051",
        desc: "ТО-17051 (ВЛГ1024)",
        processTypeName: "Техническое обслужавание",
        taskType: "Назначение наряда бригаде",
        dueDate: DateUtils.dateOnly(DateTime.now())
            .add(const Duration(hours: 24 * 7 + 14)),
        assignee: "Богданова И.Л.",
        address: "г.Вологда, пр.Космонавтов, 23a",
        latitude: null,
        longitude: null,
        comment: "По вопросам доступа в диспетчерскую, вход с торца",
        createDate: DateUtils.dateOnly(DateTime.now())
            .add(const Duration(hours: 24 * 4 - 20)),
        isClosed: false,
        isOutdoor: true,
        flexibleAttribs: new LinkedHashMap.of({
          orderOperatorNameFlexAttrName: "Megafon",
          foreignOrderIdFlexAttrName: "INT43463",
          "Наряд/Договор": "№464527",
          "Наряд/Приоритет": "9",
          "Объект/Тип объекта": "Базовая станция",
          objectNameFlexAttrName: "ВЛГД1024",
          distanceToObjectFlexAttrName: "6 км"
        })),
    new Task(
        id: 12,
        name: "АВР-18364",
        desc: "АВР-18364 (ВЛГ2937)",
        processTypeName: "Аварийно-восстановительные работы",
        taskType: "Выезд на объект",
        dueDate: DateUtils.dateOnly(DateTime.now())
            .add(const Duration(hours: -24 * 0 + 13)),
        assignee: "Богданова И.Л.",
        address: "г.Вологда, ул.Лермонтова, 11",
        latitude: null,
        longitude: null,
        comment: "",
        createDate: DateUtils.dateOnly(DateTime.now())
            .add(const Duration(hours: -24 * 0 + 11)),
        isClosed: false,
        isOutdoor: true,
        flexibleAttribs: new LinkedHashMap.of({
          orderOperatorNameFlexAttrName: "Tele2",
          foreignOrderIdFlexAttrName: "INT42748",
          "Наряд/Договор": "№464527",
          "Наряд/Приоритет": "1",
          "Объект/Тип объекта": "Базовая станция",
          objectNameFlexAttrName: "ВЛГ2937",
          distanceToObjectFlexAttrName: "2 км"
        }))
  });

  List<Task> getTasks() {
    return List.of(taskFixture);
  }

  ///***************************************************************************
  /// периодически подает список с разным набором задач, чтобы была возможность
  /// протестировать клиентскую часть без подписок graphql
  Stream<List<Task>> streamOpenedTasks() async* {
    while (true) {
      List<Task> tasks = getTasks();
      // по четным минутам в возвращаемое значение подмешиваем additional задачи
      if (DateTime.now().minute.isEven) {
        tasks.addAll(taskFixtureAdditionalTasks);
      }
      yield tasks.where((e) => !e.isClosed).toList();

      await Future.delayed(Duration(seconds: 10));
    }
  }

  Stream<List<Task>> streamClosedTasks(DateTime day) async* {
    while (true) {
      List<Task> tasks = getTasks();

      if (DateTime.now().minute.isEven) {
        tasks.addAll(taskFixtureAdditionalTasks);
      }
      List<Task> closedTasks = tasks.where((e) => e.isClosed).toList();
      yield closedTasks;

      await Future.delayed(Duration(seconds: 10));
    }
  }
}
