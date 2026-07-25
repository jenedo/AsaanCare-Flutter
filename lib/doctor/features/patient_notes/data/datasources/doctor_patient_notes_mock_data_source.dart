import '../../domain/entities/doctor_patient_notes_state.dart';

class DoctorPatientNotesMockDataSource {
  final Map<String, DoctorPatientNotesState> _records =
      <String, DoctorPatientNotesState>{};

  Future<DoctorPatientNotesState> load({
    required String patientRecordId,
  }) async {
    _validate(patientRecordId);
    return _records.putIfAbsent(patientRecordId, DoctorPatientNotesState.new);
  }

  Future<DoctorPatientNotesState> save({
    required String patientRecordId,
    required DoctorPatientNotesState state,
  }) async {
    _validate(patientRecordId);
    _records[patientRecordId] = state;
    return state;
  }

  void reset() => _records.clear();

  void _validate(String patientRecordId) {
    if (patientRecordId.trim().isEmpty) {
      throw ArgumentError.value(patientRecordId, 'patientRecordId');
    }
  }
}
