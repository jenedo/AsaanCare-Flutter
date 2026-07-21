import 'package:asaancare/doctor/screens/auth/doctor_sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Create Account invokes the registration callback', (
    tester,
  ) async {
    var invocationCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DoctorCreateAccountPrompt(onPressed: () => invocationCount++),
        ),
      ),
    );

    await tester.tap(find.text('Create Account'));

    expect(invocationCount, 1);
  });
}
