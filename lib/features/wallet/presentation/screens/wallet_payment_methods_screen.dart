import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/wallet_payment_method.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/wallet_payment_method_tile.dart';

class WalletPaymentMethodsScreen extends StatefulWidget {
  const WalletPaymentMethodsScreen({
    super.key,
    required this.controller,
    required this.patientId,
  });

  final WalletController controller;
  final String patientId;

  @override
  State<WalletPaymentMethodsScreen> createState() =>
      _WalletPaymentMethodsScreenState();
}

class _WalletPaymentMethodsScreenState
    extends State<WalletPaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
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

  Future<void> _openAddMethod() async {
    widget.controller.clearMessages();

    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _AddPaymentMethodSheet(
          controller: widget.controller,
          patientId: widget.patientId,
        );
      },
    );

    if (!mounted || added != true) return;

    _showMessage(widget.controller.successMessage ?? 'Payment method added.');
    widget.controller.clearMessages();
  }

  Future<void> _setDefault(WalletPaymentMethod method) async {
    final success = await widget.controller.setDefaultPaymentMethod(
      patientId: widget.patientId,
      paymentMethodId: method.id,
    );

    if (!mounted) return;

    _showMessage(
      success
          ? widget.controller.successMessage ??
                'Default payment method updated.'
          : widget.controller.errorMessage ??
                'Could not update the payment method.',
      isError: !success,
    );

    widget.controller.clearMessages();
  }

  Future<void> _remove(WalletPaymentMethod method) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove payment method?'),
          content: Text('Remove ${method.displayName} ${method.maskedValue}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await widget.controller.removePaymentMethod(
      patientId: widget.patientId,
      paymentMethodId: method.id,
    );

    if (!mounted) return;

    _showMessage(
      success
          ? widget.controller.successMessage ?? 'Payment method removed.'
          : widget.controller.errorMessage ??
                'Could not remove the payment method.',
      isError: !success,
    );

    widget.controller.clearMessages();
  }

  @override
  Widget build(BuildContext context) {
    final methods = widget.controller.paymentMethods;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Payment Methods')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.controller.isUpdatingPaymentMethods
            ? null
            : _openAddMethod,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add method'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxMobileContentWidth,
            ),
            child: methods.isEmpty
                ? const _EmptyMethods()
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.horizontalPadding(context),
                      14,
                      AppLayout.horizontalPadding(context),
                      100,
                    ),
                    children: [
                      const Text(
                        'Saved methods',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Only masked account information is stored in '
                        'this demo.',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final method in methods)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: WalletPaymentMethodTile(
                            method: method,
                            trailing: PopupMenuButton<String>(
                              tooltip: 'Payment method actions',
                              onSelected: (action) {
                                if (action == 'default') {
                                  _setDefault(method);
                                } else if (action == 'remove') {
                                  _remove(method);
                                }
                              },
                              itemBuilder: (context) => [
                                if (!method.isDefault)
                                  const PopupMenuItem(
                                    value: 'default',
                                    child: Text('Set as default'),
                                  ),
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Remove'),
                                ),
                              ],
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

class _AddPaymentMethodSheet extends StatefulWidget {
  const _AddPaymentMethodSheet({
    required this.controller,
    required this.patientId,
  });

  final WalletController controller;
  final String patientId;

  @override
  State<_AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<_AddPaymentMethodSheet> {
  final TextEditingController _lastFourController = TextEditingController();

  WalletPaymentMethodType _selectedType = WalletPaymentMethodType.card;

  bool _setAsDefault = false;
  bool _isSubmitting = false;
  String? _localError;

  @override
  void dispose() {
    _lastFourController.dispose();
    super.dispose();
  }

  String get _displayName {
    return switch (_selectedType) {
      WalletPaymentMethodType.card => 'Debit / Credit Card',
      WalletPaymentMethodType.bankTransfer => 'Bank account',
      WalletPaymentMethodType.easypaisa => 'Easypaisa',
      WalletPaymentMethodType.jazzCash => 'JazzCash',
    };
  }

  String _maskedValue(String lastFour) {
    return switch (_selectedType) {
      WalletPaymentMethodType.card => '**** $lastFour',
      WalletPaymentMethodType.bankTransfer => 'PK** **** $lastFour',
      WalletPaymentMethodType.easypaisa => '03** ***$lastFour',
      WalletPaymentMethodType.jazzCash => '03** ***$lastFour',
    };
  }

  Future<void> _submit() async {
    final lastFour = _lastFourController.text.trim();

    if (lastFour.length != 4) {
      setState(() {
        _localError = 'Enter exactly the last 4 digits.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _localError = null;
    });

    final success = await widget.controller.addPaymentMethod(
      patientId: widget.patientId,
      type: _selectedType,
      displayName: _displayName,
      maskedValue: _maskedValue(lastFour),
      setAsDefault: _setAsDefault,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _localError = widget.controller.errorMessage;
    });

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Payment Method',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in WalletPaymentMethodType.values)
                    ChoiceChip(
                      avatar: Icon(walletPaymentMethodIcon(type), size: 18),
                      label: Text(type.title),
                      selected: _selectedType == type,
                      onSelected: (_) {
                        setState(() {
                          _selectedType = type;
                          _localError = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lastFourController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  labelText: 'Last 4 digits only',
                  hintText: '1234',
                  helperText:
                      'Never enter a full card, phone or account number.',
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _setAsDefault,
                onChanged: (value) {
                  setState(() {
                    _setAsDefault = value ?? false;
                  });
                },
                title: const Text('Set as default payment method'),
              ),
              if (_localError != null)
                Text(
                  _localError!,
                  style: const TextStyle(
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSubmitting ? 'Saving...' : 'Save payment method',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMethods extends StatelessWidget {
  const _EmptyMethods();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.credit_card_off_outlined,
              size: 56,
              color: AppTheme.textMuted,
            ),
            SizedBox(height: 14),
            Text(
              'No payment methods',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add a masked payment method to top up your wallet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
