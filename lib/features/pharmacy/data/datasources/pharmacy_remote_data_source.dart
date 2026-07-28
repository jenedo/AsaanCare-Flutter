import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/prescription_order.dart';
import '../models/cart_model.dart';
import '../models/delivery_address_model.dart';
import '../models/pharmacy_category_model.dart';
import '../models/pharmacy_order_model.dart';
import '../models/pharmacy_product_model.dart';

abstract class PharmacyRemoteDataSource {
  Future<List<Medicine>> getPopularMedicines();
  Future<PrescriptionOrder> getRecentPrescription();
  Future<List<PharmacyCategoryModel>> getCategories();
  Future<Map<String, dynamic>> getProducts({
    String? categoryId,
    String? search,
    bool? prescriptionRequired,
    int page = 1,
    int limit = 20,
  });
  Future<PharmacyProductModel> getProductById(String id);
  Future<CartModel> getCart();
  Future<CartModel> addToCart(String productId, int quantity);
  Future<CartModel> updateCartItem(String productId, int quantity);
  Future<void> removeCartItem(String productId);
  Future<List<DeliveryAddressModel>> getAddresses();
  Future<DeliveryAddressModel> createAddress(Map<String, dynamic> data);
  Future<void> deleteAddress(String id);
  Future<PharmacyOrderModel> createOrder({
    required String deliveryAddressId,
    required String idempotencyKey,
    String? prescriptionId,
  });
  Future<Map<String, dynamic>> getOrders({int page = 1, int limit = 20});
  Future<PharmacyOrderModel> getOrderById(String id);
  Future<PharmacyOrderModel> cancelOrder(String id);
}

class PharmacyRemoteDataSourceImpl implements PharmacyRemoteDataSource {
  final ApiClient apiClient;

  PharmacyRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<Medicine>> getPopularMedicines() async {
    try {
      final response = await apiClient.getJson('/v1/pharmacy/medicines');
      final rawList = response['data'] ?? response['medicines'] ?? response;
      if (rawList is List) {
        return rawList.whereType<Map<String, dynamic>>().map((item) {
          final priceVal =
              item['pricePkr'] ??
              item['price'] ??
              item['unitPriceMinor'] ??
              100;
          final priceInt = (priceVal is num) ? priceVal.toInt() : 100;
          return Medicine(
            id: item['id']?.toString() ?? '',
            brandName:
                item['brandName']?.toString() ??
                item['name']?.toString() ??
                'Medicine',
            genericName: item['genericName']?.toString() ?? 'Generic',
            manufacturer: item['manufacturer']?.toString() ?? 'Pharma',
            category: MedicineCategory.painRelief,
            strength: item['strength']?.toString() ?? 'N/A',
            dosageForm: item['dosageForm']?.toString() ?? 'Tablet',
            packSize: item['packSize']?.toString() ?? '10 Units',
            price: priceInt,
            originalPrice: priceInt,
            stockQuantity: item['stockQuantity'] is num
                ? (item['stockQuantity'] as num).toInt()
                : (item['inStock'] == true ? 50 : 0),
            prescriptionRequired: item['prescriptionRequired'] == true,
            rating: 4.8,
            reviewCount: 12,
            description:
                item['description']?.toString() ?? 'Pharmacy medicine item',
            productCode:
                item['sku']?.toString() ?? item['id']?.toString() ?? 'MED-01',
            imageUrl: item['imageUrl']?.toString(),
          );
        }).toList();
      }
    } catch (_) {}
    return const [];
  }

  @override
  Future<PrescriptionOrder> getRecentPrescription() async {
    try {
      final response = await apiClient.getJson(
        ApiEndpoints.prescriptions,
        queryParameters: {'limit': '1'},
      );
      final rawList = response['data'] ?? response['prescriptions'] ?? response;
      if (rawList is List && rawList.isNotEmpty) {
        final item = rawList.first;
        if (item is Map<String, dynamic>) {
          return PrescriptionOrder(
            id: item['id']?.toString() ?? 'rec_001',
            title: item['instructions']?.toString() ?? 'Recent Prescription',
            uploadedDate:
                item['issuedAt']?.toString() ??
                item['createdAt']?.toString() ??
                'Recent',
            isVerified: true,
            imageAsset: 'assets/images/sample_prescription.png',
            medicineIds: const [],
          );
        }
      }
    } catch (_) {}

    return const PrescriptionOrder(
      id: 'rec_001',
      title: 'Recent Prescription',
      uploadedDate: '2024-05-18',
      isVerified: true,
      imageAsset: 'assets/images/sample_prescription.png',
      medicineIds: [],
    );
  }

