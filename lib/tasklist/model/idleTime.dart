/// Простой
class IdleTime {
  /// Причина простоя
  String reason;

  /// Время начала простоя
  DateTime startDate;

  /// Время окончания простоя
  DateTime? endDate;

  IdleTime(
      {required this.reason,
      required this.startDate,
      this.endDate});
}