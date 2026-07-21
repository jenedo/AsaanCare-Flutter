import '../../domain/entities/doctor_finance_snapshot.dart';

class DoctorFinanceMockDataSource {
  DoctorFinanceMockDataSource({
    this.loadDelay = const Duration(milliseconds: 180),
  });

  final Duration loadDelay;

  Future<DoctorFinanceSnapshot> getFinance({
    required String doctorId,
    required DoctorFinancePeriod period,
    FinanceDateRange? customRange,
  }) async {
    if (doctorId.trim().isEmpty) {
      throw ArgumentError.value(doctorId, 'doctorId');
    }
    if (loadDelay > Duration.zero) {
      await Future<void>.delayed(loadDelay);
    }

    final now = DateTime.now();
    final currentRange = resolveFinancePeriodRange(
      period,
      now: now,
      customRange: customRange,
    );
    final previousRange = previousFinancePeriodRange(
      period,
      current: currentRange,
    );

    final currentTotal = _totalForRange(currentRange);
    final previousTotal = _totalForRange(previousRange);
    final growthPercent = previousTotal == 0
        ? (currentTotal == 0 ? 0.0 : 100.0)
        : ((currentTotal - previousTotal) / previousTotal) * 100;

    final pending = (currentTotal * 0.28).round();
    final withdrawn = (currentTotal * 0.23).round();
    final fees = (currentTotal * 0.1).round();
    final consultations = (currentTotal / 1500).round().clamp(0, 999);

    return DoctorFinanceSnapshot(
      period: period,
      totalEarningsPkr: currentTotal,
      availableBalancePkr: currentTotal - withdrawn - fees,
      pendingPayoutPkr: pending,
      withdrawnPkr: withdrawn,
      platformFeesPkr: fees,
      consultationCount: consultations,
      growthPercent: double.parse(growthPercent.toStringAsFixed(1)),
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
          amountPkr: (currentTotal * .55).round(),
          share: .55,
        ),
        DoctorEarningsBreakdown(
          label: 'Clinic visits',
          amountPkr: (currentTotal * .32).round(),
          share: .32,
        ),
        DoctorEarningsBreakdown(
          label: 'Follow-ups',
          amountPkr: (currentTotal * .13).round(),
          share: .13,
        ),
      ],
      transactions: _transactionsForRange(currentRange, now),
    );
  }

  /// Deterministic earnings for a date range so growth is a real
  /// current-vs-previous calculation (not a hardcoded percentage).
  int _totalForRange(FinanceDateRange range) {
    final days = range.end.difference(range.start).inDays.abs() + 1;
    final seed =
        range.start.year * 10000 + range.start.month * 100 + range.start.day;
    final daily = 900 + (seed % 700);
    return daily * days;
  }

  List<DoctorFinanceTransaction> _transactionsForRange(
    FinanceDateRange range,
    DateTime now,
  ) {
    final mid = range.start.add(
      Duration(days: (range.end.difference(range.start).inDays / 2).floor()),
    );
    final occurred = mid.isAfter(now)
        ? now.subtract(const Duration(hours: 2))
        : mid;
    return [
      DoctorFinanceTransaction(
        id: 'finance-video-1',
        title: 'Video consultation',
        subtitle: 'Ahmed Hassan',
        amountPkr: 1500,
        occurredAt: occurred,
        kind: DoctorFinanceTransactionKind.consultation,
        status: DoctorFinanceTransactionStatus.completed,
      ),
      DoctorFinanceTransaction(
        id: 'finance-clinic-1',
        title: 'Clinic visit',
        subtitle: 'Sara Bibi',
        amountPkr: 2000,
        occurredAt: occurred.subtract(const Duration(hours: 4)),
        kind: DoctorFinanceTransactionKind.consultation,
        status: DoctorFinanceTransactionStatus.pending,
      ),
      DoctorFinanceTransaction(
        id: 'finance-audio-1',
        title: 'Audio consultation',
        subtitle: 'Fatima Ali',
        amountPkr: 1000,
        occurredAt: occurred.subtract(const Duration(days: 1)),
        kind: DoctorFinanceTransactionKind.consultation,
        status: DoctorFinanceTransactionStatus.completed,
      ),
      DoctorFinanceTransaction(
        id: 'finance-fee-1',
        title: 'Platform fee',
        subtitle: 'Video consultation fee',
        amountPkr: -150,
        occurredAt: occurred.subtract(const Duration(hours: 2)),
        kind: DoctorFinanceTransactionKind.platformFee,
        status: DoctorFinanceTransactionStatus.completed,
      ),
      DoctorFinanceTransaction(
        id: 'finance-payout-1',
        title: 'Bank payout',
        subtitle: 'HBL Bank **** 4587',
        amountPkr: -6500,
        occurredAt: occurred.subtract(const Duration(days: 3)),
        kind: DoctorFinanceTransactionKind.payout,
        status: DoctorFinanceTransactionStatus.completed,
      ),
    ];
  }
}
