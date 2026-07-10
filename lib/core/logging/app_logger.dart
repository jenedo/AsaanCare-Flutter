import 'package:flutter/foundation.dart';

typedef AppErrorReporter = void Function(FlutterErrorDetails details);

abstract final class AppLogger {
  const AppLogger._();

  static AppErrorReporter _errorReporter = FlutterError.reportError;

  static void info(String scope, String message) {
    if (!kDebugMode) return;
    debugPrint('[${_redact(scope)}] ${_redact(message)}');
  }

  static void error(String scope, Object error, StackTrace stackTrace) {
    final redactedScope = _redact(scope);
    final redactedError = _redact(error.toString());
    final redactedStack = StackTrace.fromString(_redact(stackTrace.toString()));

    if (kDebugMode) {
      debugPrint('[$redactedScope] $redactedError');
      debugPrintStack(stackTrace: redactedStack);
    }

    _errorReporter(
      FlutterErrorDetails(
        exception: _RedactedAppError(redactedError),
        stack: redactedStack,
        library: 'AsaanCare',
        context: ErrorDescription(redactedScope),
        silent: true,
      ),
    );
  }

  @visibleForTesting
  static void setErrorReporter(AppErrorReporter reporter) {
    _errorReporter = reporter;
  }

  @visibleForTesting
  static void resetErrorReporter() {
    _errorReporter = FlutterError.reportError;
  }

  static String _redact(String value) {
    var output = value;

    output = output.replaceAll(
      RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false),
      'Bearer [REDACTED]',
    );

    output = output.replaceAllMapped(
      RegExp(
        r'\b(password|passcode|token|authorization|api[-_ ]?key|secret)\b'
        r'\s*[:=]\s*([^\s,;]+)',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}=[REDACTED]',
    );

    output = output.replaceAll(
      RegExp(r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}', caseSensitive: false),
      '[REDACTED_EMAIL]',
    );

    output = output.replaceAll(
      RegExp(r'\+?\d[\d\s-]{8,}\d'),
      '[REDACTED_PHONE]',
    );

    return output;
  }
}

class _RedactedAppError implements Exception {
  const _RedactedAppError(this.message);

  final String message;

  @override
  String toString() => message;
}
