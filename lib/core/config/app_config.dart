import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  const AppConfig._();

  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: true,
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const int requestTimeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 20,
  );

  static Duration get requestTimeout =>
      Duration(seconds: requestTimeoutSeconds);

  static void validate() {
    validateValues(
      useMockApi: useMockApi,
      apiBaseUrl: apiBaseUrl,
      requestTimeoutSeconds: requestTimeoutSeconds,
      allowLocalHttp: kDebugMode,
    );
  }

  @visibleForTesting
  static void validateValues({
    required bool useMockApi,
    required String apiBaseUrl,
    required int requestTimeoutSeconds,
    required bool allowLocalHttp,
  }) {
    if (useMockApi) return;

    final uri = Uri.tryParse(apiBaseUrl.trim());
    final isHttps = uri?.scheme == 'https';
    final isAllowedLocalHttp =
        allowLocalHttp &&
        uri?.scheme == 'http' &&
        const {'localhost', '127.0.0.1', '10.0.2.2'}.contains(uri?.host);

    if (uri == null || !uri.hasAuthority || (!isHttps && !isAllowedLocalHttp)) {
      throw StateError(
        'Remote API mode requires HTTPS. Plain HTTP is allowed only for local debug hosts.',
      );
    }

    if (requestTimeoutSeconds < 5 || requestTimeoutSeconds > 120) {
      throw StateError(
        'API_TIMEOUT_SECONDS must be between 5 and 120 seconds.',
      );
    }
  }
}
