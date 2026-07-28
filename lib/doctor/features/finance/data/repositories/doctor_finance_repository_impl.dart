// ignore_for_file: prefer_initializing_formals

import 'package:asaancare/core/config/app_config.dart';

import '../../domain/entities/doctor_finance_snapshot.dart';
import '../../domain/repositories/doctor_finance_repository.dart';
import '../datasources/doctor_finance_mock_data_source.dart';
import '../datasources/doctor_finance_remote_data_source.dart';

class DoctorFinanceRepositoryImpl implements DoctorFinanceRepository {
  const DoctorFinanceRepositoryImpl({
    DoctorFinanceMockDataSource? mockDataSource,
    DoctorFinanceMockDataSource? dataSource,
    DoctorFinanceRemoteDataSource? remoteDataSource,
  }) : _mockDataSource = mockDataSource ?? dataSource,
       _remoteDataSource = remoteDataSource;

  final DoctorFinanceMockDataSource? _mockDataSource;
  final DoctorFinanceRemoteDataSource? _remoteDataSource;

  @override
  Future<DoctorFinanceSnapshot> getFinance({
    required String doctorId,
    required DoctorFinancePeriod period,
    FinanceDateRange? customRange,
  }) async {
    final remote = _remoteDataSource;
    if (!AppConfig.useMockApi && remote != null) {
      try {
        return await remote.getFinance(
          doctorId: doctorId,
          period: period,
          customRange: customRange,
        );
      } catch (_) {}
    }
    final mock = _mockDataSource ?? DoctorFinanceMockDataSource();
    return mock.getFinance(
      doctorId: doctorId,
      period: period,
      customRange: customRange,
    );
  }
}
