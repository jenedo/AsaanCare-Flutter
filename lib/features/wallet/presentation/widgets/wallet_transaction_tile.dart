import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../utils/wallet_formatters.dart';

class WalletTransactionTile extends StatelessWidget {
  const WalletTransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final WalletTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = _transactionVisual(transaction.type);
    final amountPrefix = transaction.isCredit ? '+' : '-';

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: visual.background,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(visual.icon, color: visual.foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatWalletDate(transaction.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF8A9698),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix ${formatWalletRupees(transaction.amount)}',
                    style: TextStyle(
                      color: transaction.isCredit
                          ? AppTheme.success
                          : AppTheme.textDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    transaction.status.label,
                    style: TextStyle(
                      color: _statusColor(transaction.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

_TransactionVisual _transactionVisual(WalletTransactionType type) {
  return switch (type) {
    WalletTransactionType.topUp => const _TransactionVisual(
      icon: Icons.add_card_rounded,
      foreground: AppTheme.success,
      background: Color(0xFFE8F8F1),
    ),
    WalletTransactionType.payment => const _TransactionVisual(
      icon: Icons.shopping_bag_outlined,
      foreground: AppTheme.primary,
      background: AppTheme.softTeal,
    ),
    WalletTransactionType.refund => const _TransactionVisual(
      icon: Icons.undo_rounded,
      foreground: Color(0xFF6C55C9),
      background: Color(0xFFF0EDFF),
    ),
  };
}

Color _statusColor(WalletTransactionStatus status) {
  return switch (status) {
    WalletTransactionStatus.completed => AppTheme.success,
    WalletTransactionStatus.pending => AppTheme.warning,
    WalletTransactionStatus.failed => AppTheme.danger,
  };
}

class _TransactionVisual {
  const _TransactionVisual({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
}
