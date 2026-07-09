enum WalletTransactionType { topUp, payment, refund }

extension WalletTransactionTypeX on WalletTransactionType {
  String get label {
    return switch (this) {
      WalletTransactionType.topUp => 'Top-up',
      WalletTransactionType.payment => 'Payment',
      WalletTransactionType.refund => 'Refund',
    };
  }

  bool get isCredit {
    return this == WalletTransactionType.topUp ||
        this == WalletTransactionType.refund;
  }
}

enum WalletTransactionStatus { completed, pending, failed }

extension WalletTransactionStatusX on WalletTransactionStatus {
  String get label {
    return switch (this) {
      WalletTransactionStatus.completed => 'Completed',
      WalletTransactionStatus.pending => 'Pending',
      WalletTransactionStatus.failed => 'Failed',
    };
  }
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.patientId,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.amount,
    required this.referenceId,
    required this.createdAt,
  });

  final String id;
  final String patientId;
  final WalletTransactionType type;
  final WalletTransactionStatus status;
  final String title;
  final String description;

  /// Always stored as a positive whole-rupee amount.
  final int amount;

  final String referenceId;
  final DateTime createdAt;

  bool get isCredit => type.isCredit;
  int get signedAmount => isCredit ? amount : -amount;
}
