import 'dart:convert';

import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/doctor/features/finance/data/datasources/doctor_finance_mock_data_source.dart';
import 'package:asaancare/doctor/features/finance/data/datasources/doctor_finance_remote_data_source.dart';
import 'package:asaancare/doctor/features/finance/data/repositories/doctor_finance_repository_impl.dart';
import 'package:asaancare/doctor/features/finance/domain/entities/doctor_finance_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('DoctorFinanceRemoteDataSource Unit Tests', () {
    test('getFinance parses balance and doctor earnings', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/v1/wallet') {
          return http.Response(
            jsonEncode({
              'wallet': {'balanceMinor': 250000, 'currency': 'PKR'},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path == '/v1/wallet/earnings') {
          return http.Response(
            jsonEncode({
              'earnings': {'totalEarnedMinor': 500000, 'consultationCount': 20},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: 'https://api.asaancare.pk',
        timeout: const Duration(seconds: 15),
      );

      final dataSource = DoctorFinanceRemoteDataSource(
        apiClient: apiClient,
        tokenProvider: () async => 'valid_token',
      );

      final snapshot = await dataSource.getFinance(
        doctorId: 'doc_1',
        period: DoctorFinancePeriod.thisMonth,
      );

      expect(snapshot.availableBalancePkr, 2500);
      expect(snapshot.totalEarningsPkr, 5000);
      expect(snapshot.consultationCount, 20);
    });
  });

  group('DoctorFinanceRepositoryImpl Unit Tests', () {
    test('uses mockDataSource when AppConfig.useMockApi is true', () async {
      final mockDataSource = DoctorFinanceMockDataSource();
      final repository = DoctorFinanceRepositoryImpl(
        mockDataSource: mockDataSource,
      );

      final snapshot = await repository.getFinance(
        doctorId: 'doc_1',
        period: DoctorFinancePeriod.thisMonth,
      );
      expect(snapshot.availableBalancePkr, greaterThanOrEqualTo(0));
    });
  });
}
