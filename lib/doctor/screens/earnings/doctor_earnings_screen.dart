import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/theme/doctor_tokens.dart';
import '../../features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';
import '../../features/dashboard/presentation/controllers/doctor_dashboard_controller.dart';
import '../../features/finance/domain/entities/doctor_finance_snapshot.dart';
import '../../features/finance/presentation/controllers/doctor_finance_controller.dart';
import 'doctor_wallet_screen.dart';
import 'widgets/earnings_header.dart';
import 'widgets/earnings_summary_card.dart';
import 'widgets/earnings_tab_segment.dart';
import 'widgets/earnings_transactions_list.dart';
import 'widgets/open_wallet_tile.dart';

/// Doctor Earnings tab. Overview = summary + wallet tile; Transactions =
/// period-filtered ledger. Totals/growth come from [DoctorFinanceController];
/// pending amount is the sum of appointment fees with
/// [DoctorPaymentStatus.pending] in the selected period (when a dashboard
/// controller is provided).
class DoctorEarningsScreen extends StatefulWidget {
  const DoctorEarningsScreen({
    super.key,
    required this.controller,
    this.dashboardController,
  });

  final DoctorFinanceController controller;
  final DoctorDashboardController? dashboardController;

  @override
  State<DoctorEarningsScreen> createState() => _DoctorEarningsScreenState();
}

class _DoctorEarningsScreenState extends State<DoctorEarningsScreen> {
  EarningsTab _tab = EarningsTab.overview;
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
          : _EarningsBody(
              key: const ValueKey('doctor-earnings'),
              finance: widget.controller,
              dashboard: widget.dashboardController,
              tab: _tab,
              onTabChanged: (tab) => setState(() => _tab = tab),
              onWalletTap: () => setState(() => _showWallet = true),
            ),
    );
  }
}

class _EarningsBody extends StatelessWidget {
  const _EarningsBody({
    super.key,
    required this.finance,
    required this.dashboard,
    required this.tab,
    required this.onTabChanged,
    required this.onWalletTap,
  });

  final DoctorFinanceController finance;
  final DoctorDashboardController? dashboard;
  final EarningsTab tab;
  final ValueChanged<EarningsTab> onTabChanged;
  final VoidCallback onWalletTap;

  @override
  Widget build(BuildContext context) {
    final listenables = <Listenable>[finance];
    if (dashboard != null) listenables.add(dashboard!);

    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, _) {
        final snapshot = finance.snapshot;
        final pendingPkr = _pendingPaymentSum(
          dashboard: dashboard,
          range: finance.activeRange,
          fallback: snapshot?.pendingPayoutPkr ?? 0,
        );

        return ColoredBox(
          color: DoctorColors.background,
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: RefreshIndicator(
                  color: DoctorColors.primary,
                  onRefresh: finance.refresh,
                  child: CustomScrollView(
                    key: const PageStorageKey('doctor-earnings-scroll'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          MediaQuery.sizeOf(context).width > 600
                              ? 24
                              : DoctorSpacing.screenHorizontal,
                          16,
                          MediaQuery.sizeOf(context).width > 600
                              ? 24
                              : DoctorSpacing.screenHorizontal,
                          28,
                        ),
                        sliver: SliverList.list(
                          children: [
                            EarningsHeader(
                              periodLabel: finance.periodChipLabel,
                              selectedPeriod: finance.period,
                              onPeriodSelected: (period) =>
                                  _handlePeriodSelected(context, period),
                            ),
                            const SizedBox(height: 16),
                            EarningsTabSegment(
                              selected: tab,
                              onChanged: onTabChanged,
                            ),
                            const SizedBox(height: 16),
                            if (finance.isLoading && snapshot == null)
                              const _FinanceLoading()
                            else if (finance.status ==
                                    DoctorFinanceLoadStatus.failure &&
                                snapshot == null)
                              _FinanceFailure(
                                message:
                                    finance.errorMessage ??
                                    'Could not load earnings.',
                                onRetry: finance.refresh,
                              )
                            else if (snapshot == null)
                              const _FinanceLoading()
                            else
                              AnimatedSwitcher(
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                    ? Duration.zero
                                    : const Duration(milliseconds: 220),
                                child: tab == EarningsTab.overview
                                    ? _OverviewPane(
                                        key: const ValueKey(
                                          'earnings-overview',
                                        ),
                                        snapshot: snapshot,
                                        pendingPkr: pendingPkr,
                                        onWalletTap: onWalletTap,
                                      )
                                    : _TransactionsPane(
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
          ),
        );
      },
    );
  }

  Future<void> _handlePeriodSelected(
    BuildContext context,
    DoctorFinancePeriod period,
  ) async {
    if (period == DoctorFinancePeriod.custom) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 1)),
        initialDateRange: DateTimeRange(
          start:
              finance.customRange?.start ??
              DateTime.now().subtract(const Duration(days: 7)),
          end: finance.customRange?.end ?? DateTime.now(),
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(primary: DoctorColors.primary),
            ),
            child: child!,
          );
        },
      );
      if (picked == null) return;
      await finance.changePeriod(
        DoctorFinancePeriod.custom,
        customRange: FinanceDateRange(start: picked.start, end: picked.end),
      );
      return;
    }
    await finance.changePeriod(period);
  }
}

class _OverviewPane extends StatelessWidget {
  const _OverviewPane({
    super.key,
    required this.snapshot,
    required this.pendingPkr,
    required this.onWalletTap,
  });

  final DoctorFinanceSnapshot snapshot;
  final int pendingPkr;
  final VoidCallback onWalletTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EarningsSummaryCard(
          totalEarningsPkr: snapshot.totalEarningsPkr,
          consultationCount: snapshot.consultationCount,
          pendingPkr: pendingPkr,
          growthPercent: snapshot.growthPercent,
        ),
        const SizedBox(height: DoctorSpacing.cardGap),
        OpenWalletTile(onTap: onWalletTap),
      ],
    );
    if (MediaQuery.disableAnimationsOf(context)) return content;
    return content
        .animate()
        .fadeIn(duration: 220.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.02, end: 0, duration: 240.ms);
  }
}

class _TransactionsPane extends StatelessWidget {
  const _TransactionsPane({super.key, required this.transactions});

  final List<DoctorFinanceTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final content = EarningsTransactionsList(transactions: transactions);
    if (MediaQuery.disableAnimationsOf(context)) return content;
    return content
        .animate()
        .fadeIn(duration: 220.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.02, end: 0, duration: 240.ms);
  }
}

/// Pending amount = sum of appointment fees whose payment status is pending
/// and whose scheduled time falls in [range]. Falls back to the finance
/// snapshot's pending payout when no dashboard data is available.
int _pendingPaymentSum({
  required DoctorDashboardController? dashboard,
  required FinanceDateRange range,
  required int fallback,
}) {
  final appointments = dashboard?.snapshot?.appointments;
  if (appointments == null) return fallback;
  var total = 0;
  for (final appointment in appointments) {
    if (appointment.paymentStatus != DoctorPaymentStatus.pending) continue;
    if (!range.contains(appointment.scheduledAt) &&
        !range.contains(appointment.requestedAt)) {
      continue;
    }
    total += appointment.feePkr;
  }
  return total;
}

class _FinanceLoading extends StatelessWidget {
  const _FinanceLoading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _FinanceFailure extends StatelessWidget {
  const _FinanceFailure({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 42,
            color: DoctorColors.danger,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: DoctorColors.textPrimary),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
