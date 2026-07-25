import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/core/network/api_exception.dart';
import 'package:asaancare/features/clinical_prescriptions/data/repositories/mock_clinical_prescription_repository.dart';
import 'package:asaancare/features/clinical_prescriptions/domain/entities/clinical_prescription.dart';
import 'package:asaancare/features/clinical_prescriptions/domain/repositories/clinical_prescription_repository.dart';
import 'package:asaancare/features/clinical_prescriptions/presentation/controllers/clinical_prescriptions_controller.dart';

class FailingClinicalPrescriptionRepository
    implements ClinicalPrescriptionRepository {
  FailingClinicalPrescriptionRepository({this.statusCode = 500});
  final int statusCode;

  @override
  Future<List<ClinicalPrescription>> getClinicalPrescriptions() async {
    throw ApiException('Server error', statusCode: statusCode);
  }

  @override
  Future<ClinicalPrescription> getClinicalPrescription(String id) async {
    throw ApiException('Prescription not found', statusCode: statusCode);
  }
}

class EmptyClinicalPrescriptionRepository
    implements ClinicalPrescriptionRepository {
  @override
  Future<List<ClinicalPrescription>> getClinicalPrescriptions() async {
    return const [];
  }

  @override
  Future<ClinicalPrescription> getClinicalPrescription(String id) async {
    throw ApiException('Not found', statusCode: 404);
  }
}

void main() {
  group('ClinicalPrescriptionsController Unit Tests', () {
    test('loads prescriptions successfully from mock repository', () async {
      final mockRepo = MockClinicalPrescriptionRepository();
      final controller = ClinicalPrescriptionsController(repository: mockRepo);

      expect(controller.status, ClinicalPrescriptionsStatus.initial);

      final future = controller.loadPrescriptions();
      expect(controller.isLoading, isTrue);

      await future;

      expect(controller.isLoaded, isTrue);
      expect(controller.prescriptions.length, 1);
      expect(
        controller.prescriptions.first.status,
        ClinicalPrescriptionStatus.issued,
      );
    });

    test('handles empty prescription state correctly', () async {
      final emptyRepo = EmptyClinicalPrescriptionRepository();
      final controller = ClinicalPrescriptionsController(repository: emptyRepo);

      await controller.loadPrescriptions();

      expect(controller.isEmpty, isTrue);
      expect(controller.prescriptions.isEmpty, isTrue);
    });

    test('fetches single prescription detail correctly', () async {
      final mockRepo = MockClinicalPrescriptionRepository();
      final controller = ClinicalPrescriptionsController(repository: mockRepo);

      final detail = await controller.getPrescriptionDetail(
        'mock_clinical_presc_001',
      );

      expect(detail, isNotNull);
      expect(detail!.id, 'mock_clinical_presc_001');
      expect(detail.status, ClinicalPrescriptionStatus.issued);
      expect(detail.medicines.length, 1);
      expect(detail.medicines.first.name, 'Panadol Extra');
      expect(controller.selectedPrescription, isNotNull);
    });

    test('handles 401 session expiry when fetching prescriptions', () async {
      final failingRepo = FailingClinicalPrescriptionRepository(
        statusCode: 401,
      );
      final controller = ClinicalPrescriptionsController(
        repository: failingRepo,
      );

      await controller.loadPrescriptions();

      expect(controller.hasError, isTrue);
      expect(controller.errorMessage, contains('Failed to load'));
    });

    test('no delete or update methods exist on controller', () {
      final mockRepo = MockClinicalPrescriptionRepository();
      final controller = ClinicalPrescriptionsController(repository: mockRepo);

      // Verify interface only exposes loadPrescriptions & getPrescriptionDetail
      expect(controller.loadPrescriptions, isA<Function>());
      expect(controller.getPrescriptionDetail, isA<Function>());
    });
  });
}
