import 'package:asaancare/core/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('401 is unauthorized but not forbidden', () {
    const error = ApiException('Unauthorized', statusCode: 401);

    expect(error.isUnauthorized, isTrue);
    expect(error.isForbidden, isFalse);
  });

  test('403 is forbidden but not unauthorized', () {
    const error = ApiException('Forbidden', statusCode: 403);

    expect(error.isUnauthorized, isFalse);
    expect(error.isForbidden, isTrue);
  });
}
