/// Событие в истории
class Comment {
  ///Персона, которая сгенерировала событие
  final String person;

  /// Тип события(вижу что может быть коммент или файл, а может что-то еще?)
  final String type;

  ///С уведомлением или без? По умолчанию без
  final isAlarm;

  ///Какое-то содержимое события
  var content;

  ///Дата события
  final DateTime date;

  Comment(
      {required this.person,
      required this.type,
      required this.content,
      required this.date,
      required this.isAlarm
      });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      person: json['person'],
      type: json['type'],
      isAlarm: json['important'],
      content: json['text'] ,
      date: DateTime.parse(json['date'])
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['person'] = this.person;
    data['type'] = this.type;
    data['important'] = this.isAlarm;
    data['text'] = this.content;
    data['date'] =  this.date.toString();
    return data;
  }
}
