import '../entities/doctor_prescription_draft_state.dart';

abstract class DoctorPrescriptionDraftRepository {
  Future<DoctorPrescriptionDraftState> loadDraft({
    required String appointmentId,
  });
  Future<DoctorPrescriptionDraftState> saveDraft({
    required String appointmentId,
    required DoctorPrescriptionDraftState state,
  });
  void reset();
}
