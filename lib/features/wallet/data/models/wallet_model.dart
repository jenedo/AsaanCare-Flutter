class WalletModel {
  final String id;
  final String userId;
  final String currency;
  final int balanceMinor;

  const WalletModel({
    required this.id,
    required this.userId,
    required this.currency,
    required this.balanceMinor,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      currency: json['currency'] as String? ?? 'PKR',
      balanceMinor: (json['balanceMinor'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'currency': currency,
      'balanceMinor': balanceMinor,
    };
  }
}
