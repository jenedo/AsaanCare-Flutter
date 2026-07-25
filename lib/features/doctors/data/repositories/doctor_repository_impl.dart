// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

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
  Future<List<Doctor>> getDoctors() {
    final remote = _remoteDataSource;
    if (remote != null) return remote.getDoctors();
    return _mockDataSource!.getDoctors();
  }

  @override
  Future<Doctor> getDoctorDetail(String doctorId) {
    final remote = _remoteDataSource;
    if (remote != null) {
      return remote.getDoctorDetail(doctorId);
    }
    return _mockDataSource!.getDoctorDetail(doctorId);
  }
}
