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
    if (useMockApi) return;

    final uri = Uri.tryParse(apiBaseUrl.trim());
    final validScheme = uri?.scheme == 'https' || uri?.scheme == 'http';

    if (uri == null || !uri.hasAuthority || !validScheme) {
      throw StateError(
        'Remote API mode requires an absolute API_BASE_URL using HTTPS or HTTP.',
      );
    }

    if (requestTimeoutSeconds < 5 || requestTimeoutSeconds > 120) {
      throw StateError(
        'API_TIMEOUT_SECONDS must be between 5 and 120 seconds.',
      );
    }
  }
}
