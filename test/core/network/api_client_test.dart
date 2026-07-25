import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/core/network/api_exception.dart';

void main() {
  const baseUrl = 'https://api.asaancare.test/api';

  group('ApiClient Array & Object Parsing Regression Suite', () {
    test('parses doctor list response correctly from raw JSON array', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {
              'id': 'doc-1',
              'fullName': 'Dr. Sara Ahmed',
              'specialty': 'General Physician',
              'consultationFee': 1500,
            },
          ]),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final response = await apiClient.getJson('/v1/doctors');
      final list = response['data'] as List;
      expect(list.length, 1);
      expect(list.first['id'], 'doc-1');
      expect(list.first['fullName'], 'Dr. Sara Ahmed');
    });

    test(
      'parses appointment list response correctly from raw JSON array',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode([
              {
                'id': 'appt-1',
                'patientProfileId': 'pat-1',
                'doctorProfileId': 'doc-1',
                'status': 'CONFIRMED',
                'consultationType': 'VIDEO',
                'slotStart': '2026-07-25T14:00:00.000Z',
              },
            ]),
            200,
          );
        });

        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: baseUrl,
          timeout: const Duration(seconds: 5),
        );

        final response = await apiClient.getJson('/v1/appointments');
        final list = response['data'] as List;
        expect(list.length, 1);
        expect(list.first['id'], 'appt-1');
        expect(list.first['status'], 'CONFIRMED');
      },
    );

    test('parses single object response unchanged', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'id': 'doc-1', 'fullName': 'Dr. Sara Ahmed'}),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final result = await apiClient.getJson('/v1/doctors/doc-1');
      expect(result['id'], 'doc-1');
      expect(result['fullName'], 'Dr. Sara Ahmed');
    });

    test('parses backend error objects correctly', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'statusCode': 400, 'message': 'Invalid query parameter'}),
          400,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      expect(
        () => apiClient.getJson('/v1/invalid'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', contains('Invalid query')),
        ),
      );
    });

    test('parses empty array response as empty data wrapper', () async {
      final mockClient = MockClient((request) async {
        return http.Response('[]', 200);
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final result = await apiClient.getJson('/v1/empty');
      expect(result['data'], isA<List>());
      expect((result['data'] as List).isEmpty, isTrue);
    });

    test('fails on malformed non-JSON primitive response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('PLAIN_TEXT_NOT_JSON', 200);
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      expect(
        () => apiClient.getJson('/v1/malformed'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('invalid JSON'),
          ),
        ),
      );
    });
  });
}
