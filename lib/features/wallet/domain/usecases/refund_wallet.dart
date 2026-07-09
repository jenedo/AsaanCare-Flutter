import '../entities/wallet_transaction.dart';
import '../repositories/wallet_repository.dart';

class RefundWallet {
  const RefundWallet(this._repository);

  final WalletRepository _repository;

  Future<WalletTransaction> call({
    required String patientId,
    required int amount,
    required String title,
    required String description,
    required String referenceId,
  }) {
    return _repository.refundWallet(
      patientId: patientId,
      amount: amount,
      title: title,
      description: description,
      referenceId: referenceId,
    );
  }
}
