import '../../domain/entities/doctor_prescription_draft_state.dart';

class DoctorPrescriptionDraftMockDataSource {
  final Map<String, DoctorPrescriptionDraftState> _drafts =
      <String, DoctorPrescriptionDraftState>{};

  Future<DoctorPrescriptionDraftState> loadDraft({
    required String appointmentId,
  }) async {
    _validate(appointmentId);
    return _drafts.putIfAbsent(appointmentId, DoctorPrescriptionDraftState.new);
  }

  Future<DoctorPrescriptionDraftState> saveDraft({
    required String appointmentId,
    required DoctorPrescriptionDraftState state,
  }) async {
    _validate(appointmentId);
    _drafts[appointmentId] = state;
    return state;
  }

  void reset() => _drafts.clear();

  void _validate(String appointmentId) {
    if (appointmentId.trim().isEmpty) {
      throw ArgumentError.value(appointmentId, 'appointmentId');
    }
  }
}
