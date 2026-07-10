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

  static const bool allowInsecureLocalApi = bool.fromEnvironment(
    'ALLOW_INSECURE_LOCAL_API',
    defaultValue: false,
  );

  static const int requestTimeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 20,
  );

  static Duration get requestTimeout =>
      Duration(seconds: requestTimeoutSeconds);

  static void validate() {
    if (useMockApi) return;

    validateRemoteApiUrl(
      apiBaseUrl,
      allowInsecureLocalApi: allowInsecureLocalApi,
    );

    if (requestTimeoutSeconds < 5 || requestTimeoutSeconds > 120) {
      throw StateError(
        'API_TIMEOUT_SECONDS must be between 5 and 120 seconds.',
      );
    }
  }

  static void validateRemoteApiUrl(
    String value, {
    bool allowInsecureLocalApi = false,
  }) {
    final uri = Uri.tryParse(value.trim());

    if (uri == null || !uri.hasAuthority) {
      throw StateError(
        'Remote API mode requires an absolute HTTPS API_BASE_URL.',
      );
    }

    if (uri.scheme == 'https') return;

    final localHttpAllowed =
        uri.scheme == 'http' &&
        allowInsecureLocalApi &&
        _isLocalDevelopmentHost(uri.host);

    if (localHttpAllowed) return;

    throw StateError(
      'Remote API mode requires HTTPS because bearer tokens are sent. '
      'Cleartext HTTP is allowed only for localhost or private-network '
      'development when ALLOW_INSECURE_LOCAL_API=true.',
    );
  }

  static bool _isLocalDevelopmentHost(String host) {
    final normalized = host.trim().toLowerCase();

    if (normalized == 'localhost' ||
        normalized == '::1' ||
        normalized.startsWith('127.')) {
      return true;
    }

    final octets = normalized.split('.');
    if (octets.length != 4) return false;

    final values = octets.map(int.tryParse).toList(growable: false);
    if (values.any((value) => value == null || value < 0 || value > 255)) {
      return false;
    }

    final first = values[0]!;
    final second = values[1]!;

    return first == 10 ||
        (first == 172 && second >= 16 && second <= 31) ||
        (first == 192 && second == 168);
  }
}
