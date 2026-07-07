import '../entities/medicine.dart';
import '../entities/prescription_order.dart';

abstract class PharmacyRepository {
  Future<List<Medicine>> getPopularMedicines();

  Future<PrescriptionOrder> getRecentPrescription();
}
