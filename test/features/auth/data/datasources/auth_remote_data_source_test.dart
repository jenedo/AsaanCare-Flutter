import 'dart:convert';

import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/core/network/api_endpoints.dart';
import 'package:asaancare/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:asaancare/features/auth/data/storage/auth_token_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthRemoteDataSource secure token persistence', () {
    test('login persists the returned access token', () async {
      final tokenStore = _FakeAuthTokenStore();
      final dataSource = _dataSource(
        tokenStore: tokenStore,
        handler: (request) async {
          expect(request.method, 'POST');
          expect(request.url.path, ApiEndpoints.authLogin);

          return http.Response(
            jsonEncode({'accessToken': 'token-123', 'user': _userJson}),
            200,
          );
        },
      );

      final user = await dataSource.login(
        emailOrPhone: 'ayesha@example.com',
        password: 'safe-test-password',
      );

      expect(user.id, 'patient-001');
      expect(tokenStore.token, 'token-123');
      expect(tokenStore.writeCount, 1);
    });

    test('a new datasource instance restores the persisted session', () async {
      final tokenStore = _FakeAuthTokenStore(token: 'persisted-token');
      final dataSource = _dataSource(
        tokenStore: tokenStore,
        handler: (request) async {
          expect(request.method, 'GET');
          expect(request.url.path, ApiEndpoints.authMe);
          expect(request.headers['Authorization'], 'Bearer persisted-token');

          return http.Response(jsonEncode({'user': _userJson}), 200);
        },
      );

      final user = await dataSource.getCurrentUser();

      expect(user?.id, 'patient-001');
      expect(tokenStore.readCount, 1);
    });

    test('registration uses the patient auth contract', () async {
      final tokenStore = _FakeAuthTokenStore();
      final dataSource = _dataSource(
        tokenStore: tokenStore,
        handler: (request) async {
          expect(request.method, 'POST');
          expect(request.url.path, ApiEndpoints.authRegister);
          expect(request.headers['Authorization'], isNull);
          expect(jsonDecode(request.body), {
            'fullName': 'Ayesha Noor',
            'emailOrPhone': 'ayesha@example.com',
            'password': 'safe-test-password',
            'role': 'patient',
          });

          return http.Response(jsonEncode({'data': _userJson}), 201);
        },
      );

      final user = await dataSource.registerPatient(
        fullName: ' Ayesha Noor ',
        emailOrPhone: ' ayesha@example.com ',
        password: 'safe-test-password',
      );

      expect(user.id, 'patient-001');
      expect(tokenStore.writeCount, 0);
    });

    test('login rejects a success response without an access token', () async {
      final tokenStore = _FakeAuthTokenStore();
      final dataSource = _dataSource(
        tokenStore: tokenStore,
        handler: (_) async =>
            http.Response(jsonEncode({'user': _userJson}), 200),
      );

      expect(
        () => dataSource.login(
          emailOrPhone: 'ayesha@example.com',
          password: 'safe-test-password',
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('did not include an access token'),
          ),
        ),
      );
      expect(tokenStore.writeCount, 0);
    });

    test('an unauthorized session clears the persisted token', () async {
      final tokenStore = _FakeAuthTokenStore(token: 'expired-token');
      final dataSource = _dataSource(
        tokenStore: tokenStore,
        handler: (request) async {
          return http.Response(
            jsonEncode({'message': 'Session expired.'}),
            401,
          );
        },
      );

      final user = await dataSource.getCurrentUser();

      expect(user, isNull);
      expect(tokenStore.token, isNull);
      expect(tokenStore.clearCount, 1);
    });

    test('logout clears the token before sending the remote request', () async {
      final tokenStore = _FakeAuthTokenStore(token: 'logout-token');
      final dataSource = _dataSource(
        tokenStore: tokenStore,
        handler: (request) async {
          expect(tokenStore.token, isNull);
          expect(request.method, 'POST');
          expect(request.url.path, ApiEndpoints.authLogout);
          expect(request.headers['Authorization'], 'Bearer logout-token');

          return http.Response('', 204);
        },
      );

      await dataSource.logout();

      expect(tokenStore.token, isNull);
      expect(tokenStore.clearCount, 1);
    });
  });
}

const Map<String, dynamic> _userJson = {
  'id': 'patient-001',
  'fullName': 'Ayesha Noor',
  'email': 'ayesha@example.com',
  'role': 'patient',
};

AuthRemoteDataSource _dataSource({
  required _FakeAuthTokenStore tokenStore,
  required Future<http.Response> Function(http.Request request) handler,
}) {
  return AuthRemoteDataSource(
    apiClient: ApiClient(
      client: MockClient(handler),
      baseUrl: 'https://api.example.test',
      timeout: const Duration(seconds: 2),
    ),
    tokenStore: tokenStore,
  );
}

class _FakeAuthTokenStore implements AuthTokenStore {
  _FakeAuthTokenStore({this.token});

  String? token;
  int readCount = 0;
  int writeCount = 0;
  int clearCount = 0;

  @override
  Future<String?> readAccessToken() async {
    readCount++;
    return token;
  }

  @override
  Future<void> writeAccessToken(String token) async {
    writeCount++;
    this.token = token;
  }

  @override
  Future<void> clearAccessToken() async {
    clearCount++;
    token = null;
  }
}
