import 'package:asaancare/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(AppLogger.resetErrorReporter);

  test('forwards redacted errors to the configured reporter', () {
    FlutterErrorDetails? reported;

    AppLogger.setErrorReporter((details) {
      reported = details;
    });

    AppLogger.error(
      'ApiClient.POST /auth/login',
      StateError(
        'password=secret email=user@example.com '
        'Authorization: Bearer abc.def.ghi',
      ),
      StackTrace.fromString('token=raw-token phone=03001234567'),
    );

    expect(reported, isNotNull);

    final details = reported!;
    final rendered =
        '${details.exceptionAsString()}\n'
        '${details.stack}\n'
        '${details.context}';

    expect(rendered, contains('ApiClient.POST /auth/login'));
    expect(rendered, contains('[REDACTED]'));
    expect(rendered, isNot(contains('secret')));
    expect(rendered, isNot(contains('user@example.com')));
    expect(rendered, isNot(contains('abc.def.ghi')));
    expect(rendered, isNot(contains('03001234567')));
  });
}
