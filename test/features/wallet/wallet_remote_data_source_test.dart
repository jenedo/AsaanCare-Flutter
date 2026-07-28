import 'dart:convert';
import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/features/wallet/data/datasources/payment_remote_data_source.dart';
import 'package:asaancare/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const baseUrl = 'http://localhost:3000/api';

  group('Wallet & Payment Remote Data Sources Unit Tests', () {
    test('getWallet parses balanceMinor as int', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/wallet');
        return http.Response(
          jsonEncode({
            'id': 'wallet-1',
            'userId': 'user-1',
            'currency': 'PKR',
            'balanceMinor': 50000,
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = WalletRemoteDataSourceImpl(apiClient);
      final wallet = await dataSource.getWallet();

      expect(wallet.id, 'wallet-1');
      expect(wallet.userId, 'user-1');
      expect(wallet.currency, 'PKR');
      expect(wallet.balanceMinor, 50000);
    });

    test('getTransactions returns paginated result', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/wallet/transactions');
        expect(request.url.queryParameters['page'], '1');
        expect(request.url.queryParameters['limit'], '20');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'tx-1',
                'walletId': 'wallet-1',
                'type': 'CREDIT',
                'amountMinor': 25000,
                'currency': 'PKR',
                'balanceAfter': 50000,
                'description': 'Top-up',
                'createdAt': DateTime.now().toIso8601String(),
              },
            ],
            'total': 1,
            'page': 1,
            'limit': 20,
            'balanceMinor': 50000,
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = WalletRemoteDataSourceImpl(apiClient);
      final result = await dataSource.getTransactions(page: 1, limit: 20);

      expect(result['total'], 1);
      final list = result['data'] as List;
      expect(list, hasLength(1));
    });

    test('getTransactions parses amountMinor as int', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/wallet/transactions');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'tx-1',
                'walletId': 'wallet-1',
                'type': 'CREDIT',
                'amountMinor': 12345,
                'currency': 'PKR',
                'balanceAfter': 12345,
                'description': 'Top-up',
                'createdAt': DateTime.now().toIso8601String(),
              },
            ],
            'total': 1,
            'page': 1,
            'limit': 20,
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = WalletRemoteDataSourceImpl(apiClient);
      final result = await dataSource.getTransactions();

      final list = result['data'] as List;
      final txMap = list.first as Map<String, dynamic>;
      expect(txMap['amountMinor'], 12345);
    });

    test('getDoctorEarnings parses totalEarnedMinor as int', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/wallet/earnings');
        return http.Response(
          jsonEncode({
            'totalEarnedMinor': 150000,
            'pendingPayoutMinor': 20000,
            'currency': 'PKR',
            'data': [],
            'total': 0,
            'page': 1,
            'limit': 20,
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = WalletRemoteDataSourceImpl(apiClient);
      final earnings = await dataSource.getDoctorEarnings();

      expect(earnings.totalEarnedMinor, 150000);
      expect(earnings.pendingPayoutMinor, 20000);
      expect(earnings.currency, 'PKR');
    });

    test('createPaymentIntent sends correct body', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/payments/intent');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['orderId'], 'ord-123');
        expect(body['idempotencyKey'], 'idemp-key-1');
        expect(body['provider'], 'SANDBOX');

        return http.Response(
          jsonEncode({
            'paymentId': 'pay-attempt-1',
            'redirectUrl': 'https://sandbox.asaancare.pk/pay/sandbox_123',
            'status': 'PENDING',
            'providerRef': 'sandbox_123',
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = PaymentRemoteDataSourceImpl(apiClient);
      final attempt = await dataSource.createPaymentIntent(
        orderId: 'ord-123',
        idempotencyKey: 'idemp-key-1',
      );

      expect(attempt.id, 'pay-attempt-1');
      expect(attempt.status, 'PENDING');
    });

    test('createPaymentIntent parses redirectUrl', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'paymentId': 'pay-attempt-2',
            'redirectUrl': 'https://sandbox.asaancare.pk/pay/sandbox_456',
            'status': 'PENDING',
            'providerRef': 'sandbox_456',
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = PaymentRemoteDataSourceImpl(apiClient);
      final attempt = await dataSource.createPaymentIntent(
        orderId: 'ord-456',
        idempotencyKey: 'idemp-key-2',
      );

      expect(
        attempt.redirectUrl,
        'https://sandbox.asaancare.pk/pay/sandbox_456',
      );
    });

    test('getPaymentStatus returns status correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/payments/pay-123');
        return http.Response(
          jsonEncode({
            'id': 'pay-123',
            'status': 'SUCCEEDED',
            'providerRef': 'sandbox_123',
            'amountMinor': 50000,
            'currency': 'PKR',
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = PaymentRemoteDataSourceImpl(apiClient);
      final attempt = await dataSource.getPaymentStatus('pay-123');

      expect(attempt.id, 'pay-123');
      expect(attempt.status, 'SUCCEEDED');
      expect(attempt.amountMinor, 50000);
    });
  });
}
