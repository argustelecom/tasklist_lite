/// Шифр закрытия
class CloseCode {
  /// ID шифра
  int id;

  /// Название шифра
  String name;

  CloseCode({required this.id, required this.name});

  @override
  String toString() {
    return this.name;
  }

  factory CloseCode.fromJson(Map<String, dynamic> json) {
    return CloseCode(
      id: int.parse(json['id']),
      name: json['objectName'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['objectName'] = this.name;
    return data;
  }
}
