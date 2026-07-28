import 'wallet_transaction_model.dart';

class DoctorEarningsModel {
  final int totalEarnedMinor;
  final int pendingPayoutMinor;
  final String currency;
  final List<WalletTransactionModel> transactions;

  const DoctorEarningsModel({
    required this.totalEarnedMinor,
    required this.pendingPayoutMinor,
    required this.currency,
    required this.transactions,
  });

  factory DoctorEarningsModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['transactions'];
    final list = rawData is List ? rawData : [];
    return DoctorEarningsModel(
      totalEarnedMinor: (json['totalEarnedMinor'] as num?)?.toInt() ?? 0,
      pendingPayoutMinor: (json['pendingPayoutMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'PKR',
      transactions: list
          .map(
            (e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEarnedMinor': totalEarnedMinor,
      'pendingPayoutMinor': pendingPayoutMinor,
      'currency': currency,
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }
}
