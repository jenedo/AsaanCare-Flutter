import '../entities/prescription_record.dart';
import '../repositories/prescription_repository.dart';

class GetPrescriptions {
  const GetPrescriptions(this._repository);

  final PrescriptionRepository _repository;

  Future<List<PrescriptionRecord>> call({required String patientId}) {
    final trimmedPatientId = patientId.trim();

    if (trimmedPatientId.isEmpty) {
      throw ArgumentError('patientId cannot be empty.');
    }

    return _repository.getPrescriptions(patientId: trimmedPatientId);
  }
}
