class WalletAccount {
  const WalletAccount({
    required this.id,
    required this.patientId,
    required this.balance,
    required this.currencyCode,
    required this.updatedAt,
  });

  final String id;
  final String patientId;

  /// Stored as whole Pakistani rupees. Never use double for wallet money.
  final int balance;

  final String currencyCode;
  final DateTime updatedAt;

  WalletAccount copyWith({int? balance, DateTime? updatedAt}) {
    return WalletAccount(
      id: id,
      patientId: patientId,
      balance: balance ?? this.balance,
      currencyCode: currencyCode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
