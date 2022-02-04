import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tasklist_lite/tasklist/model/idle_time.dart';
import 'package:tasklist_lite/tasklist/model/task.dart';

/// идентификаторы возможных фикстур, используемых для отладки приложения, когда нет реальных удаленных данных
enum CurrentTaskFixture {
  /// первая, самая минималистичная фикстурка
  firstFixture,

  /// вторая пожирнее
  secondFixture,

  /// третья фикстурка для извращенцев
  thirdFixture,

  /// фикстура не выбрана, действует только полученный удаленно набор данных
  noneFixture
}

/// Служба, возвращающая набор задач по переданному идентификатору фикстуры
class TaskFixtures {
  // #TODO: в name должен быть скорее номер задачи, а указанное здесь должно быть в desc
  List<Task> firstTaskFixture = List.of(
      {new Task(id: 1, name: "Ленинский 107 Атлант замена компрессора")});

  List<Task> firstTaskFixtureAdditionalTasks =
      List.of({new Task(id: 10, name: "Ленинский 117 Минск диодный мост")});

  List<Task> secondTaskFixture = List.of({
    new Task(id: 2, name: "Papa Johns Ветеранов заказ 111"),
    new Task(
        id: 3,
        name: "Papa Johns 111 доставка Зины Портновой 15",
        assignee: "developer")
  });

  List<Task> secondTaskFixtureAdditionalTasks = List.of({
    new Task(id: 11, name: "Pizza Hut Ветеранов заказ 15"),
    new Task(id: 12, name: "Pizza Hut доствка Ленинский 144")
  });

  static Task firstTask = new Task(
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
      flexibleAttribs: new LinkedHashMap.of({
        "Наряд/Оператор": "Tele2",
        "Наряд/ID заявки оператора": "INT33564",
        "Наряд/Договор": "№464527",
        "Наряд/Приоритет": "2",
        "Объект/Тип объекта": "Базовая станция",
        "Объект/Название": "ВЛГ0127",
        "Объект/Пробег до объекта (км)": "9 км",
      }),
      idleTime: new IdleTime(
          reason: "Форс-мажор",
          startDate: DateUtils.dateOnly(DateTime.now())
              .add(const Duration(hours: -3))));

