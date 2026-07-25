import '../../domain/entities/doctor_patient_notes_state.dart';
import '../../domain/repositories/doctor_patient_notes_repository.dart';
import '../datasources/doctor_patient_notes_mock_data_source.dart';

class DoctorPatientNotesRepositoryImpl implements DoctorPatientNotesRepository {
  const DoctorPatientNotesRepositoryImpl({required this.dataSource});

  final DoctorPatientNotesMockDataSource dataSource;

  @override
  Future<DoctorPatientNotesState> load({required String patientRecordId}) {
    return dataSource.load(patientRecordId: patientRecordId);
  }

  @override
  Future<DoctorPatientNotesState> save({
    required String patientRecordId,
    required DoctorPatientNotesState state,
  }) {
    return dataSource.save(patientRecordId: patientRecordId, state: state);
  }

  @override
  void reset() => dataSource.reset();
}
