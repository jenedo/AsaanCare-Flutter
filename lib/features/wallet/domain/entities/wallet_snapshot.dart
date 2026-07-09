import 'wallet_account.dart';
import 'wallet_payment_method.dart';
import 'wallet_transaction.dart';

class WalletSnapshot {
  const WalletSnapshot({
    required this.account,
    required this.transactions,
    required this.paymentMethods,
  });

  final WalletAccount account;
  final List<WalletTransaction> transactions;
  final List<WalletPaymentMethod> paymentMethods;
}
