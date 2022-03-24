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
          delimiter: " ",
          spacer: " ",
          locale: RussianDurationLanguage());
    } else
      return "";
  }

  factory IdleTime.fromJson(Map<String, dynamic> json) {
    return IdleTime(
      id: int.parse(json['id']),
      reason: IdleTimeReason.fromJson(json['reason']),
      startDate: DateTime.parse(json['beginTime']),
      endDate: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id.toString();
    data['reason'] = this.reason.toJson();
    data['beginTime'] = this.startDate.toString();
    data['endTime'] = this.endDate != null ? this.endDate.toString() : null;
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

  factory IdleTimeReason.fromJson(Map<String, dynamic> json) {
    return IdleTimeReason(
      id: int.parse(json['id']),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id.toString();
    data['name'] = this.name;
    return data;
  }
}
