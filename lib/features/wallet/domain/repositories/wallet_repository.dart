import '../entities/wallet_payment_method.dart';
import '../entities/wallet_snapshot.dart';
import '../entities/wallet_transaction.dart';

abstract class WalletRepository {
  Future<WalletSnapshot> getWalletSnapshot({required String patientId});

  Future<WalletTransaction> addMoney({
    required String patientId,
    required int amount,
    required String paymentMethodId,
    required String requestId,
  });

  Future<WalletTransaction> chargeWallet({
    required String patientId,
    required int amount,
    required String title,
    required String description,
    required String referenceId,
  });

  Future<WalletTransaction> refundWallet({
    required String patientId,
    required int amount,
    required String title,
    required String description,
    required String referenceId,
  });

  Future<WalletPaymentMethod> addPaymentMethod({
    required String patientId,
    required WalletPaymentMethodType type,
    required String displayName,
    required String maskedValue,
    required bool setAsDefault,
  });

  Future<void> setDefaultPaymentMethod({
    required String patientId,
    required String paymentMethodId,
  });

  Future<void> removePaymentMethod({
    required String patientId,
    required String paymentMethodId,
  });
}
