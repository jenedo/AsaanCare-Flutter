import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../domain/entities/doctor_finance_snapshot.dart';
import '../../domain/usecases/get_doctor_finance.dart';

class DoctorFinanceController extends ChangeNotifier {
  DoctorFinanceController({required this._getFinance});

  final GetDoctorFinance _getFinance;

  DoctorFinanceLoadStatus _status = DoctorFinanceLoadStatus.initial;
  DoctorFinancePeriod _period = DoctorFinancePeriod.thisMonth;
  DoctorWalletFilter _walletFilter = DoctorWalletFilter.all;
  DoctorFinanceSnapshot? _snapshot;
  String? _doctorId;
  String? _errorMessage;

  DoctorFinanceLoadStatus get status => _status;
  DoctorFinancePeriod get period => _period;
  DoctorWalletFilter get walletFilter => _walletFilter;
  DoctorFinanceSnapshot? get snapshot => _snapshot;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == DoctorFinanceLoadStatus.loading;
  bool get canWithdraw => false;
  bool get canTransfer => false;

  UnmodifiableListView<DoctorFinanceTransaction> get filteredTransactions {
    final transactions =
        _snapshot?.transactions ?? const <DoctorFinanceTransaction>[];
    return UnmodifiableListView(
      transactions.where(
        (transaction) => switch (_walletFilter) {
          DoctorWalletFilter.all => true,
          DoctorWalletFilter.credits => transaction.amountPkr > 0,
          DoctorWalletFilter.debits => transaction.amountPkr < 0,
        },
      ),
    );
  }

  Future<void> load({required String doctorId, bool force = false}) async {
    final normalizedId = doctorId.trim();
    if (normalizedId.isEmpty) {
      _status = DoctorFinanceLoadStatus.failure;
      _errorMessage = 'A verified doctor session is required.';
      notifyListeners();
      return;
    }
    if (!force && _doctorId == normalizedId && _snapshot != null) return;
    _doctorId = normalizedId;
    await _loadCurrentPeriod();
  }

  Future<void> refresh() => _loadCurrentPeriod();

  Future<void> changePeriod(DoctorFinancePeriod period) async {
    if (_period == period && _snapshot != null) return;
    _period = period;
    notifyListeners();
    await _loadCurrentPeriod();
  }

  void selectWalletFilter(DoctorWalletFilter filter) {
    if (_walletFilter == filter) return;
    _walletFilter = filter;
    notifyListeners();
  }

  Future<void> _loadCurrentPeriod() async {
    final doctorId = _doctorId;
    if (doctorId == null) return;
    _status = DoctorFinanceLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _snapshot = await _getFinance(doctorId: doctorId, period: _period);
      _status = _snapshot!.transactions.isEmpty
          ? DoctorFinanceLoadStatus.empty
          : DoctorFinanceLoadStatus.ready;
    } catch (_) {
      _status = DoctorFinanceLoadStatus.failure;
      _errorMessage = 'Could not load earnings. Please retry.';
    }
    notifyListeners();
  }
}
