import 'package:asaancare/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

    test('allows local HTTP only with the explicit override', () {
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
