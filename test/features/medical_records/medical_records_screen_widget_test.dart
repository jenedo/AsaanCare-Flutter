import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/features/medical_records/data/repositories/mock_medical_records_repository.dart';
import 'package:asaancare/features/medical_records/presentation/controllers/medical_records_controller.dart';
import 'package:asaancare/features/medical_records/presentation/screens/medical_records_screen.dart';

void main() {
  testWidgets(
    'renders medical records screen, shows PASSED record with download button enabled',
    (tester) async {
      final repository = MockMedicalRecordsRepository();
      final controller = MedicalRecordsController(repository: repository);

      await tester.pumpWidget(
        MaterialApp(home: MedicalRecordsScreen(controller: controller)),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Health Records'), findsOneWidget);
      expect(find.text('MEDICALRECORD'), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    },
  );
}
