import 'dart:convert';
import 'dart:io';

import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/core/network/api_endpoints.dart';
import 'package:asaancare/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:asaancare/features/auth/data/storage/auth_token_store.dart';
import 'package:asaancare/features/auth/domain/entities/auth_user.dart';
import 'package:asaancare/features/auth/domain/exceptions/auth_exception.dart';
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
          if (request.url.path == ApiEndpoints.authLogin) {
            expect(request.method, 'POST');
            expect(request.headers['Authorization'], isNull);
            expect(jsonDecode(request.body), {
              'email': 'patient@example.com',
              'password': 'safe-test-password',
            });
            return http.Response(
              jsonEncode({
                'accessToken': 'access-token-123',
                'refreshToken': 'refresh-token-456',
                'user': _userJson,
              }),
              200,
            );
          }
          if (request.url.path == ApiEndpoints.usersMe) {
            expect(request.headers['Authorization'], 'Bearer access-token-123');
            return http.Response(jsonEncode({'user': _userJson}), 200);
          }
          throw UnimplementedError('Unexpected path: ${request.url.path}');
        },
      );

      final user = await dataSource.login(
        emailOrPhone: 'patient@example.com',
        password: 'safe-test-password',
      );

      expect(user.id, 'patient-001');
      expect(user.role, UserRole.patient);
      expect(tokenStore.token, 'access-token-123');
      expect(tokenStore.writeCount, 1);
    });

    test('a new datasource instance restores the persisted session', () async {
      final tokenStore = _FakeAuthTokenStore(token: 'persisted-token');
      final dataSource = _dataSource(
        tokenStore: tokenStore,
        handler: (request) async {
          if (request.url.path == ApiEndpoints.usersMe) {
            expect(request.method, 'GET');
            expect(request.headers['Authorization'], 'Bearer persisted-token');
            return http.Response(jsonEncode({'user': _userJson}), 200);
          }
          throw UnimplementedError('Unexpected path: ${request.url.path}');
        },
      );

      final user = await dataSource.getCurrentUser();

      expect(user?.id, 'patient-001');
      expect(tokenStore.readCount, 1);
    });

    test('registration uses the patient auth contract and logs in', () async {
      final tokenStore = _FakeAuthTokenStore();
      final dataSource = _dataSource(
        tokenStore: tokenStore,
        handler: (request) async {
          if (request.url.path == ApiEndpoints.authRegister) {
            expect(request.method, 'POST');
            expect(request.headers['Authorization'], isNull);
            expect(jsonDecode(request.body), {
              'fullName': 'Ayesha Noor',
              'email': 'ayesha@example.com',
              'password': 'safe-test-password',
              'role': 'PATIENT',
            });
            return http.Response(jsonEncode({'user': _userJson}), 201);
          }
          if (request.url.path == ApiEndpoints.authLogin) {
            return http.Response(
              jsonEncode({
                'accessToken': 'access-token-123',
                'refreshToken': 'refresh-token-456',
                'user': _userJson,
              }),
              200,
            );
          }
          if (request.url.path == ApiEndpoints.usersMe) {
            return http.Response(jsonEncode({'user': _userJson}), 200);
          }
          throw UnimplementedError('Unexpected path: ${request.url.path}');
        },
      );

      final user = await dataSource.registerPatient(
        fullName: 'Ayesha Noor',
        emailOrPhone: 'ayesha@example.com',
        password: 'safe-test-password',
      );

      expect(user.id, 'patient-001');
    });

    test('login rejects a success response without an access token', () async {
      final tokenStore = _FakeAuthTokenStore();
      final dataSource = _dataSource(
        tokenStore: tokenStore,
        handler: (request) async {
          if (request.url.path == ApiEndpoints.authLogin) {
            return http.Response(
              jsonEncode({'accessToken': null, 'user': _userJson}),
              200,
            );
          }
          throw UnimplementedError('Unexpected path: ${request.url.path}');
        },
      );

      await expectLater(
        () => dataSource.login(
          emailOrPhone: 'patient@example.com',
          password: 'safe-test-password',
        ),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            contains('complete token pair'),
          ),
        ),
      );
      expect(tokenStore.writeCount, 0);
      expect(tokenStore.clearCount, greaterThanOrEqualTo(1));
    });

    test('logout clears stored tokens and current user state', () async {
      final tokenStore = _FakeAuthTokenStore(token: 'existing-token');
      final dataSource = _dataSource(
        tokenStore: tokenStore,
        handler: (request) async {
          if (request.url.path == ApiEndpoints.authLogout) {
            expect(request.method, 'POST');
            expect(request.headers['Authorization'], 'Bearer existing-token');
            return http.Response('', 204);
          }
          throw UnimplementedError('Unexpected path: ${request.url.path}');
        },
      );

      await dataSource.logout();

      expect(tokenStore.token, isNull);
      expect(tokenStore.clearCount, greaterThanOrEqualTo(1));
    });

    test(
      'logout clears tokens locally even when the remote call fails',
      () async {
        final tokenStore = _FakeAuthTokenStore(token: 'existing-token');
        final dataSource = _dataSource(
          tokenStore: tokenStore,
          handler: (request) async {
            throw const SocketException('offline');
          },
        );

        await dataSource.logout();

        expect(tokenStore.token, isNull);
        expect(tokenStore.clearCount, greaterThanOrEqualTo(1));
      },
    );
  });
}

const _userJson = <String, dynamic>{
  'id': 'patient-001',
  'email': 'patient@example.com',
  'fullName': 'Ayesha Noor',
  'role': 'PATIENT',
  'status': 'ACTIVE',
  'isVerified': true,
};

AuthRemoteDataSource _dataSource({
  required AuthTokenStore tokenStore,
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

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> writeRefreshToken(String token) async {}

  @override
  Future<void> clearRefreshToken() async {}
}
