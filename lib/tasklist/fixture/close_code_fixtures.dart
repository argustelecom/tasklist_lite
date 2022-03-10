import '../model/close_code.dart';

class CloseCodeFixtures {
  static final closeCode_1 = new CloseCode(id: 1, name: "ВЫП-Выполнено");
  static final closeCode_2 = new CloseCode(id: 2, name: "АН-Наряд аннулирован");

  List<CloseCode> closeCodeFixture = List.of({closeCode_1, closeCode_2});

  List<CloseCode> getCloseCodes() {
    return closeCodeFixture;
  }
}
