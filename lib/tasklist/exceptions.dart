/// Ошибки, проброшенные из remote_client при вызове сервера.
/// (в т.ч. ошибки обращения к серверу, ошибки валидации ответа, бизнес-ошибки сервера, системные ошибки сервера)
/// Как правило, выводятся в диалогах.
/// Выделены в отдельный класс во многом ради переопределения toString (формат вывода Exception не устраивает).
class ExternalException implements Exception {
  final String? message;

  const ExternalException(this.message);

  String toString() {
    return message ?? "Ошибка сервера";
  }
}
