import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/theme/app_theme.dart';
import '../utils/wallet_formatters.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
    required this.onAddMoney,
    required this.onTransactions,
  });

  final int balance;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onAddMoney;
  final VoidCallback onTransactions;

  @override
  Widget build(BuildContext context) {
    final compact = AppLayout.isCompact(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryDark,
            AppTheme.primary,
            AppTheme.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Available balance',
                style: TextStyle(
                  color: Color(0xFFD9FFFA),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: isBalanceVisible ? 'Hide balance' : 'Show balance',
                onPressed: onToggleVisibility,
                color: Colors.white,
                icon: Icon(
                  isBalanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              isBalanceVisible ? formatWalletRupees(balance) : 'Rs. ******',
              key: ValueKey<bool>(isBalanceVisible),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                height: 1.1,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 17,
                color: Color(0xFFD9FFFA),
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Demo wallet balance for your AsaanCare payments',
                  style: TextStyle(
                    color: Color(0xFFD9FFFA),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (compact) ...[
            FilledButton.icon(
              onPressed: onAddMoney,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryDark,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Money'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onTransactions,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xBFFFFFFF)),
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Transactions'),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAddMoney,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryDark,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Money'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTransactions,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xBFFFFFFF)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Transactions'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
