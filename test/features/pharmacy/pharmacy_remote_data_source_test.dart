import 'dart:convert';
import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/features/pharmacy/data/datasources/pharmacy_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const baseUrl = 'http://localhost:3000/api';

  group('PharmacyRemoteDataSource Unit Tests', () {
    test('getCategories parses category list correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/pharmacy/categories');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'cat-1',
                'name': 'Pain Relief',
                'slug': 'pain-relief',
                'description': 'Painkillers',
                'sortOrder': 1,
                'productCount': 5,
              },
            ],
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = PharmacyRemoteDataSourceImpl(apiClient);
      final categories = await dataSource.getCategories();

      expect(categories, hasLength(1));
      expect(categories.first.id, 'cat-1');
      expect(categories.first.name, 'Pain Relief');
      expect(categories.first.productCount, 5);
    });

    test('getProducts returns paginated result with availableStock', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/pharmacy/products');
        expect(request.url.queryParameters['page'], '1');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'prod-1',
                'categoryId': 'cat-1',
                'sku': 'PAN-500',
                'genericName': 'Paracetamol',
                'brandName': 'Panadol',
                'dosageForm': 'Tablet',
                'packSize': 10,
                'prescriptionRequired': false,
                'unitPriceMinor': 500,
                'availableStock': 42,
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

      final dataSource = PharmacyRemoteDataSourceImpl(apiClient);
      final result = await dataSource.getProducts(page: 1, limit: 20);

      expect(result['total'], 1);
      final products = result['data'] as List;
      expect(products, hasLength(1));
      expect(products.first.availableStock, 42);
    });

    test('getProductById parses unitPriceMinor as int', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/pharmacy/products/prod-1');
        return http.Response(
          jsonEncode({
            'id': 'prod-1',
            'categoryId': 'cat-1',
            'sku': 'PAN-500',
            'genericName': 'Paracetamol',
            'brandName': 'Panadol',
            'dosageForm': 'Tablet',
            'packSize': 10,
            'prescriptionRequired': false,
            'unitPriceMinor': 250,
            'availableStock': 100,
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = PharmacyRemoteDataSourceImpl(apiClient);
      final product = await dataSource.getProductById('prod-1');

      expect(product.id, 'prod-1');
      expect(product.unitPriceMinor, 250);
      expect(product.brandName, 'Panadol');
    });

    test('getCart returns cart with subtotalMinor as int', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/pharmacy/cart');
        return http.Response(
          jsonEncode({
            'id': 'cart-1',
            'patientId': 'pat-1',
            'currency': 'PKR',
            'subtotalMinor': 1000,
            'deliveryFeeMinor': 0,
            'totalMinor': 1000,
            'items': [],
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = PharmacyRemoteDataSourceImpl(apiClient);
      final cart = await dataSource.getCart();

      expect(cart.id, 'cart-1');
      expect(cart.subtotalMinor, 1000);
      expect(cart.totalMinor, 1000);
    });

    test('addToCart sends correct productId and quantity', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/pharmacy/cart/items');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['productId'], 'prod-1');
        expect(body['quantity'], 2);
        return http.Response(
          jsonEncode({
            'id': 'cart-1',
            'patientId': 'pat-1',
            'subtotalMinor': 1000,
            'deliveryFeeMinor': 0,
            'totalMinor': 1000,
            'items': [
              {
                'id': 'item-1',
                'productId': 'prod-1',
                'quantity': 2,
                'lineTotalMinor': 1000,
                'product': {
                  'id': 'prod-1',
                  'sku': 'PAN-500',
                  'brandName': 'Panadol',
                  'genericName': 'Paracetamol',
                  'dosageForm': 'Tablet',
                  'packSize': 10,
                  'prescriptionRequired': false,
                  'unitPriceMinor': 500,
                  'availableStock': 50,
                },
              },
            ],
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = PharmacyRemoteDataSourceImpl(apiClient);
      final cart = await dataSource.addToCart('prod-1', 2);

      expect(cart.items, hasLength(1));
      expect(cart.items.first.productId, 'prod-1');
      expect(cart.items.first.quantity, 2);
    });

    test('createOrder sends deliveryAddressId and idempotencyKey', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/pharmacy/orders');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['deliveryAddressId'], 'addr-1');
        expect(body['idempotencyKey'], 'idemp-123');
        return http.Response(
          jsonEncode({
            'id': 'order-1',
            'orderNumber': 'AC-12345',
            'status': 'PENDING_PAYMENT',
            'subtotalMinor': 1000,
            'deliveryFeeMinor': 0,
            'totalMinor': 1000,
            'currency': 'PKR',
            'createdAt': DateTime.now().toIso8601String(),
            'items': [],
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = PharmacyRemoteDataSourceImpl(apiClient);
      final order = await dataSource.createOrder(
        deliveryAddressId: 'addr-1',
        idempotencyKey: 'idemp-123',
      );

      expect(order.id, 'order-1');
      expect(order.orderNumber, 'AC-12345');
      expect(order.status, 'PENDING_PAYMENT');
    });

    test('cancelOrder calls correct endpoint', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/pharmacy/orders/order-1/cancel');
        return http.Response(
          jsonEncode({
            'id': 'order-1',
            'orderNumber': 'AC-12345',
            'status': 'CANCELLED',
            'subtotalMinor': 1000,
            'deliveryFeeMinor': 0,
            'totalMinor': 1000,
            'currency': 'PKR',
            'createdAt': DateTime.now().toIso8601String(),
            'items': [],
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = PharmacyRemoteDataSourceImpl(apiClient);
      final order = await dataSource.cancelOrder('order-1');

      expect(order.id, 'order-1');
      expect(order.status, 'CANCELLED');
    });
  });
}
