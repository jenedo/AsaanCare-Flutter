// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../features/auth/domain/exceptions/auth_exception.dart';
import '../../domain/entities/doctor_finance_snapshot.dart';

class DoctorFinanceRemoteDataSource {
  DoctorFinanceRemoteDataSource({
    required ApiClient apiClient,
    required AccessTokenProvider tokenProvider,
  }) : _apiClient = apiClient,
       _tokenProvider = tokenProvider;

  final ApiClient _apiClient;
  final AccessTokenProvider _tokenProvider;

  Future<Map<String, dynamic>> getWalletBalance() async {
    final token = await _getToken();
    return _apiClient.getJson(ApiEndpoints.wallet, bearerToken: token);
  }

  Future<Map<String, dynamic>> getEarnings() async {
    final token = await _getToken();
    return _apiClient.getJson(ApiEndpoints.walletEarnings, bearerToken: token);
  }

  Future<DoctorFinanceSnapshot> getFinance({
    required String doctorId,
    required DoctorFinancePeriod period,
    FinanceDateRange? customRange,
  }) async {
    final balanceRes = await getWalletBalance();
    final earningsRes = await getEarnings();

    final walletData = balanceRes['wallet'] ?? balanceRes['data'] ?? balanceRes;
    final balanceMinor =
        (walletData is Map<String, dynamic>
            ? (walletData['balanceMinor'] as num?)?.toInt()
            : null) ??
        0;
    final availableBalancePkr = (balanceMinor / 100).round();

    final earningsData =
        earningsRes['earnings'] ?? earningsRes['data'] ?? earningsRes;
    final totalEarnedMinor =
        (earningsData is Map<String, dynamic>
            ? (earningsData['totalEarnedMinor'] as num?)?.toInt()
            : null) ??
        0;
    final totalEarningsPkr = (totalEarnedMinor / 100).round();
    final consultationCount =
        (earningsData is Map<String, dynamic>
            ? (earningsData['consultationCount'] as num?)?.toInt()
            : null) ??
        0;

    return DoctorFinanceSnapshot(
      period: period,
      totalEarningsPkr: totalEarningsPkr,
      availableBalancePkr: availableBalancePkr,
      pendingPayoutPkr: 0,
      withdrawnPkr: 0,
      platformFeesPkr: 0,
      consultationCount: consultationCount,
      growthPercent: 0.0,
      transactions: const [],
      breakdown: const [],
      payoutMethods: const [],
      nextPayoutAt: null,
    );
  }

  Future<String> _getToken() async {
    final token = await _tokenProvider();
    if (token != null && token.trim().isNotEmpty) {
      return token.trim();
    }
    try {
      final currentSessionToken =
          Supabase.instance.client.auth.currentSession?.accessToken;
      if (currentSessionToken != null &&
          currentSessionToken.trim().isNotEmpty) {
        return currentSessionToken.trim();
      }
    } catch (_) {}

    throw const AuthException('Session expired. Please log in again.');
  }
}
