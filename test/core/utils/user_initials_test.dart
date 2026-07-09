import 'package:asaancare/core/utils/user_initials.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserInitials', () {
    test('uses first and last name initials', () {
      expect(UserInitials.fromName('Sumiya Ibrahim'), 'SI');
    });

    test('supports a single name', () {
      expect(UserInitials.fromName('Fareed'), 'F');
    });

    test('returns fallback for blank values', () {
      expect(UserInitials.fromName('   '), '?');
      expect(UserInitials.fromName(null), '?');
    });
  });
}
