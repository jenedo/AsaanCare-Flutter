import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../features/finance/domain/entities/doctor_finance_snapshot.dart';
import '../../features/finance/presentation/controllers/doctor_finance_controller.dart';

class DoctorWalletScreen extends StatelessWidget {
  const DoctorWalletScreen({
    super.key,
    required this.controller,
    required this.onBack,
  });

  final DoctorFinanceController controller;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final snapshot = controller.snapshot;
        if (controller.isLoading && snapshot == null) {
          return const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot == null) {
          return SafeArea(
            child: Center(
              child: FilledButton.icon(
                onPressed: controller.refresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry wallet'),
              ),
            ),
          );
        }

        final content = SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: CustomScrollView(
                key: const PageStorageKey('doctor-wallet-scroll'),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    sliver: SliverList.list(
                      children: [
                        _WalletHeader(
                          onBack: onBack,
                          onFilter: () => _chooseFilter(context),
                        ),
                        const SizedBox(height: 14),
                        _BalanceHero(snapshot: snapshot),
                        const SizedBox(height: 14),
                        _WalletActions(
                          onWithdraw: () => _showSafeAction(
                            context,
                            title: 'Withdraw funds',
                            message: 'Backend verification required',
                            detail:
                                'Withdrawals remain locked until payout account verification, balance checks, audit logging, and idempotent server APIs are connected.',
                          ),
                          onTransfer: () => _showSafeAction(
                            context,
                            title: 'Transfer funds',
                            message: 'Transfers are not enabled in demo mode.',
                            detail:
                                'A verified recipient, authenticated doctor session, rate limits, and server-side ledger entries are required before money can move.',
                          ),
                          onPaymentMethods: () =>
                              _showPaymentMethods(context, snapshot),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(controller.walletFilter.label),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _SectionTitle('Balance details'),
                        const SizedBox(height: 8),
                        _Panel(
                          child: Column(
                            children: [
                              _BalanceRow(
                                'Total earnings',
                                snapshot.totalEarningsPkr,
                              ),
                              const Divider(),
                              _BalanceRow(
                                'Withdrawn amount',
                                snapshot.withdrawnPkr,
                              ),
                              const Divider(),
                              _BalanceRow(
                                'Pending payout',
                                snapshot.pendingPayoutPkr,
                              ),
                              const Divider(),
                              _BalanceRow(
                                'Available balance',
                                snapshot.availableBalancePkr,
                                emphasize: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _SectionTitle('Payment methods'),
                        const SizedBox(height: 8),
                        _Panel(
                          child: Column(
                            children: snapshot.payoutMethods
                                .map(
                                  (method) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    onTap: () =>
                                        _showPaymentMethods(context, snapshot),
                                    leading: const CircleAvatar(
                                      child: Icon(
                                        Icons.account_balance_rounded,
                                      ),
                                    ),
                                    title: Text(
                                      '${method.label} ${method.maskedDetails}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    subtitle: Text(
                                      method.isVerified
                                          ? 'Verified'
                                          : 'Verification required',
                                    ),
                                    trailing: method.isPrimary
                                        ? const Chip(label: Text('Primary'))
                                        : const Icon(
                                            Icons.chevron_right_rounded,
                                          ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _SectionTitle('Recent wallet activity'),
                        const SizedBox(height: 8),
                        _ActivityPanel(
                          transactions: controller.filteredTransactions,
                        ),
                        const SizedBox(height: 20),
                        _NextPayout(nextPayoutAt: snapshot.nextPayoutAt),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        if (MediaQuery.disableAnimationsOf(context)) return content;
        return content
            .animate()
            .fadeIn(duration: 220.ms)
            .slideX(begin: .015, duration: 240.ms);
      },
    );
  }

  Future<void> _chooseFilter(BuildContext context) async {
    final selected = await showModalBottomSheet<DoctorWalletFilter>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter wallet activity',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              for (final filter in DoctorWalletFilter.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    filter == controller.walletFilter
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                  ),
                  title: Text(filter.label),
                  onTap: () => Navigator.pop(context, filter),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) controller.selectWalletFilter(selected);
  }

  void _showSafeAction(
    BuildContext context, {
    required String title,
    required String message,
    required String detail,
  }) {
    final closeLabel = title.toLowerCase().split(' ').first;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close $closeLabel',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(detail),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.lock_outline_rounded),
                  label: Text('Waiting for verified payout API'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentMethods(
    BuildContext context,
    DoctorFinanceSnapshot snapshot,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Manage payment methods',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close payment methods',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              for (final method in snapshot.payoutMethods)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.account_balance_rounded),
                  ),
                  title: Text('${method.label} ${method.maskedDetails}'),
                  subtitle: Text(
                    method.isVerified ? 'Verified' : 'Verification required',
                  ),
                  trailing: method.isPrimary
                      ? const Chip(label: Text('Primary'))
                      : null,
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.add_rounded),
                  label: Text('Add payment method'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.onBack, required this.onFilter});
  final VoidCallback onBack;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: 'Back to earnings',
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      Expanded(
        child: Text(
          'Wallet',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      IconButton(
        tooltip: 'Filter wallet activity',
        onPressed: onFilter,
        icon: const Icon(Icons.tune_rounded),
      ),
    ],
  );
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({required this.snapshot});
  final DoctorFinanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF087D72), Color(0xFF0B9E98)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available balance',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 7),
              FittedBox(
                child: Text(
                  formatPkr(snapshot.availableBalancePkr),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '+${snapshot.growthPercent.toStringAsFixed(1)}% this period',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.account_balance_wallet_rounded,
          size: 64,
          color: Colors.white70,
        ),
      ],
    ),
  );
}

class _WalletActions extends StatelessWidget {
  const _WalletActions({
    required this.onWithdraw,
    required this.onTransfer,
    required this.onPaymentMethods,
  });
  final VoidCallback onWithdraw;
  final VoidCallback onTransfer;
  final VoidCallback onPaymentMethods;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.account_balance_rounded, 'Withdraw', onWithdraw),
      (Icons.sync_alt_rounded, 'Transfer', onTransfer),
      (Icons.credit_card_rounded, 'Payment methods', onPaymentMethods),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700
            ? 3
            : constraints.maxWidth >= 430
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: actions
              .map(
                (action) => SizedBox(
                  width: width,
                  child: Material(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: action.$3,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            CircleAvatar(child: Icon(action.$1)),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                action.$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
  );
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow(this.label, this.amount, {this.emphasize = false});
  final String label;
  final int amount;
  final bool emphasize;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          formatPkr(amount),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: emphasize ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    ),
  );
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({required this.transactions});
  final List<DoctorFinanceTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const _Panel(child: Center(child: Text('No matching activity')));
    }
    return _Panel(
      child: Column(
        children: [
          for (var index = 0; index < transactions.length; index++) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Icon(
                  transactions[index].amountPkr >= 0
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                ),
              ),
              title: Text(
                transactions[index].title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(transactions[index].status.label),
              trailing: Text(
                formatPkr(transactions[index].amountPkr),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            if (index < transactions.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _NextPayout extends StatelessWidget {
  const _NextPayout({required this.nextPayoutAt});
  final DateTime? nextPayoutAt;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.event_available_rounded),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            nextPayoutAt == null
                ? 'No payout scheduled yet.'
                : 'Next payout: ${nextPayoutAt!.day}/${nextPayoutAt!.month}/${nextPayoutAt!.year}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: .55),
      ),
    ),
    child: Padding(padding: const EdgeInsets.all(15), child: child),
  );
}
