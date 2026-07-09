import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/wallet_controller.dart';
import '../utils/wallet_formatters.dart';
import 'wallet_payment_method_tile.dart';

class AddMoneySheet extends StatefulWidget {
  const AddMoneySheet({
    super.key,
    required this.controller,
    required this.patientId,
  });

  final WalletController controller;
  final String patientId;

  @override
  State<AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<AddMoneySheet> {
  static const _presetAmounts = [500, 1000, 2000, 5000];

  final TextEditingController _customAmountController = TextEditingController();

  int? _selectedAmount = 1000;
  String? _selectedPaymentMethodId;
  String? _localError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethodId = widget.controller.defaultPaymentMethod?.id;
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount =
        _selectedAmount ?? int.tryParse(_customAmountController.text.trim());

    if (amount == null || amount < 100) {
      setState(() {
        _localError = 'Enter an amount of at least Rs. 100.';
      });
      return;
    }

    final paymentMethodId = _selectedPaymentMethodId;

    if (paymentMethodId == null || paymentMethodId.isEmpty) {
      setState(() {
        _localError = 'Select a payment method.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _localError = null;
    });

    final success = await widget.controller.addMoney(
      patientId: widget.patientId,
      amount: amount,
      paymentMethodId: paymentMethodId,
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
    final methods = widget.controller.paymentMethods;

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
                'Add Money',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose an amount and a saved payment method.',
                style: TextStyle(color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final amount in _presetAmounts)
                    ChoiceChip(
                      label: Text(formatWalletRupees(amount)),
                      selected: _selectedAmount == amount,
                      onSelected: (_) {
                        setState(() {
                          _selectedAmount = amount;
                          _customAmountController.clear();
                          _localError = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _customAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  labelText: 'Custom amount',
                  prefixText: 'Rs. ',
                  hintText: 'Minimum 100',
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedAmount = null;
                    _localError = null;
                  });
                },
              ),
              const SizedBox(height: 22),
              const Text(
                'Payment method',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (methods.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6E6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Add a payment method before topping up your wallet.',
                    style: TextStyle(
                      color: Color(0xFF7A4B00),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                ...methods.map(
                  (method) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: WalletPaymentMethodTile(
                      method: method,
                      onTap: () {
                        setState(() {
                          _selectedPaymentMethodId = method.id;
                          _localError = null;
                        });
                      },
                      trailing: Icon(
                        _selectedPaymentMethodId == method.id
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: _selectedPaymentMethodId == method.id
                            ? AppTheme.primary
                            : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              if (_localError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _localError!,
                  style: const TextStyle(
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSubmitting || methods.isEmpty ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_card_rounded),
                  label: Text(
                    _isSubmitting ? 'Adding money...' : 'Confirm Top-up',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Demo mode: no real payment will be processed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
