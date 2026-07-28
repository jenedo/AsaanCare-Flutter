class WalletTransactionModel {
  final String id;
  final String walletId;
  final String type;
  final int amountMinor;
  final String currency;
  final int balanceAfter;
  final String description;
  final String? referenceType;
  final String? referenceId;
  final DateTime createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.balanceAfter,
    required this.description,
    this.referenceType,
    this.referenceId,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as String? ?? '',
      walletId: json['walletId'] as String? ?? '',
      type: json['type'] as String? ?? 'CREDIT',
      amountMinor: (json['amountMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'PKR',
      balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      referenceType: json['referenceType'] as String?,
      referenceId: json['referenceId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'type': type,
      'amountMinor': amountMinor,
      'currency': currency,
      'balanceAfter': balanceAfter,
      'description': description,
      'referenceType': referenceType,
      'referenceId': referenceId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
