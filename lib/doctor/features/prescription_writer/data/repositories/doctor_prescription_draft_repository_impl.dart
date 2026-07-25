import '../../domain/entities/doctor_prescription_draft_state.dart';
import '../../domain/repositories/doctor_prescription_draft_repository.dart';
import '../datasources/doctor_prescription_draft_mock_data_source.dart';

class DoctorPrescriptionDraftRepositoryImpl
    implements DoctorPrescriptionDraftRepository {
  const DoctorPrescriptionDraftRepositoryImpl({required this.dataSource});

  final DoctorPrescriptionDraftMockDataSource dataSource;

  @override
  Future<DoctorPrescriptionDraftState> loadDraft({
    required String appointmentId,
  }) {
    return dataSource.loadDraft(appointmentId: appointmentId);
  }

  @override
  Future<DoctorPrescriptionDraftState> saveDraft({
    required String appointmentId,
    required DoctorPrescriptionDraftState state,
  }) {
    return dataSource.saveDraft(appointmentId: appointmentId, state: state);
  }

  @override
  void reset() => dataSource.reset();
}
