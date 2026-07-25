import '../../domain/entities/doctor_profile_state.dart';
import '../../domain/repositories/doctor_profile_repository.dart';
import '../datasources/doctor_profile_mock_data_source.dart';

class DoctorProfileRepositoryImpl implements DoctorProfileRepository {
  const DoctorProfileRepositoryImpl({required this.dataSource});

  final DoctorProfileMockDataSource dataSource;

  @override
  Future<DoctorProfileState> loadProfile({required String doctorId}) {
    return dataSource.loadProfile(doctorId: doctorId);
  }

  @override
  Future<DoctorProfileState> saveProfile({
    required String doctorId,
    required DoctorProfileState state,
  }) {
    return dataSource.saveProfile(doctorId: doctorId, state: state);
  }

  @override
  void reset() => dataSource.reset();
}