  static Task secondTask = new Task(
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
      createDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: 24 * 2 - 22)),
      isClosed: false,
      isOutdoor: true,
      flexibleAttribs: new LinkedHashMap.of({
        "Наряд/Оператор": "Megafon",
        "Наряд/ID заявки оператора": "INT35134",
        "Наряд/Договор": "№464527",
        "Наряд/Приоритет": "5",
        "Объект/Тип объекта": "ВОЛС",
        "Объект/Название": "Лосево-Песочное",
        "Объект/Пробег до объекта (км)": "73 км"
      }));

  static Task thirdTask = new Task(
      id: 3,
      name: "РР-28050",
      desc: "РР-28050 (ВЛГ4032)",
      processTypeName: "Разовые работы",
      taskType: "Назначение наряда бригаде",
      dueDate:
          DateUtils.dateOnly(DateTime.now()).add(const Duration(hours: 22)),
      assignee: null,
      address: "г.Вологда, ул.Лесопарковая, 9Б",
      latitude: null,
      longitude: null,
      comment:
          "ТРЦ Радуга. Работы только в ночное время. Дежурный инженер Семенов И.С. +79501234567",
      createDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: 24 * 2 - 22)),
      isClosed: false,
      isOutdoor: true,
      flexibleAttribs: new LinkedHashMap.of({
        "Наряд/Оператор": "Tele2",
        "Наряд/ID заявки оператора": "INT36197",
        "Наряд/Договор": "№464527",
        "Наряд/Приоритет": "5",
        "Объект/Тип объекта": "Базовая станция",
        "Объект/Название": "ВЛГ4032",
        "Объект/Пробег до объекта (км)": "5 км"
      }));

  static Task fourthTask = new Task(
      id: 4,
      name: "ТО-19099",
      desc: "ТО-19099 (ВЛГ0734)",
      processTypeName: "Техническое обслуживание",
      taskType: "Назначение наряда бригаде",
      dueDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: 24 * 1 + 16)),
      assignee: null,
      address: "г.Вологда, ул.Северная, 27",
      latitude: null,
      longitude: null,
      comment: "",
      createDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: 24 * 2 - 22)),
      isClosed: false,
      isOutdoor: true,
      flexibleAttribs: new LinkedHashMap.of({
        "Наряд/Оператор": "Tele2",
        "Наряд/ID заявки оператора": "INT45090",
        "Наряд/Договор": "№464527",
        "Наряд/Приоритет": "5",
        "Объект/Тип объекта": "Базовая станция",
        "Объект/Название": "ВЛГ0734",
        "Объект/Пробег до объекта (км)": "12 км"
      }));

  static Task fifthTask = new Task(
      id: 5,
      name: "РР-14569",
      desc: "РР-14569 (ВЛГ1077)",
      processTypeName: "Разовые работы",
      taskType: "Назначение наряда бригаде",
      dueDate: DateUtils.dateOnly(DateTime.now())
          .add(const Duration(hours: 24 * 3 + 15)),
      assignee: null,
      address: "г.Вологда, пр.Мира, 16",
      latitude: null,
      longitude: null,
      comment: "",
      createDate:
          DateUtils.dateOnly(DateTime.now()).add(const Duration(hours: -12)),
      isClosed: false,
      isOutdoor: true,
      flexibleAttribs: new LinkedHashMap.of({
        "Наряд/Оператор": "Tele2",
        "Наряд/ID заявки оператора": "INT44785",
        "Наряд/Договор": "№464527",
        "Наряд/Приоритет": "3",
        "Объект/Тип объекта": "Базовая станция",
        "Объект/Название": "ВЛГ1077",
        "Объект/Пробег до объекта (км)": "21 км"
      }));

  static Task sixthTask = new Task(
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
        "Наряд/Оператор": "Tele2",
        "Наряд/ID заявки оператора": "INT42748",
        "Наряд/Договор": "№464527",
        "Наряд/Приоритет": "3",
        "Объект/Тип объекта": "Базовая станция",
        "Объект/Название": "ВЛГ1379",
        "Объект/Пробег до объекта (км)": "2 км"
      }));

  static Task seventhTask = new Task(
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
        "Наряд/Оператор": "Tele2",
        "Наряд/ID заявки оператора": "INT34673",
        "Наряд/Договор": "№464836",
        "Наряд/Приоритет": "5",
        "Объект/Тип объекта": "Базовая станция",
        "Объект/Название": "ВЛГ1027",
        "Объект/Пробег до объекта (км)": "14 км"
      }));

  static Task eighthTask = new Task(
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
        "Наряд/Оператор": "Megafon",
        "Наряд/ID заявки оператора": "INT38676",
        "Наряд/Договор": "№734577",
        "Наряд/Приоритет": "5",
        "Объект/Тип объекта": "Базовая станция",
        "Объект/Название": "ВЛГ2625",
        "Объект/Пробег до объекта (км)": "2 км"
      }));

  static Task ninthTask = new Task(
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
        "Наряд/Оператор": "Megafon",
        "Наряд/ID заявки оператора": "INT33566",
        "Наряд/Договор": "№734577",
        "Наряд/Приоритет": "5",
        "Объект/Тип объекта": "Базовая станция",
        "Объект/Название": "ВЛГ2023",
        "Объект/Пробег до объекта (км)": "10 км"
      }));

  List<Task> thirdTaskFixture = List.of({
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

  List<Task> thirdTaskFixtureAdditionalTasks = List.of({
    new Task(
        id: 11,
        name: "ТО-17051",
        desc: "ТО-17051 (ВЛГ1024)",
        processTypeName: "Техническое обслужавание",
        taskType: "Назначение наряда бригаде",
        dueDate: DateUtils.dateOnly(DateTime.now())
            .add(const Duration(hours: 24 * 7 + 14)),
        assignee: null,
        address: "г.Вологда, пр.Космонавтов, 23a",
        latitude: null,
        longitude: null,
        comment: "По вопросам доступа в диспетчерскую, вход с торца",
        createDate: DateUtils.dateOnly(DateTime.now())
            .add(const Duration(hours: 24 * 4 - 20)),
        isClosed: false,
        isOutdoor: true,
        flexibleAttribs: new LinkedHashMap.of({
          "Наряд/Оператор": "Megafon",
          "Наряд/ID заявки оператора": "INT43463",
          "Наряд/Договор": "№464527",
          "Наряд/Приоритет": "9",
          "Объект/Тип объекта": "Базовая станция",
          "Объект/Название": "ВЛГД1024",
          "Объект/Пробег до объекта (км)": "6 км"
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
          "Наряд/Оператор": "Tele2",
          "Наряд/ID заявки оператора": "INT42748",
          "Наряд/Договор": "№464527",
          "Наряд/Приоритет": "1",
          "Объект/Тип объекта": "Базовая станция",
          "Объект/Название": "ВЛГ2937",
          "Объект/Пробег до объекта (км)": "2 км"
        }))
  });

  List<Task> getTasks(CurrentTaskFixture currentTaskFixture) {
    if (currentTaskFixture == CurrentTaskFixture.firstFixture) {
      // чтобы возвращалась не сама фикстура, а ее копия (иначе можем случайно потом изменить)
      return List.of(firstTaskFixture);
    } else if (currentTaskFixture == CurrentTaskFixture.secondFixture) {
      return List.of(secondTaskFixture);
    } else if (currentTaskFixture == CurrentTaskFixture.thirdFixture) {
      return List.of(thirdTaskFixture);
    } else
      return new List.of({});
  }

  ///***************************************************************************
  /// периодически подает список с разным набором задач, чтобы была возможность
  /// протестировать клиентскую часть без подписок graphql
  Stream<List<Task>> streamOpenedTasks(
      CurrentTaskFixture currentTaskFixture) async* {
    while (true) {
      List<Task> tasks = getTasks(currentTaskFixture);
      // по четным минутам в возвращаемое значение подмешиваем additional задачи
      if (DateTime.now().minute.isEven) {
        if (currentTaskFixture == CurrentTaskFixture.firstFixture) {
          tasks.addAll(firstTaskFixtureAdditionalTasks);
        } else if (currentTaskFixture == CurrentTaskFixture.secondFixture) {
          tasks.addAll(secondTaskFixtureAdditionalTasks);
        } else {
          tasks.addAll(thirdTaskFixtureAdditionalTasks);
        }
      }
      yield tasks.where((e) => !e.isClosed).toList();

      await Future.delayed(Duration(seconds: 10));
    }
  }

  Stream<List<Task>> streamClosedTasks(
      CurrentTaskFixture currentTaskFixture, DateTime day) async* {
    while (true) {
      List<Task> tasks = getTasks(currentTaskFixture);

      if (DateTime.now().minute.isEven) {
        if (currentTaskFixture == CurrentTaskFixture.firstFixture) {
          tasks.addAll(firstTaskFixtureAdditionalTasks);
        } else if (currentTaskFixture == CurrentTaskFixture.secondFixture) {
          tasks.addAll(secondTaskFixtureAdditionalTasks);
        } else {
          tasks.addAll(thirdTaskFixtureAdditionalTasks);
        }
      }
      List<Task> closedTasks = tasks.where((e) => e.isClosed).toList();
      yield closedTasks;

      await Future.delayed(Duration(seconds: 10));
    }
  }
}
