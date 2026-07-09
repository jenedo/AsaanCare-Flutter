import '../entities/wallet_snapshot.dart';
import '../repositories/wallet_repository.dart';

class GetWalletSnapshot {
  const GetWalletSnapshot(this._repository);

  final WalletRepository _repository;

  Future<WalletSnapshot> call({required String patientId}) {
    return _repository.getWalletSnapshot(patientId: patientId);
  }
}
