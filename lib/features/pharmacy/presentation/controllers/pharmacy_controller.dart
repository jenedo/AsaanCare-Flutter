import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../domain/entities/medicine.dart';
import '../../domain/entities/prescription_order.dart';
import '../../domain/usecases/get_popular_medicines.dart';
import '../../domain/usecases/get_recent_prescription.dart';

enum PharmacyStatus { initial, loading, loaded, error }

class PharmacyController extends ChangeNotifier {
  PharmacyController({
    required this._getPopularMedicines,
    required this._getRecentPrescription,
  });

  final GetPopularMedicines _getPopularMedicines;
  final GetRecentPrescription _getRecentPrescription;

  UnmodifiableListView<Medicine> _popularMedicines =
      UnmodifiableListView<Medicine>(const []);

  PrescriptionOrder? _recentPrescription;
  PharmacyStatus _status = PharmacyStatus.initial;
  String? _errorMessage;
  bool _isDisposed = false;

  UnmodifiableListView<Medicine> get popularMedicines => _popularMedicines;
  PrescriptionOrder? get recentPrescription => _recentPrescription;
  PharmacyStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isInitial => _status == PharmacyStatus.initial;
  bool get isLoading => _status == PharmacyStatus.loading;
  bool get isLoaded => _status == PharmacyStatus.loaded;
  bool get hasError => _status == PharmacyStatus.error;

  bool get hasData =>
      _popularMedicines.isNotEmpty || _recentPrescription != null;

  bool get isEmpty =>
      _status == PharmacyStatus.loaded &&
      _popularMedicines.isEmpty &&
      _recentPrescription == null;

  Future<void> load({bool forceRefresh = false}) async {
    if (_status == PharmacyStatus.loading) return;

    if (!forceRefresh && _status == PharmacyStatus.loaded) {
      return;
    }

    _setStatus(PharmacyStatus.loading, errorMessage: null);

    try {
      final medicinesFuture = _getPopularMedicines();
      final prescriptionFuture = _getRecentPrescription();

      final medicines = await medicinesFuture;
      final prescription = await prescriptionFuture;

      if (_isDisposed) return;

      _popularMedicines = UnmodifiableListView<Medicine>(medicines);
      _recentPrescription = prescription;

      _setStatus(PharmacyStatus.loaded, errorMessage: null);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('PharmacyController.load failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      if (_isDisposed) return;

      _setStatus(
        PharmacyStatus.error,
        errorMessage: 'Failed to load pharmacy data. Please try again.',
      );
    }
  }

  Future<void> refresh() {
    return load(forceRefresh: true);
  }

  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;
    _safeNotifyListeners();
  }

  void _setStatus(PharmacyStatus status, {required String? errorMessage}) {
    _status = status;
    _errorMessage = errorMessage;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
