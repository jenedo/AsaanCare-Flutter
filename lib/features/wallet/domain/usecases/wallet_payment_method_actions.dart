import '../entities/wallet_payment_method.dart';
import '../repositories/wallet_repository.dart';

class AddWalletPaymentMethod {
  const AddWalletPaymentMethod(this._repository);

  final WalletRepository _repository;

  Future<WalletPaymentMethod> call({
    required String patientId,
    required WalletPaymentMethodType type,
    required String displayName,
    required String maskedValue,
    bool setAsDefault = false,
  }) {
    return _repository.addPaymentMethod(
      patientId: patientId,
      type: type,
      displayName: displayName,
      maskedValue: maskedValue,
      setAsDefault: setAsDefault,
    );
  }
}

class SetDefaultWalletPaymentMethod {
  const SetDefaultWalletPaymentMethod(this._repository);

  final WalletRepository _repository;

  Future<void> call({
    required String patientId,
    required String paymentMethodId,
  }) {
    return _repository.setDefaultPaymentMethod(
      patientId: patientId,
      paymentMethodId: paymentMethodId,
    );
  }
}

class RemoveWalletPaymentMethod {
  const RemoveWalletPaymentMethod(this._repository);

  final WalletRepository _repository;

  Future<void> call({
    required String patientId,
    required String paymentMethodId,
  }) {
    return _repository.removePaymentMethod(
      patientId: patientId,
      paymentMethodId: paymentMethodId,
    );
  }
}
