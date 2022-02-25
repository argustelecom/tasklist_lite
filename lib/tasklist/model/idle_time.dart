import 'package:duration/duration.dart';
import 'package:duration/locale.dart';

/// Простой
class IdleTime {
  /// ID простоя
  int id;

  /// Причина простоя
  IdleTimeReason reason;

  /// Время начала простоя
  DateTime startDate;

  /// Время окончания простоя
  DateTime? endDate;

  IdleTime(
      {required this.id,
      required this.reason,
      required this.startDate,
      this.endDate});

  bool isCompleted() {
    return endDate != null;
  }

  Duration? getDuration() {
    if (isCompleted()) {
      return Duration(
          milliseconds: endDate!.millisecondsSinceEpoch -
              startDate.millisecondsSinceEpoch);
    } else
      return null;
  }

  String getDurationText() {
    if (getDuration() != null) {
      return prettyDuration(getDuration()!,
          tersity: DurationTersity.minute,
          abbreviated: true,
          delimiter: " ",
          spacer: "",
          locale: RussianDurationLanguage());
    } else
      return "";
  }

  factory IdleTime.fromJson(Map<String, dynamic> json) {
    return IdleTime(
      id: int.parse(json['id']),
      reason: json['reason'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['reason'] = this.reason;
    data['startDate'] = this.startDate.toString();
    data['endDate'] = this.endDate != null ? this.endDate.toString() : null;
    return data;
  }
}

/// Причина простоя
class IdleTimeReason {
  /// ID причины
  int id;

  /// Название причины
  String name;

  IdleTimeReason({required this.id, required this.name});

  @override
  String toString() {
    return this.name;
  }
}
