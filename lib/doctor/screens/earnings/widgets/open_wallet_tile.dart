import 'package:flutter/material.dart';

import '../../../../shared/theme/doctor_tokens.dart';

/// Tappable "Open wallet" row. Navigates to the existing
/// [DoctorWalletScreen] via the parent callback — do not stub a new route.
class OpenWalletTile extends StatelessWidget {
  const OpenWalletTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DoctorColors.neutralPill,
      borderRadius: BorderRadius.circular(DoctorSpacing.radiusCard),
      child: InkWell(
        key: const ValueKey('open-wallet-tile'),
        borderRadius: BorderRadius.circular(DoctorSpacing.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: DoctorColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: DoctorColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Open wallet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: DoctorColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'View balance, withdrawals and payouts',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: DoctorColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: DoctorColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
