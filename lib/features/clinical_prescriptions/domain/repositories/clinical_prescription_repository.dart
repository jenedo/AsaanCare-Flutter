import '../entities/clinical_prescription.dart';

abstract class ClinicalPrescriptionRepository {
  Future<List<ClinicalPrescription>> getClinicalPrescriptions();

  Future<ClinicalPrescription> getClinicalPrescription(String id);
}
