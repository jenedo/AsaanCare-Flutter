import 'package:asaancare/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig.validateValues', () {
    test('mock mode skips remote endpoint and timeout validation', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: true,
          apiBaseUrl: '',
          requestTimeoutSeconds: 0,
          allowLocalHttp: false,
        ),
        returnsNormally,
      );
    });

    test('accepts an HTTPS remote endpoint', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'https://api.asaancare.example',
          requestTimeoutSeconds: 20,
          allowLocalHttp: false,
        ),
        returnsNormally,
      );
    });

    test('rejects a public plain HTTP endpoint', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'http://api.asaancare.example',
          requestTimeoutSeconds: 20,
          allowLocalHttp: true,
        ),
        throwsStateError,
      );
    });

    test('allows local HTTP hosts when enabled', () {
      for (final host in ['localhost', '127.0.0.1', '10.0.2.2']) {
        expect(
          () => AppConfig.validateValues(
            useMockApi: false,
            apiBaseUrl: 'http://$host:3000',
            requestTimeoutSeconds: 20,
            allowLocalHttp: true,
          ),
          returnsNormally,
        );
      }
    });

    test('rejects local HTTP when the local override is disabled', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'http://localhost:3000',
          requestTimeoutSeconds: 20,
          allowLocalHttp: false,
        ),
        throwsStateError,
      );
    });

    test('rejects an empty remote URL', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: '',
          requestTimeoutSeconds: 20,
          allowLocalHttp: false,
        ),
        throwsStateError,
      );
    });

    test('rejects a timeout below the supported range', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'https://api.asaancare.example',
          requestTimeoutSeconds: 4,
          allowLocalHttp: false,
        ),
        throwsStateError,
      );
    });

    test('rejects a timeout above the supported range', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'https://api.asaancare.example',
          requestTimeoutSeconds: 121,
          allowLocalHttp: false,
        ),
        throwsStateError,
      );
    });
  });

  group('AppConfig.validateRemoteApiUrl', () {
    test('accepts an absolute HTTPS URL', () {
      expect(
        () => AppConfig.validateRemoteApiUrl('https://api.asaancare.example'),
        returnsNormally,
      );
    });

    test('rejects cleartext HTTP by default', () {
      expect(
        () => AppConfig.validateRemoteApiUrl('http://localhost:8080'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('requires HTTPS'),
          ),
        ),
      );
    });

    test('allows private-network HTTP only with the explicit override', () {
      expect(
        () => AppConfig.validateRemoteApiUrl(
          'http://192.168.1.10:8080',
          allowInsecureLocalApi: true,
        ),
        returnsNormally,
      );
    });

    test('does not allow public HTTP with the local override', () {
      expect(
        () => AppConfig.validateRemoteApiUrl(
          'http://example.com',
          allowInsecureLocalApi: true,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects relative URLs', () {
      expect(
        () => AppConfig.validateRemoteApiUrl('/api'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
