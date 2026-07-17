import '../../domain/entities/doctor_finance_snapshot.dart';
import '../../domain/repositories/doctor_finance_repository.dart';
import '../datasources/doctor_finance_mock_data_source.dart';

class DoctorFinanceRepositoryImpl implements DoctorFinanceRepository {
  const DoctorFinanceRepositoryImpl({required this.dataSource});

  final DoctorFinanceMockDataSource dataSource;

  @override
  Future<DoctorFinanceSnapshot> getFinance({
    required String doctorId,
    required DoctorFinancePeriod period,
  }) {
    return dataSource.getFinance(doctorId: doctorId, period: period);
  }
}
