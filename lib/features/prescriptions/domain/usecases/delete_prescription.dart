import '../repositories/prescription_repository.dart';

class DeletePrescription {
  const DeletePrescription(this._repository);

  final PrescriptionRepository _repository;

  Future<void> call({
    required String patientId,
    required String prescriptionId,
  }) {
    final trimmedPatientId = patientId.trim();
    final trimmedPrescriptionId = prescriptionId.trim();

    if (trimmedPatientId.isEmpty) {
      throw ArgumentError('patientId cannot be empty.');
    }

    if (trimmedPrescriptionId.isEmpty) {
      throw ArgumentError('prescriptionId cannot be empty.');
    }

    return _repository.deletePrescription(
      patientId: trimmedPatientId,
      prescriptionId: trimmedPrescriptionId,
    );
  }
}
