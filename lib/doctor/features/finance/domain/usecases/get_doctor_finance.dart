import '../entities/doctor_finance_snapshot.dart';
import '../repositories/doctor_finance_repository.dart';

class GetDoctorFinance {
  const GetDoctorFinance(this._repository);

  final DoctorFinanceRepository _repository;

  Future<DoctorFinanceSnapshot> call({
    required String doctorId,
    required DoctorFinancePeriod period,
  }) {
    return _repository.getFinance(doctorId: doctorId, period: period);
  }
}
