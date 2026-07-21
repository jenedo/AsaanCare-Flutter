import 'package:flutter/material.dart';

import '../../../../shared/theme/doctor_tokens.dart';
import '../../../features/finance/domain/entities/doctor_finance_snapshot.dart';

/// Transaction list for the Earnings "Transactions" tab.
///
/// Designed without a reference mock — uses the app's existing card + status
/// chip conventions. Should be reviewed against the real design before final.
class EarningsTransactionsList extends StatelessWidget {
  const EarningsTransactionsList({super.key, required this.transactions});

  final List<DoctorFinanceTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: DoctorColors.surface,
          borderRadius: BorderRadius.circular(DoctorSpacing.radiusCard),
          boxShadow: DoctorColors.cardShadow,
        ),
        child: const Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: DoctorColors.primary,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'No transactions yet',
              style: TextStyle(
                color: DoctorColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Completed consultations and payouts will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: DoctorColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(DoctorSpacing.radiusCard),
        boxShadow: DoctorColors.cardShadow,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: DoctorColors.border),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return _TransactionTile(transaction: tx);
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final DoctorFinanceTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final positive = transaction.amountPkr >= 0;
    final (chipBg, chipFg) = switch (transaction.status) {
      DoctorFinanceTransactionStatus.completed => (
        const Color(0xFFEAF8EF),
        DoctorColors.success,
      ),
      DoctorFinanceTransactionStatus.pending => (
        const Color(0xFFFFF5E6),
        DoctorColors.warning,
      ),
      DoctorFinanceTransactionStatus.processing => (
        DoctorColors.mint,
        DoctorColors.primaryDark,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: positive ? DoctorColors.mint : const Color(0xFFFFF2E5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _kindIcon(transaction.kind),
              color: positive ? DoctorColors.primary : const Color(0xFFE67E00),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.subtitle.isEmpty
                      ? transaction.title
                      : transaction.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DoctorColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.title} · ${_formatDate(transaction.occurredAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DoctorColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPkr(transaction.amountPkr),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: positive
                      ? DoctorColors.primaryDark
                      : DoctorColors.danger,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(DoctorSpacing.radiusPill),
                ),
                child: Text(
                  transaction.status.label,
                  style: TextStyle(
                    color: chipFg,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _kindIcon(DoctorFinanceTransactionKind kind) => switch (kind) {
  DoctorFinanceTransactionKind.consultation => Icons.videocam_outlined,
  DoctorFinanceTransactionKind.payout => Icons.account_balance_outlined,
  DoctorFinanceTransactionKind.platformFee => Icons.percent_rounded,
};

String _formatDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${value.day} ${months[value.month - 1]}';
}
