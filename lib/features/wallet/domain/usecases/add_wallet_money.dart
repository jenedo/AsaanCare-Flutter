import '../entities/wallet_transaction.dart';
import '../repositories/wallet_repository.dart';

class AddWalletMoney {
  const AddWalletMoney(this._repository);

  final WalletRepository _repository;

  Future<WalletTransaction> call({
    required String patientId,
    required int amount,
    required String paymentMethodId,
    required String requestId,
  }) {
    return _repository.addMoney(
      patientId: patientId,
      amount: amount,
      paymentMethodId: paymentMethodId,
      requestId: requestId,
    );
  }
}
