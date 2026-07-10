import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../controllers/wallet_controller.dart';
import '../utils/wallet_formatters.dart';
import '../widgets/wallet_transaction_tile.dart';

enum _TransactionFilter { all, credits, payments, refunds }

class WalletTransactionsScreen extends StatefulWidget {
  const WalletTransactionsScreen({
    super.key,
    required this.controller,
    required this.patientId,
  });

  final WalletController controller;
  final String patientId;

  @override
  State<WalletTransactionsScreen> createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  _TransactionFilter _selectedFilter = _TransactionFilter.all;

  List<WalletTransaction> get _filteredTransactions {
    final query = _searchController.text.trim().toLowerCase();

    return widget.controller.transactions
        .where((transaction) {
          final matchesFilter = switch (_selectedFilter) {
            _TransactionFilter.all => true,
            _TransactionFilter.credits => transaction.isCredit,
            _TransactionFilter.payments =>
              transaction.type == WalletTransactionType.payment,
            _TransactionFilter.refunds =>
              transaction.type == WalletTransactionType.refund,
          };

          final matchesSearch =
              query.isEmpty ||
              transaction.title.toLowerCase().contains(query) ||
              transaction.description.toLowerCase().contains(query) ||
              transaction.referenceId.toLowerCase().contains(query);

          return matchesFilter && matchesSearch;
        })
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    _searchController.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showDetails(WalletTransaction transaction) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final prefix = transaction.isCredit ? '+' : '-';
        final maximumHeight = MediaQuery.sizeOf(sheetContext).height * 0.85;

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maximumHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    transaction.isCredit
                        ? Icons.add_circle_outline_rounded
                        : Icons.payments_outlined,
                    size: 50,
                    color: transaction.isCredit
                        ? AppTheme.success
                        : AppTheme.primary,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    transaction.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$prefix ${formatWalletRupees(transaction.amount)}',
                    style: TextStyle(
                      color: transaction.isCredit
                          ? AppTheme.success
                          : AppTheme.textDark,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DetailRow(label: 'Status', value: transaction.status.label),
                  _DetailRow(label: 'Type', value: transaction.type.label),
                  _DetailRow(
                    label: 'Date',
                    value: formatWalletDate(transaction.createdAt),
                  ),
                  _DetailRow(
                    label: 'Reference',
                    value: transaction.referenceId,
                  ),
                  _DetailRow(
                    label: 'Description',
                    value: transaction.description,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _filteredTransactions;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Transactions')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxMobileContentWidth,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppLayout.horizontalPadding(context),
                    10,
                    AppLayout.horizontalPadding(context),
                    0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search transactions or reference',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.horizontalPadding(context),
                    ),
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _selectedFilter == _TransactionFilter.all,
                        onTap: () {
                          setState(() {
                            _selectedFilter = _TransactionFilter.all;
                          });
                        },
                      ),
                      _FilterChip(
                        label: 'Credits',
                        selected: _selectedFilter == _TransactionFilter.credits,
                        onTap: () {
                          setState(() {
                            _selectedFilter = _TransactionFilter.credits;
                          });
                        },
                      ),
                      _FilterChip(
                        label: 'Payments',
                        selected:
                            _selectedFilter == _TransactionFilter.payments,
                        onTap: () {
                          setState(() {
                            _selectedFilter = _TransactionFilter.payments;
                          });
                        },
                      ),
                      _FilterChip(
                        label: 'Refunds',
                        selected: _selectedFilter == _TransactionFilter.refunds,
                        onTap: () {
                          setState(() {
                            _selectedFilter = _TransactionFilter.refunds;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () =>
                        widget.controller.refresh(widget.patientId),
                    child: transactions.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(30),
                            children: const [
                              SizedBox(height: 80),
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 54,
                                color: AppTheme.textMuted,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'No matching transactions',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.textDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              AppLayout.horizontalPadding(context),
                              8,
                              AppLayout.horizontalPadding(context),
                              28,
                            ),
                            itemCount: transactions.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];

                              return WalletTransactionTile(
                                transaction: transaction,
                                onTap: () => _showDetails(transaction),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
