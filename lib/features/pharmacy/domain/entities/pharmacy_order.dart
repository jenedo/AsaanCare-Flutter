import 'cart_item.dart';

enum PharmacyPaymentMethod {
  asaancareWallet,
  easypaisa,
  jazzCash,
  card,
  cashOnDelivery,
}

extension PharmacyPaymentMethodX on PharmacyPaymentMethod {
  String get label {
    return switch (this) {
      PharmacyPaymentMethod.asaancareWallet => 'AsaanCare Wallet',
      PharmacyPaymentMethod.easypaisa => 'Easypaisa',
      PharmacyPaymentMethod.jazzCash => 'JazzCash',
      PharmacyPaymentMethod.card => 'Credit / Debit Card',
      PharmacyPaymentMethod.cashOnDelivery => 'Cash on Delivery',
    };
  }

  String get subtitle {
    return switch (this) {
      PharmacyPaymentMethod.asaancareWallet => 'Demo balance: Rs. 850',
      PharmacyPaymentMethod.easypaisa => 'Mobile wallet',
      PharmacyPaymentMethod.jazzCash => 'Mobile wallet',
      PharmacyPaymentMethod.card => 'Visa or Mastercard',
      PharmacyPaymentMethod.cashOnDelivery => 'Pay when delivered',
    };
  }
}

enum PharmacyOrderStage {
  confirmed,
  paymentSuccessful,
  accepted,
  preparing,
  packed,
  outForDelivery,
  delivered,
}

extension PharmacyOrderStageX on PharmacyOrderStage {
  String get label {
    return switch (this) {
      PharmacyOrderStage.confirmed => 'Order Confirmed',
      PharmacyOrderStage.paymentSuccessful => 'Payment Successful',
      PharmacyOrderStage.accepted => 'Order Accepted',
      PharmacyOrderStage.preparing => 'Preparing Your Order',
      PharmacyOrderStage.packed => 'Packed',
      PharmacyOrderStage.outForDelivery => 'Out for Delivery',
      PharmacyOrderStage.delivered => 'Delivered',
    };
  }
}

class PharmacyOrder {
  const PharmacyOrder({
    required this.id,
    required this.patientId,
    required this.items,
    required this.deliveryAddress,
    required this.pharmacyName,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.createdAt,
    required this.stage,
  });

  final String id;
  final String patientId;
  final List<CartItem> items;
  final String deliveryAddress;
  final String pharmacyName;
  final PharmacyPaymentMethod paymentMethod;
  final int subtotal;
  final int deliveryFee;
  final int discount;
  final int total;
  final DateTime createdAt;
  final PharmacyOrderStage stage;

  List<PharmacyOrderStage> get stagePath {
    if (paymentMethod == PharmacyPaymentMethod.cashOnDelivery) {
      return const [
        PharmacyOrderStage.confirmed,
        PharmacyOrderStage.accepted,
        PharmacyOrderStage.preparing,
        PharmacyOrderStage.packed,
        PharmacyOrderStage.outForDelivery,
        PharmacyOrderStage.delivered,
      ];
    }

    return const [
      PharmacyOrderStage.paymentSuccessful,
      PharmacyOrderStage.accepted,
      PharmacyOrderStage.preparing,
      PharmacyOrderStage.packed,
      PharmacyOrderStage.outForDelivery,
      PharmacyOrderStage.delivered,
    ];
  }

  PharmacyOrder copyWith({PharmacyOrderStage? stage}) {
    return PharmacyOrder(
      id: id,
      patientId: patientId,
      items: items,
      deliveryAddress: deliveryAddress,
      pharmacyName: pharmacyName,
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      createdAt: createdAt,
      stage: stage ?? this.stage,
    );
  }
}
