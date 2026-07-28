import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/doctor_earnings_model.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWallet();
  Future<Map<String, dynamic>> getTransactions({int page = 1, int limit = 20});
  Future<DoctorEarningsModel> getDoctorEarnings({int page = 1, int limit = 20});
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient apiClient;

  WalletRemoteDataSourceImpl(this.apiClient);

  @override
  Future<WalletModel> getWallet() async {
    final response = await apiClient.getJson(ApiEndpoints.wallet);
    final data = response['data'] ?? response;
    return WalletModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await apiClient.getJson(
      ApiEndpoints.walletTransactions,
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    return response;
  }

  @override
  Future<DoctorEarningsModel> getDoctorEarnings({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await apiClient.getJson(
      ApiEndpoints.walletEarnings,
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    return DoctorEarningsModel.fromJson(response);
  }
}
