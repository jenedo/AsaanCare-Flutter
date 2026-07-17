import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../features/finance/domain/entities/doctor_finance_snapshot.dart';
import '../../features/finance/presentation/controllers/doctor_finance_controller.dart';
import 'doctor_wallet_screen.dart';

class DoctorEarningsScreen extends StatefulWidget {
  const DoctorEarningsScreen({super.key, required this.controller});

  final DoctorFinanceController controller;

  @override
  State<DoctorEarningsScreen> createState() => _DoctorEarningsScreenState();
}

class _DoctorEarningsScreenState extends State<DoctorEarningsScreen> {
  _EarningsTab _tab = _EarningsTab.overview;
  bool _showWallet = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(.015, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: _showWallet
          ? DoctorWalletScreen(
              key: const ValueKey('doctor-wallet'),
              controller: widget.controller,
              onBack: () => setState(() => _showWallet = false),
            )
          : _EarningsContent(
              key: const ValueKey('doctor-earnings'),
              controller: widget.controller,
              tab: _tab,
              onTabChanged: (tab) => setState(() => _tab = tab),
              onWalletTap: () => setState(() => _showWallet = true),
            ),
    );
  }
}

class _EarningsContent extends StatelessWidget {
  const _EarningsContent({
    super.key,
    required this.controller,
    required this.tab,
    required this.onTabChanged,
    required this.onWalletTap,
  });

  final DoctorFinanceController controller;
  final _EarningsTab tab;
  final ValueChanged<_EarningsTab> onTabChanged;
  final VoidCallback onWalletTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final snapshot = controller.snapshot;
        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: CustomScrollView(
                  key: const PageStorageKey('doctor-earnings-scroll'),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      sliver: SliverList.list(
                        children: [
                          _TopBar(
                            period: controller.period,
                            onPeriodTap: () => _choosePeriod(context),
                          ),
                          const SizedBox(height: 16),
                          _Tabs(selected: tab, onChanged: onTabChanged),
                          const SizedBox(height: 16),
                          if (controller.isLoading && snapshot == null)
                            const _FinanceLoading()
                          else if (controller.status ==
                                  DoctorFinanceLoadStatus.failure &&
                              snapshot == null)
                            _FinanceFailure(
                              message:
                                  controller.errorMessage ??
                                  'Could not load earnings.',
                              onRetry: controller.refresh,
                            )
                          else if (snapshot == null)
                            const _FinanceLoading()
                          else
                            AnimatedSwitcher(
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 220),
                              child: tab == _EarningsTab.overview
                                  ? _Overview(
                                      key: const ValueKey('earnings-overview'),
                                      snapshot: snapshot,
                                      onWalletTap: onWalletTap,
                                    )
                                  : _Transactions(
                                      key: const ValueKey(
                                        'earnings-transactions',
                                      ),
                                      transactions: snapshot.transactions,
                                    ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _choosePeriod(BuildContext context) async {
    final selected = await showModalBottomSheet<DoctorFinancePeriod>(
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
                'Choose earnings period',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              for (final period in DoctorFinancePeriod.values)
                ListTile(
                  leading: Icon(
                    period == controller.period
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: period == controller.period
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(period.label),
                  onTap: () => Navigator.pop(context, period),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) await controller.changePeriod(selected);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.period, required this.onPeriodTap});
  final DoctorFinancePeriod period;
  final VoidCallback onPeriodTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          'Earnings',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      OutlinedButton.icon(
        key: const ValueKey('earnings-period-control'),
        onPressed: onPeriodTap,
        icon: const Icon(Icons.calendar_month_outlined, size: 18),
        label: Text(period.label),
      ),
    ],
  );
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selected, required this.onChanged});
  final _EarningsTab selected;
  final ValueChanged<_EarningsTab> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<_EarningsTab>(
    segments: const [
      ButtonSegment(
        value: _EarningsTab.overview,
        icon: Icon(Icons.bar_chart_rounded),
        label: Text('Overview'),
      ),
      ButtonSegment(
        value: _EarningsTab.transactions,
        icon: Icon(Icons.receipt_long_rounded),
        label: Text('Transactions'),
      ),
    ],
    selected: {selected},
    showSelectedIcon: false,
    onSelectionChanged: (values) => onChanged(values.first),
  );
}

class _Overview extends StatelessWidget {
  const _Overview({
    super.key,
    required this.snapshot,
    required this.onWalletTap,
  });
  final DoctorFinanceSnapshot snapshot;
  final VoidCallback onWalletTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF087D72), Color(0xFF0B9E98)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total earnings',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 7),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatPkr(snapshot.totalEarningsPkr),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  _HeroMetric(
                    label: 'Consultations',
                    value: '${snapshot.consultationCount}',
                  ),
                  _HeroMetric(
                    label: 'Pending',
                    value: formatPkr(snapshot.pendingPayoutPkr),
                  ),
                  _HeroMetric(
                    label: 'Growth',
                    value: '+${snapshot.growthPercent.toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Material(
          color: colors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colors.outlineVariant.withValues(alpha: .55),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onWalletTap,
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  CircleAvatar(
                    child: Icon(Icons.account_balance_wallet_rounded),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open wallet',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text('View balance, withdrawals and payouts'),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Earnings summary',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        _SummaryGrid(snapshot: snapshot),
        const SizedBox(height: 22),
        Text(
          'Earnings breakdown',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        _BreakdownCard(snapshot: snapshot),
        const SizedBox(height: 22),
        Text(
          'Recent transactions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        _TransactionCard(transactions: snapshot.transactions.take(3).toList()),
      ],
    );
    if (MediaQuery.disableAnimationsOf(context)) return content;
    return content
        .animate()
        .fadeIn(duration: 220.ms)
        .slideY(begin: .02, duration: 240.ms);
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ],
  );
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.snapshot});
  final DoctorFinanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.account_balance_wallet_rounded,
        'Available balance',
        snapshot.availableBalancePkr,
      ),
      (Icons.schedule_rounded, 'Pending payout', snapshot.pendingPayoutPkr),
      (Icons.payments_outlined, 'Withdrawn', snapshot.withdrawnPkr),
      (Icons.receipt_long_outlined, 'Platform fees', snapshot.platformFeesPkr),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: columns == 4 ? 1.25 : 1.15,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.$1, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 9),
                  FittedBox(
                    child: Text(
                      formatPkr(item.$3),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    item.$2,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.snapshot});
  final DoctorFinanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        for (var index = 0; index < snapshot.breakdown.length; index++) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  snapshot.breakdown[index].label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                formatPkr(snapshot.breakdown[index].amountPkr),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: snapshot.breakdown[index].share,
            minHeight: 6,
            borderRadius: BorderRadius.circular(99),
          ),
          if (index < snapshot.breakdown.length - 1) const SizedBox(height: 15),
        ],
      ],
    ),
  );
}

