import 'package:logging/logging.dart';

/// Ошибки, проброшенные из remote_client при вызове сервера.
/// (в т.ч. ошибки обращения к серверу, ошибки валидации ответа, бизнес-ошибки сервера, системные ошибки сервера)
/// Как правило, выводятся в диалогах.
/// Выделены в отдельный класс во многом ради переопределения toString (формат вывода Exception не устраивает).
class ExternalException implements Exception {
  final String? message;

  ExternalException(this.message) {
    // #TODO: не совсем хорошо логгировать исключение не в момент throw, а в конструкторе.
    // но не хочется повторять этот код во всех местах, где throw
    Logger log = Logger(this.runtimeType.toString());
    log.warning(message, this, StackTrace.current);
  }

  String toString() {
    return message ?? "Ошибка сервера";
  }
}
