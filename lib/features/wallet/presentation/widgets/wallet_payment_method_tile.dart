import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/wallet_payment_method.dart';

class WalletPaymentMethodTile extends StatelessWidget {
  const WalletPaymentMethodTile({
    super.key,
    required this.method,
    this.onTap,
    this.trailing,
  });

  final WalletPaymentMethod method;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            border: Border.all(
              color: method.isDefault
                  ? AppTheme.primary.withValues(alpha: 0.55)
                  : AppTheme.border,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.softTeal,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  walletPaymentMethodIcon(method.type),
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            method.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (method.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.softTeal,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      method.maskedValue,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

IconData walletPaymentMethodIcon(WalletPaymentMethodType type) {
  return switch (type) {
    WalletPaymentMethodType.card => Icons.credit_card_rounded,
    WalletPaymentMethodType.bankTransfer => Icons.account_balance_outlined,
    WalletPaymentMethodType.easypaisa => Icons.phone_android_rounded,
    WalletPaymentMethodType.jazzCash => Icons.mobile_friendly_rounded,
  };
}
