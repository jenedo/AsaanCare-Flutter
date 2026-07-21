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
  FinanceDateRange? _customRange;
  DoctorFinanceSnapshot? _snapshot;
  String? _doctorId;
  String? _errorMessage;

  DoctorFinanceLoadStatus get status => _status;
  DoctorFinancePeriod get period => _period;
  DoctorWalletFilter get walletFilter => _walletFilter;
  FinanceDateRange? get customRange => _customRange;
  DoctorFinanceSnapshot? get snapshot => _snapshot;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == DoctorFinanceLoadStatus.loading;
  bool get canWithdraw => false;
  bool get canTransfer => false;

  /// Active date range for the selected period (used by UI to filter
  /// appointment payment-pending sums).
  FinanceDateRange get activeRange => resolveFinancePeriodRange(
    _period,
    now: DateTime.now(),
    customRange: _customRange,
  );

  String get periodChipLabel {
    if (_period != DoctorFinancePeriod.custom || _customRange == null) {
      return _period.label;
    }
    final start = _customRange!.start;
    final end = _customRange!.end;
    return '${start.day}/${start.month} – ${end.day}/${end.month}';
  }

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

  Future<void> changePeriod(
    DoctorFinancePeriod period, {
    FinanceDateRange? customRange,
  }) async {
    if (period == DoctorFinancePeriod.custom && customRange == null) {
      return;
    }
    if (_period == period &&
        _snapshot != null &&
        (period != DoctorFinancePeriod.custom ||
            _sameRange(_customRange, customRange))) {
      return;
    }
    _period = period;
    _customRange = period == DoctorFinancePeriod.custom ? customRange : null;
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
      _snapshot = await _getFinance(
        doctorId: doctorId,
        period: _period,
        customRange: _customRange,
      );
      _status = _snapshot!.transactions.isEmpty
          ? DoctorFinanceLoadStatus.empty
          : DoctorFinanceLoadStatus.ready;
    } catch (_) {
      _status = DoctorFinanceLoadStatus.failure;
      _errorMessage = 'Could not load earnings. Please retry.';
    }
    notifyListeners();
  }

  bool _sameRange(FinanceDateRange? a, FinanceDateRange? b) {
    if (a == null || b == null) return a == b;
    return a.start == b.start && a.end == b.end;
  }
}
