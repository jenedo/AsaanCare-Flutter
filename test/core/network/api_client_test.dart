import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/core/network/api_exception.dart';

void main() {
  test('ApiClient returns decoded JSON for a successful response', () async {
    final client = ApiClient(
      client: MockClient((request) async {
        return http.Response(
          '{"data":{"ok":true}}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
      baseUrl: 'https://api.example.com',
      timeout: const Duration(seconds: 5),
    );

    final response = await client.getJson('/v1/health');

    expect(response['data'], isA<Map>());
  });

  test(
    'ApiClient throws a typed exception for unauthorized response',
    () async {
      final client = ApiClient(
        client: MockClient((request) async {
          return http.Response(
            '{"message":"Unauthorized"}',
            401,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: 'https://api.example.com',
        timeout: const Duration(seconds: 5),
      );

      expect(
        () => client.getJson('/v1/auth/me'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 401)
              .having(
                (error) => error.isUnauthorized,
                'isUnauthorized',
                isTrue,
              ),
        ),
      );
    },
  );

  test('ApiClient sends JSON, bearer auth, and query parameters', () async {
    final client = ApiClient(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v1/doctors');
        expect(request.url.queryParameters, {
          'specialty': 'general medicine',
          'page': '2',
        });
        expect(request.headers['Accept'], 'application/json');
        expect(request.headers['Content-Type'], contains('application/json'));
        expect(request.headers['Authorization'], 'Bearer secure-token');
        return http.Response('{"data":[]}', 200);
      }),
      baseUrl: 'https://api.example.com/',
      timeout: const Duration(seconds: 5),
    );

    await client.getJson(
      'v1/doctors',
      bearerToken: ' secure-token ',
      queryParameters: {'specialty': 'general medicine', 'page': '2'},
    );
  });

  test('ApiClient reads the standard nested API error envelope', () async {
    final client = ApiClient(
      client: MockClient(
        (_) async => http.Response(
          '{"error":{"code":"validation_error","message":"Email is invalid."}}',
          422,
        ),
      ),
      baseUrl: 'https://api.example.com',
      timeout: const Duration(seconds: 5),
    );

    expect(
      () => client.postJson('/v1/auth/register', body: const {}),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 422)
            .having((error) => error.message, 'message', 'Email is invalid.'),
      ),
    );
  });

  test('ApiClient accepts an empty successful response', () async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 204)),
      baseUrl: 'https://api.example.com',
      timeout: const Duration(seconds: 5),
    );

    expect(await client.postJson('/v1/auth/logout'), isEmpty);
  });

  test('ApiClient rejects invalid JSON in a successful response', () async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('not-json', 200)),
      baseUrl: 'https://api.example.com',
      timeout: const Duration(seconds: 5),
    );

    expect(
      () => client.getJson('/v1/doctors'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 200)
            .having(
              (error) => error.message,
              'message',
              'The server returned invalid JSON.',
            ),
      ),
    );
  });
}
