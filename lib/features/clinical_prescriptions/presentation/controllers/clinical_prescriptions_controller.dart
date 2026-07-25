// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/clinical_prescription.dart';
import '../../domain/repositories/clinical_prescription_repository.dart';

enum ClinicalPrescriptionsStatus { initial, loading, loaded, empty, error }

class ClinicalPrescriptionsController extends ChangeNotifier {
  ClinicalPrescriptionsController({
    required ClinicalPrescriptionRepository repository,
  }) : _repository = repository;

  final ClinicalPrescriptionRepository _repository;

  UnmodifiableListView<ClinicalPrescription> _prescriptions =
      UnmodifiableListView<ClinicalPrescription>(const []);
  ClinicalPrescriptionsStatus _status = ClinicalPrescriptionsStatus.initial;
  ClinicalPrescription? _selectedPrescription;
  String? _errorMessage;
  bool _isDisposed = false;

  UnmodifiableListView<ClinicalPrescription> get prescriptions =>
      _prescriptions;
  ClinicalPrescriptionsStatus get status => _status;
  ClinicalPrescription? get selectedPrescription => _selectedPrescription;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == ClinicalPrescriptionsStatus.loading;
  bool get isLoaded => _status == ClinicalPrescriptionsStatus.loaded;
  bool get isEmpty => _status == ClinicalPrescriptionsStatus.empty;
  bool get hasError => _status == ClinicalPrescriptionsStatus.error;

  Future<void> loadPrescriptions() async {
    _setStatus(ClinicalPrescriptionsStatus.loading, errorMessage: null);

    try {
      final result = await _repository.getClinicalPrescriptions();
      if (_isDisposed) return;

      _prescriptions = UnmodifiableListView<ClinicalPrescription>(result);
      _setStatus(
        result.isEmpty
            ? ClinicalPrescriptionsStatus.empty
            : ClinicalPrescriptionsStatus.loaded,
        errorMessage: null,
      );
    } catch (error, stackTrace) {
      _debugLog('loadPrescriptions failed', error, stackTrace);
      if (_isDisposed) return;
      _setStatus(
        ClinicalPrescriptionsStatus.error,
        errorMessage: 'Failed to load clinical prescriptions.',
      );
    }
  }

  Future<ClinicalPrescription?> getPrescriptionDetail(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      _setError('Prescription ID is required.');
      return null;
    }

    try {
      final detail = await _repository.getClinicalPrescription(trimmedId);
      if (_isDisposed) return null;
      _selectedPrescription = detail;
      _safeNotifyListeners();
      return detail;
    } catch (error, stackTrace) {
      _debugLog('getPrescriptionDetail failed', error, stackTrace);
      if (_isDisposed) return null;
      _setError('Could not fetch prescription details.');
      return null;
    }
  }

  void _setStatus(
    ClinicalPrescriptionsStatus status, {
    required String? errorMessage,
  }) {
    _status = status;
    _errorMessage = errorMessage;
    _safeNotifyListeners();
  }

  void _setError(String message) {
    _status = ClinicalPrescriptionsStatus.error;
    _errorMessage = message;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  void _debugLog(String message, Object error, StackTrace stackTrace) {
    AppLogger.error(
      'ClinicalPrescriptionsController.$message',
      error,
      stackTrace,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
