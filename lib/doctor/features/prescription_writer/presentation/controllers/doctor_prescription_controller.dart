import 'package:flutter/foundation.dart';

import '../../domain/entities/doctor_prescription_draft_state.dart';
import '../../domain/entities/doctor_written_prescription.dart';
import '../../domain/repositories/doctor_prescription_draft_repository.dart';

class DoctorPrescriptionController extends ChangeNotifier {
  DoctorPrescriptionController({required this._repository});

  final DoctorPrescriptionDraftRepository _repository;

  DoctorPrescriptionDraftState _state = const DoctorPrescriptionDraftState();
  String? _appointmentId;
  bool _isLoaded = false;

  DoctorPrescriptionDraftState get state => _state;
  bool get canSend =>
      _state.diagnosis.trim().isNotEmpty && _state.medicines.isNotEmpty;

  Future<void> load({required String appointmentId}) async {
    final normalizedId = appointmentId.trim();
    if (normalizedId.isEmpty) return;
    if (_isLoaded && _appointmentId == normalizedId) return;
    _appointmentId = normalizedId;
    _state = await _repository.loadDraft(appointmentId: normalizedId);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateDiagnosis(String value) =>
      _save(_state.copyWith(diagnosis: value));
  Future<void> updateChiefComplaint(String value) =>
      _save(_state.copyWith(chiefComplaint: value));
  Future<void> updateDoctorNotes(String value) =>
      _save(_state.copyWith(doctorNotes: value));
  Future<void> toggleSymptom(String value) async {
    final next = [..._state.symptoms];
    next.contains(value) ? next.remove(value) : next.add(value);
    await _save(_state.copyWith(symptoms: next));
  }

  Future<void> toggleLabTest(String value) async {
    final next = [..._state.labTests];
    next.contains(value) ? next.remove(value) : next.add(value);
    await _save(_state.copyWith(labTests: next));
  }

  Future<void> addMedicine(DoctorWrittenPrescription medicine) async {
    await _save(_state.copyWith(medicines: [..._state.medicines, medicine]));
  }

  Future<void> updateMedicine(
    DoctorWrittenPrescription current,
    DoctorWrittenPrescription updated,
  ) async {
    final next = _state.medicines
        .map((item) => identical(item, current) ? updated : item)
        .toList(growable: false);
    await _save(_state.copyWith(medicines: next));
  }

  Future<void> removeMedicineAt(int index) async {
    final next = [..._state.medicines]..removeAt(index);
    await _save(_state.copyWith(medicines: next));
  }

  Future<void> setFollowUp(bool value) =>
      _save(_state.copyWith(followUp: value));
  Future<void> setFollowUpAfter(String value) =>
      _save(_state.copyWith(followUpAfter: value));
  Future<void> saveDraft() => _save(_state);

  Future<void> _save(DoctorPrescriptionDraftState nextState) async {
    final appointmentId = _appointmentId;
    if (appointmentId == null) {
      _state = nextState;
      notifyListeners();
      return;
    }
    _state = await _repository.saveDraft(
      appointmentId: appointmentId,
      state: nextState,
    );
    notifyListeners();
  }
}
