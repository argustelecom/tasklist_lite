import 'package:graphql/client.dart';

/// copy-pasted from flutter_movie, https://github.com/o1298098/Flutter-Movie
/// но пришлось адаптировать к graphql_flutter 5 (flutter_movie пока использует 3.1) и к null safety
class GraphQLService {
  // если не передавать store, то будет использоваться InMemoryStore, что нам и нужно
  final GraphQLCache cache = GraphQLCache();
  late GraphQLClient _graphQLClient;
  late GraphQLClient _webSocketClient;

  GraphQLService(
      {required String basicAuth,
      required String url,
      required String webSocketUrl}) {
    HttpLink _httpLink = HttpLink(url);
    AuthLink authLink = AuthLink(
      getToken: () => basicAuth,
    );
    Link link = authLink.concat(_httpLink);

    _graphQLClient = GraphQLClient(link: link, cache: cache);
    // вебсокеты нужны для работы graphql subscription`ов
    // в примере flutter_movie это два разных url`а (для query/mutation и для subscription)
    WebSocketLink _webSocketLink = WebSocketLink(webSocketUrl);
    Link webSocketLink = authLink.concat(_webSocketLink);
    _webSocketClient = GraphQLClient(link: webSocketLink, cache: cache);
  }

  Future<QueryResult> query(String query,
      {Map<String, dynamic> variables = const {}}) {
    return _graphQLClient
        .query(QueryOptions(document: gql(query), fetchPolicy: FetchPolicy.networkOnly, variables: variables));
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
