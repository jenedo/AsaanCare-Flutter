import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/core/di/service_locator.dart';
import 'package:asaancare/features/clinical_prescriptions/data/repositories/clinical_prescription_repository_impl.dart';
import 'package:asaancare/features/clinical_prescriptions/data/repositories/mock_clinical_prescription_repository.dart';
import 'package:asaancare/features/clinical_prescriptions/domain/repositories/clinical_prescription_repository.dart';
import 'package:asaancare/features/medical_records/data/repositories/medical_records_repository_impl.dart';
import 'package:asaancare/features/medical_records/data/repositories/mock_medical_records_repository.dart';
import 'package:asaancare/features/medical_records/domain/repositories/medical_records_repository.dart';

void main() {
  setUp(() async {
    await sl.reset();
  });

  tearDown(() async {
    await sl.reset();
  });

  test('registers mock repositories when isMockApi is true', () async {
    await setupServiceLocator(isMockApi: true);

    expect(sl.isRegistered<ClinicalPrescriptionRepository>(), isTrue);
    expect(
      sl<ClinicalPrescriptionRepository>(),
      isA<MockClinicalPrescriptionRepository>(),
    );

    expect(sl.isRegistered<MedicalRecordsRepository>(), isTrue);
    expect(sl<MedicalRecordsRepository>(), isA<MockMedicalRecordsRepository>());
  });

  test('registers real remote repositories when isMockApi is false', () async {
    await setupServiceLocator(isMockApi: false);

    expect(sl.isRegistered<ClinicalPrescriptionRepository>(), isTrue);
    expect(
      sl<ClinicalPrescriptionRepository>(),
      isA<ClinicalPrescriptionRepositoryImpl>(),
    );

    expect(sl.isRegistered<MedicalRecordsRepository>(), isTrue);
    expect(sl<MedicalRecordsRepository>(), isA<MedicalRecordsRepositoryImpl>());
  });
}