  @override
  Future<List<PharmacyCategoryModel>> getCategories() async {
    final response = await apiClient.getJson(ApiEndpoints.pharmacyCategories);
    final rawList = response['data'] ?? response;

    if (rawList is List) {
      return rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => PharmacyCategoryModel.fromJson(item))
          .toList();
    }
    return const [];
  }

  @override
  Future<Map<String, dynamic>> getProducts({
    String? categoryId,
    String? search,
    bool? prescriptionRequired,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (prescriptionRequired != null) {
      queryParams['prescriptionRequired'] = prescriptionRequired.toString();
    }

    final response = await apiClient.getJson(
      ApiEndpoints.pharmacyProducts,
      queryParameters: queryParams,
    );

    final rawList = response['data'];
    List<PharmacyProductModel> products = const [];
    if (rawList is List) {
      products = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => PharmacyProductModel.fromJson(item))
          .toList();
    }

    return {
      'data': products,
      'total': response['total'] ?? products.length,
      'page': response['page'] ?? page,
      'limit': response['limit'] ?? limit,
    };
  }

  @override
  Future<PharmacyProductModel> getProductById(String id) async {
    final response = await apiClient.getJson(
      '${ApiEndpoints.pharmacyProducts}/$id',
    );
    final data = response['data'] ?? response;
    return PharmacyProductModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<CartModel> getCart() async {
    final response = await apiClient.getJson(ApiEndpoints.pharmacyCart);
    final data = response['data'] ?? response;
    return CartModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<CartModel> addToCart(String productId, int quantity) async {
    final response = await apiClient.postJson(
      ApiEndpoints.pharmacyCartItems,
      body: {'productId': productId, 'quantity': quantity},
    );
    final data = response['data'] ?? response;
    return CartModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<CartModel> updateCartItem(String productId, int quantity) async {
    final response = await apiClient.patchJson(
      '${ApiEndpoints.pharmacyCartItems}/$productId',
      body: {'quantity': quantity},
    );
    final data = response['data'] ?? response;
    return CartModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> removeCartItem(String productId) async {
    await apiClient.deleteJson('${ApiEndpoints.pharmacyCartItems}/$productId');
  }

  @override
  Future<List<DeliveryAddressModel>> getAddresses() async {
    final response = await apiClient.getJson(ApiEndpoints.pharmacyAddresses);
    final rawList = response['data'] ?? response;

    if (rawList is List) {
      return rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => DeliveryAddressModel.fromJson(item))
          .toList();
    }
    return const [];
  }

  @override
  Future<DeliveryAddressModel> createAddress(Map<String, dynamic> data) async {
    final response = await apiClient.postJson(
      ApiEndpoints.pharmacyAddresses,
      body: data,
    );
    final responseData = response['data'] ?? response;
    return DeliveryAddressModel.fromJson(responseData as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await apiClient.deleteJson('${ApiEndpoints.pharmacyAddresses}/$id');
  }

  @override
  Future<PharmacyOrderModel> createOrder({
    required String deliveryAddressId,
    required String idempotencyKey,
    String? prescriptionId,
  }) async {
    final body = <String, dynamic>{
      'deliveryAddressId': deliveryAddressId,
      'idempotencyKey': idempotencyKey,
    };
    if (prescriptionId != null && prescriptionId.isNotEmpty) {
      body['prescriptionId'] = prescriptionId;
    }

    final response = await apiClient.postJson(
      ApiEndpoints.pharmacyOrders,
      body: body,
    );
    final data = response['data'] ?? response;
    return PharmacyOrderModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getOrders({int page = 1, int limit = 20}) async {
    final response = await apiClient.getJson(
      ApiEndpoints.pharmacyOrders,
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    final rawList = response['data'];
    List<PharmacyOrderModel> orders = const [];
    if (rawList is List) {
      orders = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => PharmacyOrderModel.fromJson(item))
          .toList();
    }

    return {
      'data': orders,
      'total': response['total'] ?? orders.length,
      'page': response['page'] ?? page,
      'limit': response['limit'] ?? limit,
    };
  }

  @override
  Future<PharmacyOrderModel> getOrderById(String id) async {
    final response = await apiClient.getJson(
      '${ApiEndpoints.pharmacyOrders}/$id',
    );
    final data = response['data'] ?? response;
    return PharmacyOrderModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<PharmacyOrderModel> cancelOrder(String id) async {
    final response = await apiClient.postJson(
      '${ApiEndpoints.pharmacyOrders}/$id/cancel',
    );
    final data = response['data'] ?? response;
    return PharmacyOrderModel.fromJson(data as Map<String, dynamic>);
  }
}
