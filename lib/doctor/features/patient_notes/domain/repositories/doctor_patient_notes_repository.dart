import '../entities/doctor_patient_notes_state.dart';

abstract class DoctorPatientNotesRepository {
  Future<DoctorPatientNotesState> load({required String patientRecordId});
  Future<DoctorPatientNotesState> save({
    required String patientRecordId,
    required DoctorPatientNotesState state,
  });
  void reset();
}
