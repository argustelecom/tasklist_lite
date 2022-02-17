import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:tasklist_lite/crazylib/date_picker_button.dart';

/// Простой
class IdleTime {
  /// ID простоя
  int id;

  /// Причина простоя
  String reason;

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
}
