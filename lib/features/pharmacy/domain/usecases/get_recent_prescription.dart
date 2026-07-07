import '../entities/prescription_order.dart';
import '../repositories/pharmacy_repository.dart';

class GetRecentPrescription {
  const GetRecentPrescription(this._repository);

  final PharmacyRepository _repository;

  Future<PrescriptionOrder> call() {
    return _repository.getRecentPrescription();
  }
}
