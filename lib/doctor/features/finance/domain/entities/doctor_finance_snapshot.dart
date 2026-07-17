enum DoctorFinanceLoadStatus { initial, loading, ready, empty, failure }

enum DoctorFinancePeriod { thisMonth, lastThreeMonths, thisYear }

enum DoctorWalletFilter { all, credits, debits }

enum DoctorFinanceTransactionStatus { completed, pending, processing }

enum DoctorFinanceTransactionKind { consultation, payout, platformFee }

class DoctorFinanceTransaction {
  const DoctorFinanceTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amountPkr,
    required this.occurredAt,
    required this.kind,
    required this.status,
  });

  final String id;
  final String title;
  final String subtitle;
  final int amountPkr;
  final DateTime occurredAt;
  final DoctorFinanceTransactionKind kind;
  final DoctorFinanceTransactionStatus status;
}

class DoctorPayoutMethod {
  const DoctorPayoutMethod({
    required this.id,
    required this.label,
    required this.maskedDetails,
    required this.isPrimary,
    required this.isVerified,
  });

  final String id;
  final String label;
  final String maskedDetails;
  final bool isPrimary;
  final bool isVerified;
}

class DoctorEarningsBreakdown {
  const DoctorEarningsBreakdown({
    required this.label,
    required this.amountPkr,
    required this.share,
  });

  final String label;
  final int amountPkr;
  final double share;
}

class DoctorFinanceSnapshot {
  DoctorFinanceSnapshot({
    required this.period,
    required this.totalEarningsPkr,
    required this.availableBalancePkr,
    required this.pendingPayoutPkr,
    required this.withdrawnPkr,
    required this.platformFeesPkr,
    required this.consultationCount,
    required this.growthPercent,
    required List<DoctorFinanceTransaction> transactions,
    required List<DoctorEarningsBreakdown> breakdown,
    required List<DoctorPayoutMethod> payoutMethods,
    required this.nextPayoutAt,
  }) : transactions = List<DoctorFinanceTransaction>.unmodifiable(transactions),
       breakdown = List<DoctorEarningsBreakdown>.unmodifiable(breakdown),
       payoutMethods = List<DoctorPayoutMethod>.unmodifiable(payoutMethods);

  final DoctorFinancePeriod period;
  final int totalEarningsPkr;
  final int availableBalancePkr;
  final int pendingPayoutPkr;
  final int withdrawnPkr;
  final int platformFeesPkr;
  final int consultationCount;
  final double growthPercent;
  final List<DoctorFinanceTransaction> transactions;
  final List<DoctorEarningsBreakdown> breakdown;
  final List<DoctorPayoutMethod> payoutMethods;
  final DateTime? nextPayoutAt;
}

extension DoctorFinancePeriodLabel on DoctorFinancePeriod {
  String get label => switch (this) {
    DoctorFinancePeriod.thisMonth => 'This month',
    DoctorFinancePeriod.lastThreeMonths => 'Last 3 months',
    DoctorFinancePeriod.thisYear => 'This year',
  };
}

extension DoctorWalletFilterLabel on DoctorWalletFilter {
  String get label => switch (this) {
    DoctorWalletFilter.all => 'All activity',
    DoctorWalletFilter.credits => 'Credits only',
    DoctorWalletFilter.debits => 'Debits only',
  };
}

extension DoctorFinanceTransactionStatusLabel
    on DoctorFinanceTransactionStatus {
  String get label => switch (this) {
    DoctorFinanceTransactionStatus.completed => 'Completed',
    DoctorFinanceTransactionStatus.pending => 'Pending',
    DoctorFinanceTransactionStatus.processing => 'Processing',
  };
}

String formatPkr(int rupees) {
  final negative = rupees < 0;
  final digits = rupees.abs().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  return '${negative ? '-' : ''}PKR $buffer';
}
