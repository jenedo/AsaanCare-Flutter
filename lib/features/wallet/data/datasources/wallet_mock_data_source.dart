import '../../domain/entities/wallet_account.dart';
import '../../domain/entities/wallet_payment_method.dart';
import '../../domain/entities/wallet_snapshot.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/exceptions/wallet_exception.dart';

class WalletMockDataSource {
  static const int minimumTopUp = 100;
  static const int maximumTopUp = 100000;

  final Map<String, WalletAccount> _accounts = {};
  final Map<String, List<WalletTransaction>> _transactions = {};
  final Map<String, List<WalletPaymentMethod>> _paymentMethods = {};
  final Map<String, WalletTransaction> _processedOperations = {};

  Future<WalletSnapshot> getWalletSnapshot({required String patientId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final cleanPatientId = _validatePatientId(patientId);
    _ensurePatient(cleanPatientId);

    return _snapshotFor(cleanPatientId);
  }

  Future<WalletTransaction> addMoney({
    required String patientId,
    required int amount,
    required String paymentMethodId,
    required String requestId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));

    final cleanPatientId = _validatePatientId(patientId);
    final cleanRequestId = requestId.trim();

    if (cleanRequestId.isEmpty) {
      throw const WalletException('A top-up request id is required.');
    }

    _ensurePatient(cleanPatientId);

    final operationKey = '$cleanPatientId:topup:$cleanRequestId';
    final existing = _processedOperations[operationKey];

    if (existing != null) {
      return existing;
    }

    if (amount < minimumTopUp) {
      throw const WalletException('Minimum wallet top-up is Rs. 100.');
    }

    if (amount > maximumTopUp) {
      throw const WalletException('Maximum wallet top-up is Rs. 100,000.');
    }

    final methods = _paymentMethods[cleanPatientId]!;

    WalletPaymentMethod? selectedMethod;

    for (final method in methods) {
      if (method.id == paymentMethodId) {
        selectedMethod = method;
        break;
      }
    }

    if (selectedMethod == null) {
      throw const WalletException('Select a valid payment method.');
    }

    final now = DateTime.now();
    final account = _accounts[cleanPatientId]!;

    _accounts[cleanPatientId] = account.copyWith(
      balance: account.balance + amount,
      updatedAt: now,
    );

    final transaction = WalletTransaction(
      id: 'wallet_tx_${now.microsecondsSinceEpoch}',
      patientId: cleanPatientId,
      type: WalletTransactionType.topUp,
      status: WalletTransactionStatus.completed,
      title: 'Wallet top-up',
      description: 'Added through ${selectedMethod.displayName}',
      amount: amount,
      referenceId: cleanRequestId,
      createdAt: now,
    );

    _transactions[cleanPatientId]!.insert(0, transaction);
    _processedOperations[operationKey] = transaction;

    return transaction;
  }

