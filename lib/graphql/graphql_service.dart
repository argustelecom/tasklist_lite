import 'package:graphql/client.dart';

/// copy-pasted from flutter_movie, https://github.com/o1298098/Flutter-Movie
/// но пришлось адаптировать к graphql_flutter 5 (flutter_movie пока использует 3.1) и к null safety
class GraphQLService {
  // #TODO: final это прекрасно, но теперь если в ходе работы приложения изменится, например, url, как это будет учтено?
  late final HttpLink _httpLink;
  late final WebSocketLink _webSocketLink;
  // если не передавать store, то будет использоваться InMemoryStore, что нам и нужно
  final GraphQLCache cache = GraphQLCache();
  late final GraphQLClient _graphQLClient;
  late final GraphQLClient _webSocketClient;

  GraphQLService({required String url, required String webSocketUrl}) {
    //#TODO: в link`е также нужно настроить аутентификацию, или через header`ы или через credentials
    // пример с аутентификацией см. в закомменченном коде (с _authLink) в GraphQLService в flutter_movie
    // #TODO: параметры аутентификации должны откуда-то приходить, видимо после успешного входа на страничке логина
    _httpLink = HttpLink(url);
    _graphQLClient = GraphQLClient(link: _httpLink, cache: cache);

    // вебсокеты нужны для работы graphql subscription`ов
    // в примере flutter_movie это два разных url`а (для query/mutation и для subscription)
    _webSocketLink = WebSocketLink(webSocketUrl);
    _webSocketClient = GraphQLClient(link: _webSocketLink, cache: cache);
  }

  Future<QueryResult> query(String query,
      {Map<String, dynamic> variables = const {}}) {
    return _graphQLClient
        .query(QueryOptions(document: gql(query), variables: variables));
  }

  Future<QueryResult> mutate(String mutation,
      {Map<String, dynamic> variables = const {}}) {
    return _graphQLClient
        .mutate(MutationOptions(document: gql(mutation), variables: variables));
  }

  Stream<QueryResult> subscribe(String subscription,
      {String? operationName, Map<String, dynamic> variables = const {}}) {
    Stream<QueryResult> _stream = _webSocketClient.subscribe(
        SubscriptionOptions(
            document: gql(subscription),
            variables: variables,
            operationName: operationName));
    return _stream;
  }
}
