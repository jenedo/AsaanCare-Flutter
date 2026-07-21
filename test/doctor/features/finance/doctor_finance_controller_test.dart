import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/doctor/features/finance/data/datasources/doctor_finance_mock_data_source.dart';
import 'package:asaancare/doctor/features/finance/data/repositories/doctor_finance_repository_impl.dart';
import 'package:asaancare/doctor/features/finance/domain/entities/doctor_finance_snapshot.dart';
import 'package:asaancare/doctor/features/finance/domain/repositories/doctor_finance_repository.dart';
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

  DoctorFinanceController buildControllerWithRepository(
    DoctorFinanceRepository repository,
  ) {
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

    await controller.changePeriod(DoctorFinancePeriod.lastMonth);

    expect(controller.period, DoctorFinancePeriod.lastMonth);
    expect(controller.snapshot!.period, DoctorFinancePeriod.lastMonth);
  });

  test('growth percent is derived from current vs previous period totals', () async {
    final controller = buildController();
    await controller.load(doctorId: doctorId);
    final thisMonthTotal = controller.snapshot!.totalEarningsPkr;
    final thisMonthGrowth = controller.snapshot!.growthPercent;

    await controller.changePeriod(DoctorFinancePeriod.lastMonth);
    final lastMonthTotal = controller.snapshot!.totalEarningsPkr;

    expect(thisMonthGrowth.isFinite, isTrue);
    // Different calendar windows produce different deterministic totals.
    expect(lastMonthTotal, isNot(thisMonthTotal));
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

  test('reports empty when the repository has no transactions', () async {
    final controller = buildControllerWithRepository(
      _FinanceRepositoryStub(snapshot: _emptyFinanceSnapshot()),
    );

    await controller.load(doctorId: doctorId);

    expect(controller.status, DoctorFinanceLoadStatus.empty);
    expect(controller.snapshot, isNotNull);
    expect(controller.filteredTransactions, isEmpty);
    expect(controller.errorMessage, isNull);
  });

  test('reports a safe failure message when loading throws', () async {
    final controller = buildControllerWithRepository(
      _FinanceRepositoryStub(error: StateError('private payout detail')),
    );

    await controller.load(doctorId: doctorId);

    expect(controller.status, DoctorFinanceLoadStatus.failure);
    expect(controller.snapshot, isNull);
    expect(controller.errorMessage, 'Could not load earnings. Please retry.');
    expect(controller.errorMessage, isNot(contains('private payout detail')));
  });
}

DoctorFinanceSnapshot _emptyFinanceSnapshot() {
  return DoctorFinanceSnapshot(
    period: DoctorFinancePeriod.thisMonth,
    totalEarningsPkr: 0,
    availableBalancePkr: 0,
    pendingPayoutPkr: 0,
    withdrawnPkr: 0,
    platformFeesPkr: 0,
    consultationCount: 0,
    growthPercent: 0,
    transactions: const <DoctorFinanceTransaction>[],
    breakdown: const <DoctorEarningsBreakdown>[],
    payoutMethods: const <DoctorPayoutMethod>[],
    nextPayoutAt: null,
  );
}

class _FinanceRepositoryStub implements DoctorFinanceRepository {
  const _FinanceRepositoryStub({this.snapshot, this.error});

  final DoctorFinanceSnapshot? snapshot;
  final Object? error;

  @override
  Future<DoctorFinanceSnapshot> getFinance({
    required String doctorId,
    required DoctorFinancePeriod period,
    FinanceDateRange? customRange,
  }) {
    final failure = error;
    if (failure != null) return Future<DoctorFinanceSnapshot>.error(failure);
    return Future<DoctorFinanceSnapshot>.value(snapshot!);
  }
}