  Future<WalletTransaction> chargeWallet({
    required String patientId,
    required int amount,
    required String title,
    required String description,
    required String referenceId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final cleanPatientId = _validatePatientId(patientId);
    final cleanReferenceId = referenceId.trim();

    if (cleanReferenceId.isEmpty) {
      throw const WalletException('A payment reference is required.');
    }

    _ensurePatient(cleanPatientId);

    final operationKey = '$cleanPatientId:charge:$cleanReferenceId';
    final existing = _processedOperations[operationKey];

    if (existing != null) {
      return existing;
    }

    if (amount <= 0) {
      throw const WalletException('Enter a valid payment amount.');
    }

    final account = _accounts[cleanPatientId]!;

    if (account.balance < amount) {
      throw const WalletException('Insufficient wallet balance.');
    }

    final now = DateTime.now();

    _accounts[cleanPatientId] = account.copyWith(
      balance: account.balance - amount,
      updatedAt: now,
    );

    final transaction = WalletTransaction(
      id: 'wallet_tx_${now.microsecondsSinceEpoch}',
      patientId: cleanPatientId,
      type: WalletTransactionType.payment,
      status: WalletTransactionStatus.completed,
      title: title.trim().isEmpty ? 'Wallet payment' : title.trim(),
      description: description.trim(),
      amount: amount,
      referenceId: cleanReferenceId,
      createdAt: now,
    );

    _transactions[cleanPatientId]!.insert(0, transaction);
    _processedOperations[operationKey] = transaction;

    return transaction;
  }

  Future<WalletTransaction> refundWallet({
    required String patientId,
    required int amount,
    required String title,
    required String description,
    required String referenceId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final cleanPatientId = _validatePatientId(patientId);
    final cleanReferenceId = referenceId.trim();

    if (cleanReferenceId.isEmpty) {
      throw const WalletException('A refund reference is required.');
    }

    _ensurePatient(cleanPatientId);

    final operationKey = '$cleanPatientId:refund:$cleanReferenceId';
    final existing = _processedOperations[operationKey];

    if (existing != null) {
      return existing;
    }

    if (amount <= 0) {
      throw const WalletException('Enter a valid refund amount.');
    }

    final now = DateTime.now();
    final account = _accounts[cleanPatientId]!;

    _accounts[cleanPatientId] = account.copyWith(
      balance: account.balance + amount,
      updatedAt: now,
    );

    final transaction = WalletTransaction(
      id: 'wallet_tx_${now.microsecondsSinceEpoch}',
      patientId: cleanPatientId,
      type: WalletTransactionType.refund,
      status: WalletTransactionStatus.completed,
      title: title.trim().isEmpty ? 'Wallet refund' : title.trim(),
      description: description.trim(),
      amount: amount,
      referenceId: cleanReferenceId,
      createdAt: now,
    );

    _transactions[cleanPatientId]!.insert(0, transaction);
    _processedOperations[operationKey] = transaction;

    return transaction;
  }

  Future<WalletPaymentMethod> addPaymentMethod({
    required String patientId,
    required WalletPaymentMethodType type,
    required String displayName,
    required String maskedValue,
    required bool setAsDefault,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final cleanPatientId = _validatePatientId(patientId);
    final cleanName = displayName.trim();
    final cleanMaskedValue = maskedValue.trim();

    _ensurePatient(cleanPatientId);

    if (cleanName.isEmpty) {
      throw const WalletException('Payment method name is required.');
    }

    if (cleanMaskedValue.isEmpty) {
      throw const WalletException('Masked payment information is required.');
    }

    if (!_isValidMaskedValue(type, cleanMaskedValue)) {
      throw const WalletException(
        'Only masked information in the supported payment format may be stored.',
      );
    }

    final methods = _paymentMethods[cleanPatientId]!;

    for (var index = 0; index < methods.length; index++) {
      final method = methods[index];

      if (method.type == type &&
          method.maskedValue.toLowerCase() == cleanMaskedValue.toLowerCase()) {
        if (!setAsDefault) {
          return method;
        }

        for (var methodIndex = 0; methodIndex < methods.length; methodIndex++) {
          methods[methodIndex] = methods[methodIndex].copyWith(
            isDefault: methodIndex == index,
          );
        }

        return methods[index];
      }
    }

    final shouldSetDefault =
        setAsDefault ||
        methods.isEmpty ||
        !methods.any((method) => method.isDefault);

    if (shouldSetDefault) {
      for (var index = 0; index < methods.length; index++) {
        methods[index] = methods[index].copyWith(isDefault: false);
      }
    }

    final method = WalletPaymentMethod(
      id: 'wallet_method_${DateTime.now().microsecondsSinceEpoch}',
      patientId: cleanPatientId,
      type: type,
      displayName: cleanName,
      maskedValue: cleanMaskedValue,
      isDefault: shouldSetDefault,
    );

    methods.add(method);
    return method;
  }

  Future<void> setDefaultPaymentMethod({
    required String patientId,
    required String paymentMethodId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final cleanPatientId = _validatePatientId(patientId);
    _ensurePatient(cleanPatientId);

    final methods = _paymentMethods[cleanPatientId]!;

    if (!methods.any((method) => method.id == paymentMethodId)) {
      throw const WalletException('Payment method was not found.');
    }

    for (var index = 0; index < methods.length; index++) {
      methods[index] = methods[index].copyWith(
        isDefault: methods[index].id == paymentMethodId,
      );
    }
  }

  Future<void> removePaymentMethod({
    required String patientId,
    required String paymentMethodId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final cleanPatientId = _validatePatientId(patientId);
    _ensurePatient(cleanPatientId);

    final methods = _paymentMethods[cleanPatientId]!;

    WalletPaymentMethod? methodToRemove;

    for (final method in methods) {
      if (method.id == paymentMethodId) {
        methodToRemove = method;
        break;
      }
    }

    if (methodToRemove == null) {
      throw const WalletException('Payment method was not found.');
    }

    methods.removeWhere((method) => method.id == paymentMethodId);

    if (methodToRemove.isDefault && methods.isNotEmpty) {
      methods[0] = methods[0].copyWith(isDefault: true);
    }
  }

  bool _isValidMaskedValue(WalletPaymentMethodType type, String value) {
    return switch (type) {
      WalletPaymentMethodType.card => RegExp(r'^\*{4} \d{4}$').hasMatch(value),
      WalletPaymentMethodType.bankTransfer => RegExp(
        r'^PK\*{2} \*{4} \d{4}$',
        caseSensitive: false,
      ).hasMatch(value),
      WalletPaymentMethodType.easypaisa || WalletPaymentMethodType.jazzCash =>
        RegExp(r'^03\*{2} \*{3}\d{4}$').hasMatch(value),
    };
  }

  String _validatePatientId(String value) {
    final patientId = value.trim();

    if (patientId.isEmpty) {
      throw const WalletException('Patient session is required.');
    }

    return patientId;
  }

  void _ensurePatient(String patientId) {
    if (_accounts.containsKey(patientId)) {
      return;
    }

    _accounts[patientId] = WalletAccount(
      id: 'wallet_$patientId',
      patientId: patientId,
      balance: 2450,
      currencyCode: 'PKR',
      updatedAt: DateTime(2026, 7, 8, 18, 30),
    );

    _transactions[patientId] = [
      WalletTransaction(
        id: '${patientId}_refund_001',
        patientId: patientId,
        type: WalletTransactionType.refund,
        status: WalletTransactionStatus.completed,
        title: 'Appointment refund',
        description: 'Refund from cancelled consultation',
        amount: 800,
        referenceId: 'REF-DEMO-001',
        createdAt: DateTime(2026, 7, 7, 15, 20),
      ),
      WalletTransaction(
        id: '${patientId}_medicine_001',
        patientId: patientId,
        type: WalletTransactionType.payment,
        status: WalletTransactionStatus.completed,
        title: 'Medicine order',
        description: 'MediPlus Pharmacy',
        amount: 550,
        referenceId: 'MED-DEMO-001',
        createdAt: DateTime(2026, 7, 5, 12, 10),
      ),
      WalletTransaction(
        id: '${patientId}_consultation_001',
        patientId: patientId,
        type: WalletTransactionType.payment,
        status: WalletTransactionStatus.completed,
        title: 'Doctor consultation',
        description: 'Video consultation with Dr. Ali Raza',
        amount: 800,
        referenceId: 'APT-DEMO-001',
        createdAt: DateTime(2026, 7, 3, 10, 30),
      ),
      WalletTransaction(
        id: '${patientId}_topup_001',
        patientId: patientId,
        type: WalletTransactionType.topUp,
        status: WalletTransactionStatus.completed,
        title: 'Wallet top-up',
        description: 'Added through Visa / Mastercard',
        amount: 3000,
        referenceId: 'TOPUP-DEMO-001',
        createdAt: DateTime(2026, 7, 1, 9),
      ),
    ];

    _paymentMethods[patientId] = [
      WalletPaymentMethod(
        id: '${patientId}_card_4242',
        patientId: patientId,
        type: WalletPaymentMethodType.card,
        displayName: 'Visa / Mastercard',
        maskedValue: '**** 4242',
        isDefault: true,
      ),
      WalletPaymentMethod(
        id: '${patientId}_easypaisa',
        patientId: patientId,
        type: WalletPaymentMethodType.easypaisa,
        displayName: 'Easypaisa',
        maskedValue: '03** ***1234',
        isDefault: false,
      ),
      WalletPaymentMethod(
        id: '${patientId}_jazzcash',
        patientId: patientId,
        type: WalletPaymentMethodType.jazzCash,
        displayName: 'JazzCash',
        maskedValue: '03** ***5678',
        isDefault: false,
      ),
      WalletPaymentMethod(
        id: '${patientId}_bank',
        patientId: patientId,
        type: WalletPaymentMethodType.bankTransfer,
        displayName: 'Bank account',
        maskedValue: 'PK** **** 9876',
        isDefault: false,
      ),
    ];
  }

  WalletSnapshot _snapshotFor(String patientId) {
    return WalletSnapshot(
      account: _accounts[patientId]!,
      transactions: List<WalletTransaction>.unmodifiable(
        _transactions[patientId]!,
      ),
      paymentMethods: List<WalletPaymentMethod>.unmodifiable(
        _paymentMethods[patientId]!,
      ),
    );
  }
}
