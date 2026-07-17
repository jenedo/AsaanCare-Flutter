import '../../domain/entities/doctor_finance_snapshot.dart';

class DoctorFinanceMockDataSource {
  DoctorFinanceMockDataSource({
    this.loadDelay = const Duration(milliseconds: 180),
  });

  final Duration loadDelay;

  Future<DoctorFinanceSnapshot> getFinance({
    required String doctorId,
    required DoctorFinancePeriod period,
  }) async {
    if (doctorId.trim().isEmpty) {
      throw ArgumentError.value(doctorId, 'doctorId');
    }
    if (loadDelay > Duration.zero) {
      await Future<void>.delayed(loadDelay);
    }
    final now = DateTime.now();
    final multiplier = switch (period) {
      DoctorFinancePeriod.thisMonth => 1,
      DoctorFinancePeriod.lastThreeMonths => 3,
      DoctorFinancePeriod.thisYear => 8,
    };
    final total = 28500 * multiplier;
    final pending = 8000 * multiplier;
    final withdrawn = 6500 * multiplier;
    final fees = 2850 * multiplier;
    return DoctorFinanceSnapshot(
      period: period,
      totalEarningsPkr: total,
      availableBalancePkr: total - withdrawn - fees,
      pendingPayoutPkr: pending,
      withdrawnPkr: withdrawn,
      platformFeesPkr: fees,
      consultationCount: 19 * multiplier,
      growthPercent: 12.4,
      nextPayoutAt: now.add(const Duration(days: 5)),
      payoutMethods: const [
        DoctorPayoutMethod(
          id: 'hbl-primary',
          label: 'HBL Bank',
          maskedDetails: '**** 4587',
          isPrimary: true,
          isVerified: true,
        ),
        DoctorPayoutMethod(
          id: 'jazzcash-secondary',
          label: 'JazzCash',
          maskedDetails: '0300-***4567',
          isPrimary: false,
          isVerified: true,
        ),
      ],
      breakdown: [
        DoctorEarningsBreakdown(
          label: 'Video consultations',
          amountPkr: (total * .55).round(),
          share: .55,
        ),
        DoctorEarningsBreakdown(
          label: 'Clinic visits',
          amountPkr: (total * .32).round(),
          share: .32,
        ),
        DoctorEarningsBreakdown(
          label: 'Follow-ups',
          amountPkr: (total * .13).round(),
          share: .13,
        ),
      ],
      transactions: [
        DoctorFinanceTransaction(
          id: 'finance-video-1',
          title: 'Video consultation',
          subtitle: 'Ahmed Hassan',
          amountPkr: 1500,
          occurredAt: now.subtract(const Duration(hours: 2)),
          kind: DoctorFinanceTransactionKind.consultation,
          status: DoctorFinanceTransactionStatus.completed,
        ),
        DoctorFinanceTransaction(
          id: 'finance-clinic-1',
          title: 'Clinic visit',
          subtitle: 'Sara Bibi',
          amountPkr: 2000,
          occurredAt: now.subtract(const Duration(hours: 4)),
          kind: DoctorFinanceTransactionKind.consultation,
          status: DoctorFinanceTransactionStatus.pending,
        ),
        DoctorFinanceTransaction(
          id: 'finance-fee-1',
          title: 'Platform fee',
          subtitle: 'Video consultation fee',
          amountPkr: -150,
          occurredAt: now.subtract(const Duration(hours: 2)),
          kind: DoctorFinanceTransactionKind.platformFee,
          status: DoctorFinanceTransactionStatus.completed,
        ),
        DoctorFinanceTransaction(
          id: 'finance-payout-1',
          title: 'Bank payout',
          subtitle: 'HBL Bank **** 4587',
          amountPkr: -6500,
          occurredAt: now.subtract(const Duration(days: 3)),
          kind: DoctorFinanceTransactionKind.payout,
          status: DoctorFinanceTransactionStatus.completed,
        ),
      ],
    );
  }
}
