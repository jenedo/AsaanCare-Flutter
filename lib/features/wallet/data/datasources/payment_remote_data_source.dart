import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/payment_attempt_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentAttemptModel> createPaymentIntent({
    required String orderId,
    required String idempotencyKey,
    String provider = 'SANDBOX',
  });
  Future<PaymentAttemptModel> getPaymentStatus(String paymentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient apiClient;

  PaymentRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaymentAttemptModel> createPaymentIntent({
    required String orderId,
    required String idempotencyKey,
    String provider = 'SANDBOX',
  }) async {
    final response = await apiClient.postJson(
      ApiEndpoints.paymentsIntent,
      body: {
        'orderId': orderId,
        'idempotencyKey': idempotencyKey,
        'provider': provider,
      },
    );
    final data = response['data'] ?? response;
    return PaymentAttemptModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<PaymentAttemptModel> getPaymentStatus(String paymentId) async {
    final response = await apiClient.getJson(
      ApiEndpoints.paymentStatus(paymentId),
    );
    final data = response['data'] ?? response;
    return PaymentAttemptModel.fromJson(data as Map<String, dynamic>);
  }
}
