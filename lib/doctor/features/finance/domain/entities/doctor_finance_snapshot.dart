enum DoctorFinanceLoadStatus { initial, loading, ready, empty, failure }

enum DoctorFinancePeriod { thisMonth, lastMonth, thisWeek, custom }

/// Inclusive calendar range used for period filtering and growth comparison.
class FinanceDateRange {
  const FinanceDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool contains(DateTime value) =>
      !value.isBefore(start) && !value.isAfter(end);
}

/// Inclusive calendar-day range for a finance period.
FinanceDateRange resolveFinancePeriodRange(
  DoctorFinancePeriod period, {
  required DateTime now,
  FinanceDateRange? customRange,
}) {
  final today = DateTime(now.year, now.month, now.day);
  return switch (period) {
    DoctorFinancePeriod.thisMonth => FinanceDateRange(
      start: DateTime(now.year, now.month, 1),
      end: today
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1)),
    ),
    DoctorFinancePeriod.lastMonth => () {
      final start = DateTime(now.year, now.month - 1, 1);
      final end = DateTime(
        now.year,
        now.month,
        1,
      ).subtract(const Duration(milliseconds: 1));
      return FinanceDateRange(start: start, end: end);
    }(),
    DoctorFinancePeriod.thisWeek => () {
      final weekday = today.weekday; // Mon=1
      final start = today.subtract(Duration(days: weekday - 1));
      return FinanceDateRange(
        start: start,
        end: today
            .add(const Duration(days: 1))
            .subtract(const Duration(milliseconds: 1)),
      );
    }(),
    DoctorFinancePeriod.custom =>
      customRange ??
          FinanceDateRange(
            start: today.subtract(const Duration(days: 7)),
            end: today,
          ),
  };
}

/// The immediately preceding period used for growth percentage.
FinanceDateRange previousFinancePeriodRange(
  DoctorFinancePeriod period, {
  required FinanceDateRange current,
}) {
  return switch (period) {
    DoctorFinancePeriod.thisMonth || DoctorFinancePeriod.lastMonth =>
      FinanceDateRange(
        start: DateTime(current.start.year, current.start.month - 1, 1),
        end: current.start.subtract(const Duration(milliseconds: 1)),
      ),
    DoctorFinancePeriod.thisWeek => FinanceDateRange(
      start: current.start.subtract(const Duration(days: 7)),
      end: current.start.subtract(const Duration(milliseconds: 1)),
    ),
    DoctorFinancePeriod.custom => () {
      final length = current.end.difference(current.start);
      final end = current.start.subtract(const Duration(milliseconds: 1));
      final start = end.subtract(length);
      return FinanceDateRange(start: start, end: end);
    }(),
  };
}

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
    DoctorFinancePeriod.lastMonth => 'Last month',
    DoctorFinancePeriod.thisWeek => 'This week',
    DoctorFinancePeriod.custom => 'Custom range',
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
