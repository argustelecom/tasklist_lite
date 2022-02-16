class IdleTimeReasonFixtures {
  List<String> thirdIdleTimeReasonFixture = List.of({
    "Нерабочее время",
    "Дорожная обстановка",
    "Клиент недоступен",
    "Доступ к объекту ограничен",
    "Временное электроснабжение",
    "Форс-мажор"
  });

  List<String> getIdleTimeReasons() {
    return thirdIdleTimeReasonFixture;
  }
}
