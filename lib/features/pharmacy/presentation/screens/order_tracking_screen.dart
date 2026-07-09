import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/pharmacy_order.dart';
import '../controllers/pharmacy_controller.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.controller});

  final PharmacyController controller;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
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

  @override
  Widget build(BuildContext context) {
    final order = widget.controller.activeOrder;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('My Order')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxMobileContentWidth,
            ),
            child: order == null
                ? _NoOrder(
                    onHome: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.patientHome,
                        (route) => false,
                      );
                    },
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.horizontalPadding(context),
                      12,
                      AppLayout.horizontalPadding(context),
                      24,
                    ),
                    children: [
                      Text(
                        'Order ID: #${order.id}',
                        style: const TextStyle(
                          color: Color(0xFF657386),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF019A73), Color(0xFF007A64)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0x33FFFFFF),
                              child: Icon(
                                Icons.local_shipping_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.stage.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Estimated delivery: approximately 30 minutes',
                                    style: TextStyle(
                                      color: Color(0xE6FFFFFF),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      for (
                        var index = 0;
                        index < order.stagePath.length;
                        index++
                      )
                        _TimelineItem(
                          stage: order.stagePath[index],
                          currentStage: order.stage,
                          isLast: index == order.stagePath.length - 1,
                        ),
                      const SizedBox(height: 20),
                      _OrderPharmacyCard(order: order),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: order.stage == PharmacyOrderStage.delivered
                            ? null
                            : widget.controller.advanceDemoOrder,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Advance Demo Status'),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.patientHome,
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Back to Home'),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Production status will come from the NestJS Pharmacy/Order service through authenticated APIs and payment webhooks.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF657386),
                          fontSize: 11.5,
                          height: 1.4,
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

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.stage,
    required this.currentStage,
    required this.isLast,
  });

  final PharmacyOrderStage stage;
  final PharmacyOrderStage currentStage;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final stageIndex = PharmacyOrderStage.values.indexOf(stage);
    final currentIndex = PharmacyOrderStage.values.indexOf(currentStage);
    final completed = stageIndex <= currentIndex;
    final current = stage == currentStage;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34,
          child: Column(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: completed
                    ? AppTheme.primary
                    : const Color(0xFFE4E9EF),
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      )
                    : null,
              ),
              if (!isLast)
                Container(
                  height: 42,
                  width: 2,
                  color: completed ? AppTheme.primary : const Color(0xFFE4E9EF),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              stage.label,
              style: TextStyle(
                color: current
                    ? AppTheme.primary
                    : completed
                    ? const Color(0xFF07132D)
                    : const Color(0xFF8A95A6),
                fontWeight: current || completed
                    ? FontWeight.w900
                    : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderPharmacyCard extends StatelessWidget {
  const _OrderPharmacyCard({required this.order});

  final PharmacyOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppTheme.softTeal,
            child: Icon(Icons.local_pharmacy_outlined, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.pharmacyName,
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.items.length} products • Rs. ${order.total}',
                  style: const TextStyle(color: Color(0xFF657386)),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Call pharmacy',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Calling a pharmacy requires the verified contact API.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.call_outlined),
          ),
        ],
      ),
    );
  }
}

class _NoOrder extends StatelessWidget {
  const _NoOrder({required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              color: AppTheme.primary,
              size: 58,
            ),
            const SizedBox(height: 14),
            const Text(
              'No active pharmacy order',
              style: TextStyle(
                color: Color(0xFF07132D),
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onHome, child: const Text('Back to Home')),
          ],
        ),
      ),
    );
  }
}
