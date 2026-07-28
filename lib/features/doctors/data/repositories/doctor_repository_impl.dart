// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import '../../../../core/config/app_config.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_mock_data_source.dart';
import '../datasources/doctor_remote_data_source.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  const DoctorRepositoryImpl({
    DoctorMockDataSource? mockDataSource,
    DoctorRemoteDataSource? remoteDataSource,
  }) : _mockDataSource = mockDataSource,
       _remoteDataSource = remoteDataSource;

  final DoctorMockDataSource? _mockDataSource;
  final DoctorRemoteDataSource? _remoteDataSource;

  @override
  Future<List<Doctor>> getDoctors({String? specialty, String? city}) async {
    final remote = _remoteDataSource;
    if (!AppConfig.useMockApi && remote != null) {
      try {
        final doctors = await remote.getDoctors(
          specialty: specialty,
          city: city,
        );
        if (doctors.isNotEmpty) return doctors;
      } catch (_) {}
    }
    final mock = _mockDataSource ?? DoctorMockDataSource();
    return mock.getDoctors();
  }

  @override
  Future<Doctor> getDoctorDetail(String doctorId) async {
    final remote = _remoteDataSource;
    if (!AppConfig.useMockApi && remote != null) {
      try {
        return await remote.getDoctorById(doctorId);
      } catch (_) {}
    }
    final mock = _mockDataSource ?? DoctorMockDataSource();
    return mock.getDoctorDetail(doctorId);
  }
}
