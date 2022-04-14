/// интерфейс развязки между ApplicationState и использующим его слоем доступа к данным.
/// Нужен, чтобы не допускать прямой зависимости слоя доступа к данным(remote-репозиториев
/// и клиентов) от слоя представления (ApplicationState)
abstract class CurrentAppInfo {
  bool isAppInDemonstrationMode();
}
