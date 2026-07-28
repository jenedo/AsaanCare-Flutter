import 'dart:convert';

import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/features/pharmacy/data/datasources/pharmacy_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('PharmacyRemoteDataSource Unit Tests', () {
    test(
      'getPopularMedicines calls /v1/pharmacy/medicines and maps response',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/v1/pharmacy/medicines');
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 'med_1',
                  'name': 'Panadol Extra',
                  'genericName': 'Paracetamol + Caffeine',
                  'manufacturer': 'GSK',
                  'pricePkr': 250,
                  'inStock': true,
                  'dosageForm': 'Tablet',
                  'strength': '500mg',
                  'description': 'Pain reliever',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: 'https://api.asaancare.pk',
          timeout: const Duration(seconds: 15),
        );

        final dataSource = PharmacyRemoteDataSourceImpl(apiClient);
        final medicines = await dataSource.getPopularMedicines();

        expect(medicines.length, 1);
        expect(medicines.first.id, 'med_1');
        expect(medicines.first.brandName, 'Panadol Extra');
        expect(medicines.first.price, 250);
        expect(medicines.first.isInStock, isTrue);
      },
    );

    test(
      'getRecentPrescription calls /v1/prescriptions and maps first item',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/v1/prescriptions');
          expect(request.url.queryParameters['limit'], '1');
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 'pres_recent_1',
                  'instructions': 'Take after meals',
                  'issuedAt': '2026-07-28T09:00:00Z',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: 'https://api.asaancare.pk',
          timeout: const Duration(seconds: 15),
        );

        final dataSource = PharmacyRemoteDataSourceImpl(apiClient);
        final recent = await dataSource.getRecentPrescription();

        expect(recent.id, 'pres_recent_1');
        expect(recent.title, 'Take after meals');
        expect(recent.isVerified, isTrue);
      },
    );
  });
}
