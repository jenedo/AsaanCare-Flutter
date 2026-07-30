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

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
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

  static void validateSupabaseConfiguration() {
    validateSupabaseConfigurationValues(
      useMockApi: useMockApi,
      supabaseUrl: supabaseUrl,
      supabasePublishableKey: supabasePublishableKey,
    );
  }

  @visibleForTesting
  static void validateSupabaseConfigurationValues({
    required bool useMockApi,
    required String supabaseUrl,
    required String supabasePublishableKey,
  }) {
    if (useMockApi) return;

    if (supabaseUrl.trim().isEmpty) {
      throw StateError('Remote auth mode requires SUPABASE_URL.');
    }

    if (supabasePublishableKey.trim().isEmpty) {
      throw StateError('Remote auth mode requires SUPABASE_PUBLISHABLE_KEY.');
    }
  }

  static void validate() {
    validateSupabaseConfiguration();
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

    validateRemoteApiUrl(apiBaseUrl, allowInsecureLocalApi: allowLocalHttp);

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

    if (!uri.path.endsWith('/api') && !uri.path.contains('/api/')) {
      throw StateError(
        'API_BASE_URL must include the /api prefix (e.g. https://domain.com/api).',
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
