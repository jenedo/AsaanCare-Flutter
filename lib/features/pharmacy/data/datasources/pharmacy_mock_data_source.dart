import 'dart:collection';

import '../models/medicine_model.dart';
import '../../domain/entities/prescription_order.dart';

abstract class PharmacyDataSource {
  Future<List<MedicineModel>> getPopularMedicines();
  Future<PrescriptionOrder> getRecentPrescription();
}

class PharmacyMockDataSource implements PharmacyDataSource {
  PharmacyMockDataSource({this.delay = const Duration(milliseconds: 250)});

  final Duration delay;

  static const String _prescriptionAsset =
      'assets/images/prescription_paper.png';

  static const List<MedicineModel> _popularMedicines = [
    MedicineModel(
      id: 'panadol-500mg',
      name: 'Panadol',
      description: '500mg Tablet',
      price: 45,
    ),
    MedicineModel(
      id: 'brufen-400mg',
      name: 'Brufen',
      description: '400mg Tablet',
      price: 65,
    ),
    MedicineModel(
      id: 'volcaron-50g',
      name: 'Volcaron',
      description: 'Emulgel 50g',
      price: 550,
    ),
    MedicineModel(
      id: 'calpol-120ml',
      name: 'Calpol',
      description: 'Syrup 120ml',
      price: 180,
    ),
  ];

  static const PrescriptionOrder _recentPrescription = PrescriptionOrder(
    id: 'pr_12345',
    title: 'Prescription #PR12345',
    uploadedDate: 'Uploaded on 10 May 2024',
    isVerified: true,
    imageAsset: _prescriptionAsset,
  );

  Future<void> _mockNetworkDelay() async {
    await Future<void>.delayed(delay);
  }

  @override
  Future<List<MedicineModel>> getPopularMedicines() async {
    await _mockNetworkDelay();

    return UnmodifiableListView(_popularMedicines);
  }

  @override
  Future<PrescriptionOrder> getRecentPrescription() async {
    await _mockNetworkDelay();

    return _recentPrescription;
  }
}
