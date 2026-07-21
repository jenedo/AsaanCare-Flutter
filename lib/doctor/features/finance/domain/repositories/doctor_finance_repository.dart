import '../entities/doctor_finance_snapshot.dart';

abstract class DoctorFinanceRepository {
  Future<DoctorFinanceSnapshot> getFinance({
    required String doctorId,
    required DoctorFinancePeriod period,
    FinanceDateRange? customRange,
  });
}
