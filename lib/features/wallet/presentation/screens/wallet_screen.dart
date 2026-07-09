import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/add_money_sheet.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_payment_method_tile.dart';
import '../widgets/wallet_transaction_tile.dart';
import 'wallet_payment_methods_screen.dart';
import 'wallet_transactions_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({
    super.key,
    required this.controller,
    required this.patientId,
  });

  final WalletController controller;
  final String patientId;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);

    Future<void>.microtask(
      () => widget.controller.load(patientId: widget.patientId),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    widget.controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError ? AppTheme.danger : null,
          content: Text(message),
        ),
      );
  }

  Future<void> _openAddMoney() async {
    widget.controller.clearMessages();

    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      builder: (context) {
        return AddMoneySheet(
          controller: widget.controller,
          patientId: widget.patientId,
        );
      },
    );

    if (!mounted || added != true) return;

    _showMessage(
      widget.controller.successMessage ?? 'Money added successfully.',
    );
    widget.controller.clearMessages();
  }

  void _openTransactions() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => WalletTransactionsScreen(
          controller: widget.controller,
          patientId: widget.patientId,
        ),
      ),
    );
  }

  void _openPaymentMethods() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => WalletPaymentMethodsScreen(
          controller: widget.controller,
          patientId: widget.patientId,
        ),
      ),
    );
  }

  void _showHelp() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  size: 48,
                  color: AppTheme.primary,
                ),
                SizedBox(height: 14),
                Text(
                  'Wallet Help',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This is a demo wallet. Real top-ups, withdrawals and '
                  'payment disputes will be handled through verified payment '
                  'providers and AsaanCare support.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, height: 1.45),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTransactionDetails(int index) {
    final transaction = widget.controller.recentTransactions[index];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 26),
            child: WalletTransactionTile(
              transaction: transaction,
              onTap: () {},
            ),
          ),
        );
      },
    );
  }

  void _handleNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.patientHome);
        return;
      case 1:
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.doctorDetail, arguments: 'doctor_ali');
        return;
      case 2:
        Navigator.of(context).pushReplacementNamed(AppRoutes.pharmacy);
        return;
      case 3:
        Navigator.of(context).pushReplacementNamed(AppRoutes.medicalRecords);
        return;
      case 4:
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: AppTheme.background,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 4,
        onTap: _handleNavTap,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxMobileContentWidth,
            ),
            child: _buildBody(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(WalletController controller) {
    if ((controller.isInitial || controller.isLoading) &&
        controller.snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError && controller.snapshot == null) {
      return _WalletErrorState(
        message:
            controller.errorMessage ??
            'Could not load your wallet. Please try again.',
        onRetry: () =>
            controller.load(patientId: widget.patientId, forceRefresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refresh(widget.patientId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppLayout.horizontalPadding(context),
          18,
          AppLayout.horizontalPadding(context),
          110,
        ),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'My Wallet',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh wallet',
                onPressed: controller.isLoading
                    ? null
                    : () => controller.refresh(widget.patientId),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WalletBalanceCard(
            balance: controller.balance,
            isBalanceVisible: controller.isBalanceVisible,
            onToggleVisibility: controller.toggleBalanceVisibility,
            onAddMoney: _openAddMoney,
            onTransactions: _openTransactions,
          ),
          const SizedBox(height: 26),
          const _SectionTitle(title: 'Quick Actions'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
            children: [
              _QuickAction(
                icon: Icons.add_card_rounded,
                label: 'Add\nMoney',
                onTap: _openAddMoney,
              ),
              _QuickAction(
                icon: Icons.receipt_long_outlined,
                label: 'Transaction\nHistory',
                onTap: _openTransactions,
              ),
              _QuickAction(
                icon: Icons.credit_card_rounded,
                label: 'Payment\nMethods',
                onTap: _openPaymentMethods,
              ),
              _QuickAction(
                icon: Icons.help_outline_rounded,
                label: 'Wallet\nHelp',
                onTap: _showHelp,
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SectionHeader(
            title: 'Recent Transactions',
            actionText: 'View all',
            onTap: _openTransactions,
          ),
          const SizedBox(height: 10),
          if (controller.recentTransactions.isEmpty)
            const _EmptySection(
              icon: Icons.receipt_long_outlined,
              message: 'Your wallet transactions will appear here.',
            )
          else
            ...List.generate(
              controller.recentTransactions.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: WalletTransactionTile(
                  transaction: controller.recentTransactions[index],
                  onTap: () => _showTransactionDetails(index),
                ),
              ),
            ),
          const SizedBox(height: 22),
          _SectionHeader(
            title: 'Payment Methods',
            actionText: 'Manage',
            onTap: _openPaymentMethods,
          ),
          const SizedBox(height: 10),
          if (controller.paymentMethods.isEmpty)
            const _EmptySection(
              icon: Icons.credit_card_off_outlined,
              message: 'No saved payment methods.',
            )
          else
            ...controller.paymentMethods
                .take(2)
                .map(
                  (method) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: WalletPaymentMethodTile(
                      method: method,
                      onTap: _openPaymentMethods,
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.softTeal,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, color: AppTheme.primary),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'Your wallet activity is protected. Real payments will '
                    'be processed through verified payment providers.',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.softTeal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textDark,
        fontSize: 19,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  final String title;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SectionTitle(title: title)),
        TextButton(onPressed: onTap, child: Text(actionText)),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletErrorState extends StatelessWidget {
  const _WalletErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 58,
              color: AppTheme.danger,
            ),
            const SizedBox(height: 14),
            const Text(
              'Wallet unavailable',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
