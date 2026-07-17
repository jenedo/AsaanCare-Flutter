import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/doctor/features/finance/data/datasources/doctor_finance_mock_data_source.dart';
import 'package:asaancare/doctor/features/finance/data/repositories/doctor_finance_repository_impl.dart';
import 'package:asaancare/doctor/features/finance/domain/entities/doctor_finance_snapshot.dart';
import 'package:asaancare/doctor/features/finance/domain/usecases/get_doctor_finance.dart';
import 'package:asaancare/doctor/features/finance/presentation/controllers/doctor_finance_controller.dart';

void main() {
  const doctorId = 'doctor-finance-test';

  DoctorFinanceController buildController() {
    final repository = DoctorFinanceRepositoryImpl(
      dataSource: DoctorFinanceMockDataSource(),
    );
    return DoctorFinanceController(getFinance: GetDoctorFinance(repository));
  }

  test('loads finance totals and formats Pakistani currency', () async {
    final controller = buildController();

    await controller.load(doctorId: doctorId);

    expect(controller.status, DoctorFinanceLoadStatus.ready);
    expect(controller.snapshot!.totalEarningsPkr, greaterThan(0));
    expect(formatPkr(8450), 'PKR 8,450');
    expect(formatPkr(0), 'PKR 0');
  });

  test('changing period reloads the finance snapshot', () async {
    final controller = buildController();
    await controller.load(doctorId: doctorId);

    await controller.changePeriod(DoctorFinancePeriod.lastThreeMonths);

    expect(controller.period, DoctorFinancePeriod.lastThreeMonths);
    expect(controller.snapshot!.period, DoctorFinancePeriod.lastThreeMonths);
  });

  test('wallet filters separate credits and debits', () async {
    final controller = buildController();
    await controller.load(doctorId: doctorId);

    controller.selectWalletFilter(DoctorWalletFilter.credits);
    expect(
      controller.filteredTransactions,
      everyElement(
        predicate<DoctorFinanceTransaction>(
          (transaction) => transaction.amountPkr > 0,
        ),
      ),
    );

    controller.selectWalletFilter(DoctorWalletFilter.debits);
    expect(
      controller.filteredTransactions,
      everyElement(
        predicate<DoctorFinanceTransaction>(
          (transaction) => transaction.amountPkr < 0,
        ),
      ),
    );
  });

  test('money-moving capabilities stay gated without a verified API', () async {
    final controller = buildController();
    await controller.load(doctorId: doctorId);

    expect(controller.canWithdraw, isFalse);
    expect(controller.canTransfer, isFalse);
    expect(controller.snapshot!.payoutMethods, isNotEmpty);
  });
}
