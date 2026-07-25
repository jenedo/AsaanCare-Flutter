import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/features/clinical_prescriptions/data/repositories/mock_clinical_prescription_repository.dart';
import 'package:asaancare/features/clinical_prescriptions/presentation/controllers/clinical_prescriptions_controller.dart';
import 'package:asaancare/features/clinical_prescriptions/presentation/screens/clinical_prescriptions_screen.dart';

void main() {
  testWidgets(
    'renders clinical prescriptions screen with ISSUED chip and details modal',
    (tester) async {
      final repository = MockClinicalPrescriptionRepository();
      final controller = ClinicalPrescriptionsController(
        repository: repository,
      );

      await tester.pumpWidget(
        MaterialApp(home: ClinicalPrescriptionsScreen(controller: controller)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Clinical Prescriptions'), findsOneWidget);
      expect(find.text('Dr. Ali Raza'), findsOneWidget);
      expect(find.text('ISSUED'), findsOneWidget);

      // Verify no delete or edit buttons exist on the screen
      expect(find.text('Delete'), findsNothing);
      expect(find.text('Edit'), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.byIcon(Icons.edit), findsNothing);

      // Tap View Details button
      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();

      expect(find.text('Prescribed Medicines'), findsOneWidget);
      expect(find.text('Panadol Extra'), findsOneWidget);
      expect(find.text('Drink plenty of water and rest.'), findsOneWidget);
    },
  );
}
