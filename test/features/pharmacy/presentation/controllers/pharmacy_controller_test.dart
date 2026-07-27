import 'dart:async';

import 'package:asaancare/features/pharmacy/domain/entities/medicine.dart';
import 'package:asaancare/features/pharmacy/domain/entities/prescription_order.dart';
import 'package:asaancare/features/pharmacy/domain/repositories/pharmacy_repository.dart';
import 'package:asaancare/features/pharmacy/domain/usecases/get_popular_medicines.dart';
import 'package:asaancare/features/pharmacy/domain/usecases/get_recent_prescription.dart';
import 'package:asaancare/features/pharmacy/presentation/controllers/pharmacy_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PharmacyController prescription validation', () {
    test(
      'rejects checkout when prescription misses a required medicine',
      () async {
        final medicines = [
          _medicine(id: 'required-a', prescriptionRequired: true),
          _medicine(id: 'required-b', prescriptionRequired: true),
        ];
        final repository = _FakePharmacyRepository(
          medicines: medicines,
          prescription: _prescription(['required-a']),
        );
        final controller = _controller(repository);
        addTearDown(controller.dispose);

        await controller.load();
        controller
          ..addToCart(medicines[0])
          ..addToCart(medicines[1]);

        expect(
          controller.checkoutValidationError,
          contains('does not cover every required medicine'),
        );
        expect(controller.canCheckout, isFalse);
      },
    );

    test(
      'allows prescription validation when every required medicine is covered',
      () async {
        final medicines = [
          _medicine(id: 'required-a', prescriptionRequired: true),
          _medicine(id: 'required-b', prescriptionRequired: true),
        ];
        final repository = _FakePharmacyRepository(
          medicines: medicines,
          prescription: _prescription(['required-a', 'required-b']),
        );
        final controller = _controller(repository);
        addTearDown(controller.dispose);

        await controller.load();
        controller
          ..addToCart(medicines[0])
          ..addToCart(medicines[1]);

        expect(controller.checkoutValidationError, isNull);
        expect(controller.canCheckout, isTrue);
      },
    );
  });

  test(
    'load completion does not notify after the controller is disposed',
    () async {
      final medicinesCompleter = Completer<List<Medicine>>();
      final prescriptionCompleter = Completer<PrescriptionOrder>();
      final repository = _DeferredPharmacyRepository(
        medicinesCompleter: medicinesCompleter,
        prescriptionCompleter: prescriptionCompleter,
      );
      final controller = _controller(repository);

      final loadFuture = controller.load();
      controller.dispose();

      medicinesCompleter.complete(const []);
      prescriptionCompleter.complete(_prescription(const []));

      await expectLater(loadFuture, completes);
      expect(controller.status, PharmacyStatus.loaded);
    },
  );
}

PharmacyController _controller(PharmacyRepository repository) {
  return PharmacyController(
    GetPopularMedicines(repository),
    GetRecentPrescription(repository),
  );
}

Medicine _medicine({required String id, required bool prescriptionRequired}) {
  return Medicine(
    id: id,
    brandName: id,
    genericName: 'Generic',
    manufacturer: 'AsaanCare',
    category: MedicineCategory.painRelief,
    strength: '500mg',
    dosageForm: 'Tablet',
    packSize: 'Standard Pack',
    price: 100,
    originalPrice: 100,
    stockQuantity: 10,
    prescriptionRequired: prescriptionRequired,
    rating: 4.5,
    reviewCount: 10,
    description: 'Test medicine',
    productCode: id.toUpperCase(),
  );
}

PrescriptionOrder _prescription(List<String> medicineIds) {
  return PrescriptionOrder(
    id: 'prescription-test',
    title: 'Test prescription',
    uploadedDate: 'Today',
    isVerified: true,
    imageAsset: 'assets/images/prescription_paper.png',
    medicineIds: medicineIds,
  );
}

class _FakePharmacyRepository implements PharmacyRepository {
  const _FakePharmacyRepository({
    required this.medicines,
    required this.prescription,
  });

  final List<Medicine> medicines;
  final PrescriptionOrder prescription;

  @override
  Future<List<Medicine>> getPopularMedicines() async => medicines;

  @override
  Future<PrescriptionOrder> getRecentPrescription() async => prescription;
}

class _DeferredPharmacyRepository implements PharmacyRepository {
  const _DeferredPharmacyRepository({
    required this.medicinesCompleter,
    required this.prescriptionCompleter,
  });

  final Completer<List<Medicine>> medicinesCompleter;
  final Completer<PrescriptionOrder> prescriptionCompleter;

  @override
  Future<List<Medicine>> getPopularMedicines() => medicinesCompleter.future;

  @override
  Future<PrescriptionOrder> getRecentPrescription() =>
      prescriptionCompleter.future;
}
