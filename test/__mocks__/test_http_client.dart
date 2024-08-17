// ignore_for_file: always_specify_types

import 'package:http/http.dart' as http;

typedef TestHttpResponseBuilder = http.Response Function(
  http.BaseRequest request,
);

class TestHttpClient extends http.BaseClient {
  TestHttpResponseBuilder? responseBuilder;

  static Future<void> run(
    Future<void> Function(TestHttpClient client) fn,
  ) async {
    final TestHttpClient client = TestHttpClient();
    await http.runWithClient(
      () => fn(client),
      () => client,
    );
  }

  static http.Response createResponse({String? body, int statusCode = 200}) =>
      http.Response(body ?? '', statusCode);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final http.Response response = (responseBuilder ??
        (http.BaseRequest req) => http.Response('', 200))(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      contentLength: response.contentLength,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
      request: request,
    );
  }
}
