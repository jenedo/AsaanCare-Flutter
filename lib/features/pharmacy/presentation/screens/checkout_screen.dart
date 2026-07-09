import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/layout/app_layout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/pharmacy_order.dart';
import '../controllers/pharmacy_controller.dart';
import 'order_tracking_screen.dart';

import '../widgets/checkout_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.controller});

  final PharmacyController controller;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
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
    if (mounted) setState(() {});
  }

  Future<void> _editAddress() async {
    final textController = TextEditingController(
      text: widget.controller.deliveryAddress,
    );

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delivery address'),
          content: TextField(
            controller: textController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter complete delivery address',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(textController.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    textController.dispose();

    if (value == null || !mounted) return;
    widget.controller.updateDeliveryAddress(value);
  }

  Future<void> _placeOrder() async {
    final validationError = widget.controller.checkoutValidationError;

    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    final patientId = sl<AuthController>().currentUser?.id.trim();

    if (patientId == null || patientId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session expired. Please login again.'),
        ),
      );
      return;
    }

    final order = await widget.controller.placeDemoOrder(patientId: patientId);

    if (!mounted) return;

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.errorMessage ?? 'Could not place order.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (context) =>
            OrderTrackingScreen(controller: widget.controller),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Checkout')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton.icon(
          onPressed: controller.isPlacingOrder || !controller.canCheckout
              ? null
              : _placeOrder,
          icon: controller.isPlacingOrder
              ? const SizedBox(
                  height: 19,
                  width: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.lock_outline_rounded),
          label: Text(
            controller.isPlacingOrder
                ? 'Placing order...'
                : 'Place Demo Order • Rs. ${controller.payableTotal}',
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxMobileContentWidth,
            ),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppLayout.horizontalPadding(context),
                10,
                AppLayout.horizontalPadding(context),
                110,
              ),
              children: [
                const CheckoutSectionTitle('Delivery Address'),
                const SizedBox(height: 10),
                CheckoutInformationCard(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  subtitle: controller.deliveryAddress,
                  actionText: 'Change',
                  onAction: _editAddress,
                ),
                const SizedBox(height: 22),
                const CheckoutSectionTitle('Choose Pharmacy'),
                const SizedBox(height: 10),
                CheckoutInformationCard(
                  icon: Icons.local_pharmacy_outlined,
                  title: controller.selectedPharmacy,
                  subtitle: '4.7 ★ • Approximately 30 min',
                  actionText: 'Change',
                  onAction: () {
                    controller.selectPharmacy(
                      controller.selectedPharmacy == 'MediPlus Pharmacy'
                          ? 'HealthPlus Pharmacy'
                          : 'MediPlus Pharmacy',
                    );
                  },
                ),
                const SizedBox(height: 22),
                const CheckoutSectionTitle('Payment Method'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Column(
                    children: [
                      for (final method in PharmacyPaymentMethod.values)
                        ListTile(
                          onTap: () {
                            controller.selectPaymentMethod(method);
                          },
                          leading: Icon(_paymentIcon(method)),
                          title: Text(method.label),
                          subtitle: Text(method.subtitle),
                          trailing: controller.selectedPaymentMethod == method
                              ? const Icon(
                                  Icons.radio_button_checked_rounded,
                                  color: AppTheme.primary,
                                )
                              : const Icon(
                                  Icons.radio_button_off_rounded,
                                  color: Color(0xFF8A95A6),
                                ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const CheckoutSectionTitle('Order Summary'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFA),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Column(
                    children: [
                      CheckoutSummaryRow(
                        label: 'Items (${controller.cartCount})',
                        value: controller.subtotal,
                      ),
                      CheckoutSummaryRow(
                        label: 'Delivery',
                        value: controller.deliveryFee,
                      ),
                      CheckoutSummaryRow(
                        label: 'Discount',
                        value: -controller.discount,
                      ),
                      const Divider(height: 24),
                      CheckoutSummaryRow(
                        label: 'Total Payable',
                        value: controller.payableTotal,
                        bold: true,
                      ),
                    ],
                  ),
                ),
                if (controller.checkoutValidationError != null) ...[
                  const SizedBox(height: 14),
                  CheckoutValidationBanner(
                    message: controller.checkoutValidationError!,
                  ),
                ],
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                    SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        'Demo checkout only. No real payment is processed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF657386),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _paymentIcon(PharmacyPaymentMethod method) {
  return switch (method) {
    PharmacyPaymentMethod.asaancareWallet =>
      Icons.account_balance_wallet_outlined,
    PharmacyPaymentMethod.easypaisa => Icons.phone_android_rounded,
    PharmacyPaymentMethod.jazzCash => Icons.mobile_friendly_rounded,
    PharmacyPaymentMethod.card => Icons.credit_card_rounded,
    PharmacyPaymentMethod.cashOnDelivery => Icons.payments_outlined,
  };
}