class _Transactions extends StatelessWidget {
  const _Transactions({super.key, required this.transactions});
  final List<DoctorFinanceTransaction> transactions;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Transaction history',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      const Text('A read-only ledger of earnings, fees and payouts.'),
      const SizedBox(height: 14),
      _TransactionCard(transactions: transactions),
    ],
  );
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transactions});
  final List<DoctorFinanceTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No transactions yet'),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var index = 0; index < transactions.length; index++) ...[
            _TransactionTile(transaction: transactions[index]),
            if (index < transactions.length - 1) const Divider(height: 1),
          ],
        ],
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
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      leading: CircleAvatar(
        backgroundColor: (positive ? colors.primary : colors.error).withValues(
          alpha: .12,
        ),
        child: Icon(
          positive ? Icons.south_west_rounded : Icons.north_east_rounded,
          color: positive ? colors.primary : colors.error,
        ),
      ),
      title: Text(
        transaction.title,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text('${transaction.subtitle} · ${transaction.status.label}'),
      trailing: Text(
        formatPkr(transaction.amountPkr),
        style: TextStyle(
          color: positive ? colors.primary : colors.error,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FinanceLoading extends StatelessWidget {
  const _FinanceLoading();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(48),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _FinanceFailure extends StatelessWidget {
  const _FinanceFailure({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: [
        Text(message),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      ],
    ),
  );
}

enum _EarningsTab { overview, transactions }
