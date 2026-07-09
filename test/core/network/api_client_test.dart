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
}
