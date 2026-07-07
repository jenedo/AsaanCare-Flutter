import '../entities/medicine.dart';
import '../repositories/pharmacy_repository.dart';

class GetPopularMedicines {
  const GetPopularMedicines(this._repository);

  final PharmacyRepository _repository;

  Future<List<Medicine>> call() {
    return _repository.getPopularMedicines();
  }
}
