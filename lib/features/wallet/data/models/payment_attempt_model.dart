class PaymentAttemptModel {
  final String id;
  final String? orderId;
  final String provider;
  final String status;
  final int amountMinor;
  final String currency;
  final String? providerRef;
  final String? redirectUrl;
  final String idempotencyKey;
  final DateTime createdAt;

  const PaymentAttemptModel({
    required this.id,
    this.orderId,
    required this.provider,
    required this.status,
    required this.amountMinor,
    required this.currency,
    this.providerRef,
    this.redirectUrl,
    required this.idempotencyKey,
    required this.createdAt,
  });

  factory PaymentAttemptModel.fromJson(Map<String, dynamic> json) {
    return PaymentAttemptModel(
      id: (json['paymentId'] ?? json['id']) as String? ?? '',
      orderId: json['orderId'] as String?,
      provider: json['provider'] as String? ?? 'SANDBOX',
      status: json['status'] as String? ?? 'PENDING',
      amountMinor: (json['amountMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'PKR',
      providerRef: json['providerRef'] as String?,
      redirectUrl: json['redirectUrl'] as String?,
      idempotencyKey: json['idempotencyKey'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'provider': provider,
      'status': status,
      'amountMinor': amountMinor,
      'currency': currency,
      'providerRef': providerRef,
      'redirectUrl': redirectUrl,
      'idempotencyKey': idempotencyKey,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
