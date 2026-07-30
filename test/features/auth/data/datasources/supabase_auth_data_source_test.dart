import 'dart:convert';

import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/core/network/api_exception.dart';
import 'package:asaancare/features/auth/data/datasources/supabase_auth_data_source.dart';
import 'package:asaancare/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  const accessToken = 'verified-supabase-access-token';

  supabase.SupabaseClient createSupabaseClient() {
    return supabase.SupabaseClient(
      'https://project-ref.supabase.co',
      'publishable-key',
      authOptions: const supabase.AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/auth/v1/token');
        expect(request.url.queryParameters['grant_type'], 'password');

        return http.Response(
          jsonEncode({
            'access_token': accessToken,
            'token_type': 'bearer',
            'expires_in': 3600,
            'refresh_token': 'refresh-token',
            'user': {
              'id': 'supabase-user-id',
              'aud': 'authenticated',
              'role': 'authenticated',
              'email': 'doctor@example.com',
              'app_metadata': <String, Object?>{},
              'user_metadata': {
                'full_name': 'Editable Metadata Name',
                'role': 'admin',
              },
              'identities': <Object?>[],
              'created_at': '2026-07-30T00:00:00.000Z',
              'updated_at': '2026-07-30T00:00:00.000Z',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
  }

  test(
    'login uses the authoritative bootstrap role, not user metadata',
    () async {
      late http.Request bootstrapRequest;
      final apiClient = ApiClient(
        client: MockClient((request) async {
          bootstrapRequest = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'user': {
                  'id': 'database-user-id',
                  'email': 'doctor@example.com',
                  'mobile': null,
                  'role': 'DOCTOR',
                  'isActive': true,
                  'doctorProfile': {'fullName': 'Authoritative Doctor'},
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: 'https://api.asaancare.example/api',
        timeout: const Duration(seconds: 5),
      );
      final dataSource = SupabaseAuthDataSource(
        client: createSupabaseClient(),
        apiClient: apiClient,
      );

      final user = await dataSource.login(
        emailOrPhone: 'doctor@example.com',
        password: 'valid-password',
      );

      expect(bootstrapRequest.method, 'POST');
      expect(bootstrapRequest.url.path, '/api/v1/auth/bootstrap');
      expect(bootstrapRequest.headers['authorization'], 'Bearer $accessToken');
      expect(jsonDecode(bootstrapRequest.body), {'role': 'PATIENT'});
      expect(user.id, 'database-user-id');
      expect(user.fullName, 'Authoritative Doctor');
      expect(user.role, UserRole.doctor);
    },
  );

  test(
    'login propagates bootstrap failure without metadata fallback',
    () async {
      final apiClient = ApiClient(
        client: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'success': false,
              'error': {'message': 'Application profile is unavailable'},
            }),
            503,
            headers: {'content-type': 'application/json'},
          ),
        ),
        baseUrl: 'https://api.asaancare.example/api',
        timeout: const Duration(seconds: 5),
      );
      final dataSource = SupabaseAuthDataSource(
        client: createSupabaseClient(),
        apiClient: apiClient,
      );

      await expectLater(
        dataSource.login(
          emailOrPhone: 'doctor@example.com',
          password: 'valid-password',
        ),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 503)
              .having(
                (error) => error.message,
                'message',
                'Application profile is unavailable',
              ),
        ),
      );
    },
  );
}
