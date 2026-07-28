// ignore_for_file: prefer_initializing_formals

import 'package:asaancare/core/config/app_config.dart';

import '../../domain/entities/doctor_profile_state.dart';
import '../../domain/repositories/doctor_profile_repository.dart';
import '../datasources/doctor_profile_mock_data_source.dart';
import '../datasources/doctor_profile_remote_data_source.dart';

class DoctorProfileRepositoryImpl implements DoctorProfileRepository {
  const DoctorProfileRepositoryImpl({
    DoctorProfileMockDataSource? mockDataSource,
    DoctorProfileMockDataSource? dataSource,
    DoctorProfileRemoteDataSource? remoteDataSource,
  }) : _mockDataSource = mockDataSource ?? dataSource,
       _remoteDataSource = remoteDataSource;

  final DoctorProfileMockDataSource? _mockDataSource;
  final DoctorProfileRemoteDataSource? _remoteDataSource;

  @override
  Future<DoctorProfileState> loadProfile({required String doctorId}) async {
    final remote = _remoteDataSource;
    if (!AppConfig.useMockApi && remote != null) {
      try {
        return await remote.loadProfile(doctorId: doctorId);
      } catch (_) {}
    }
    final mock = _mockDataSource ?? DoctorProfileMockDataSource();
    return mock.loadProfile(doctorId: doctorId);
  }

  @override
  Future<DoctorProfileState> saveProfile({
    required String doctorId,
    required DoctorProfileState state,
  }) async {
    final remote = _remoteDataSource;
    if (!AppConfig.useMockApi && remote != null) {
      try {
        return await remote.saveProfile(doctorId: doctorId, state: state);
      } catch (_) {}
    }
    final mock = _mockDataSource ?? DoctorProfileMockDataSource();
    return mock.saveProfile(doctorId: doctorId, state: state);
  }

  @override
  void reset() {
    _mockDataSource?.reset();
  }
}
