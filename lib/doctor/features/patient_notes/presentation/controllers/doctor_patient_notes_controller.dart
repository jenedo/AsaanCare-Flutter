import 'package:flutter/foundation.dart';

import '../../domain/entities/doctor_patient_notes_state.dart';
import '../../domain/repositories/doctor_patient_notes_repository.dart';

class DoctorPatientNotesController extends ChangeNotifier {
  DoctorPatientNotesController({required this._repository});

  final DoctorPatientNotesRepository _repository;

  DoctorPatientNotesState _state = const DoctorPatientNotesState();
  String? _patientRecordId;
  bool _isLoaded = false;

  DoctorPatientNotesState get state => _state;

  Future<void> load({required String patientRecordId}) async {
    final normalizedId = patientRecordId.trim();
    if (normalizedId.isEmpty) return;
    if (_isLoaded && _patientRecordId == normalizedId) return;
    _patientRecordId = normalizedId;
    _state = await _repository.load(patientRecordId: normalizedId);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> selectTab(int index) =>
      _save(_state.copyWith(selectedTab: index));

  Future<void> addNote(String note) async {
    final trimmedNote = note.trim();
    if (trimmedNote.isEmpty) return;
    await _save(_state.copyWith(notes: [trimmedNote, ..._state.notes]));
  }

  Future<void> _save(DoctorPatientNotesState nextState) async {
    final patientRecordId = _patientRecordId;
    if (patientRecordId == null) {
      _state = nextState;
      notifyListeners();
      return;
    }
    _state = await _repository.save(
      patientRecordId: patientRecordId,
      state: nextState,
    );
    notifyListeners();
  }
}
