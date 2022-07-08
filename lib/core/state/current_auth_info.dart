/// интерфейс развязки между AuthState и использующим его слоем доступа к данным.
/// Нужен, чтобы не допускать прямой зависимости слоя доступа к данным(remote-репозиториев
/// и клиентов) от слоя представления (AuthState)
abstract class CurrentAuthInfo {
  String getCurrentAuthString();

  String getCurrentServerAddress();

  String getCurrentAuthStringForWS();
}
