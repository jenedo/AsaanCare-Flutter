enum WalletPaymentMethodType { card, bankTransfer, easypaisa, jazzCash }

extension WalletPaymentMethodTypeX on WalletPaymentMethodType {
  String get title {
    return switch (this) {
      WalletPaymentMethodType.card => 'Debit / Credit Card',
      WalletPaymentMethodType.bankTransfer => 'Bank Transfer',
      WalletPaymentMethodType.easypaisa => 'Easypaisa',
      WalletPaymentMethodType.jazzCash => 'JazzCash',
    };
  }
}

class WalletPaymentMethod {
  const WalletPaymentMethod({
    required this.id,
    required this.patientId,
    required this.type,
    required this.displayName,
    required this.maskedValue,
    required this.isDefault,
  });

  final String id;
  final String patientId;
  final WalletPaymentMethodType type;
  final String displayName;

  /// Only masked information is stored. Never store full card/account details.
  final String maskedValue;

  final bool isDefault;

  WalletPaymentMethod copyWith({bool? isDefault}) {
    return WalletPaymentMethod(
      id: id,
      patientId: patientId,
      type: type,
      displayName: displayName,
      maskedValue: maskedValue,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
