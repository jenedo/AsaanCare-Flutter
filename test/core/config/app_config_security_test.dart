import 'package:asaancare/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig.validateSupabaseConfigurationValues', () {
    test('mock mode does not require Supabase configuration', () {
      expect(
        () => AppConfig.validateSupabaseConfigurationValues(
          useMockApi: true,
          supabaseUrl: '',
          supabasePublishableKey: '',
        ),
        returnsNormally,
      );
    });

    test('remote mode rejects a missing Supabase URL', () {
      expect(
        () => AppConfig.validateSupabaseConfigurationValues(
          useMockApi: false,
          supabaseUrl: '',
          supabasePublishableKey: 'publishable-key',
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('SUPABASE_URL'),
          ),
        ),
      );
    });

    test('remote mode rejects a missing Supabase publishable key', () {
      expect(
        () => AppConfig.validateSupabaseConfigurationValues(
          useMockApi: false,
          supabaseUrl: 'https://project-ref.supabase.co',
          supabasePublishableKey: '   ',
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('SUPABASE_PUBLISHABLE_KEY'),
          ),
        ),
      );
    });

    test('remote mode accepts complete Supabase configuration', () {
      expect(
        () => AppConfig.validateSupabaseConfigurationValues(
          useMockApi: false,
          supabaseUrl: 'https://project-ref.supabase.co',
          supabasePublishableKey: 'publishable-key',
        ),
        returnsNormally,
      );
    });
  });
}
