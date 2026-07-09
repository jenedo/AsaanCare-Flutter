import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/pharmacy_order.dart';
import '../../domain/entities/prescription_order.dart';
import '../../domain/usecases/get_popular_medicines.dart';
import '../../domain/usecases/get_recent_prescription.dart';

enum PharmacyStatus { initial, loading, loaded, error }

class PharmacyController extends ChangeNotifier {
  static const int maxQuantityPerMedicine = 10;
  static const int demoWalletBalance = 850;

  PharmacyController(this._getPopularMedicines, this._getRecentPrescription);

  final GetPopularMedicines _getPopularMedicines;
  final GetRecentPrescription _getRecentPrescription;

  UnmodifiableListView<Medicine> _medicines = UnmodifiableListView<Medicine>(
    const [],
  );
  final Map<String, int> _cartQuantities = {};
  final Set<String> _favoriteIds = {};

  PrescriptionOrder? _recentPrescription;
  PharmacyOrder? _activeOrder;
  PharmacyStatus _status = PharmacyStatus.initial;
  PharmacyPaymentMethod _paymentMethod = PharmacyPaymentMethod.cashOnDelivery;
  String _deliveryAddress = '123, Model Town, Block B, Lahore, Punjab 54000';
  String _selectedPharmacy = 'MediPlus Pharmacy';
  String _selectedCity = 'Lahore';
  String? _errorMessage;
  bool _isPlacingOrder = false;

  UnmodifiableListView<Medicine> get medicines => _medicines;
  UnmodifiableListView<Medicine> get popularMedicines => _medicines;
  PrescriptionOrder? get recentPrescription => _recentPrescription;
  PharmacyOrder? get activeOrder => _activeOrder;
  PharmacyStatus get status => _status;
  PharmacyPaymentMethod get selectedPaymentMethod => _paymentMethod;
  String get deliveryAddress => _deliveryAddress;
  String get selectedPharmacy => _selectedPharmacy;
  String get selectedCity => _selectedCity;
  String? get errorMessage => _errorMessage;
  bool get isPlacingOrder => _isPlacingOrder;

  bool get isInitial => _status == PharmacyStatus.initial;
  bool get isLoading => _status == PharmacyStatus.loading;
  bool get isLoaded => _status == PharmacyStatus.loaded;
  bool get hasError => _status == PharmacyStatus.error;
  bool get hasData => _medicines.isNotEmpty || _recentPrescription != null;
  bool get isEmpty =>
      _status == PharmacyStatus.loaded &&
      _medicines.isEmpty &&
      _recentPrescription == null;
  bool get isCartEmpty => _cartQuantities.isEmpty;

  int get cartCount => _cartQuantities.values.fold<int>(
    0,
    (total, quantity) => total + quantity,
  );

  UnmodifiableListView<CartItem> get cartItems {
    final byId = {for (final medicine in _medicines) medicine.id: medicine};

    return UnmodifiableListView<CartItem>(
      _cartQuantities.entries
          .where((entry) => byId.containsKey(entry.key))
          .map(
            (entry) =>
                CartItem(medicine: byId[entry.key]!, quantity: entry.value),
          )
          .toList(growable: false),
    );
  }

  int get subtotal =>
      cartItems.fold<int>(0, (total, item) => total + item.lineTotal);

  int get deliveryFee => subtotal >= 1000 || subtotal == 0 ? 0 : 150;
  int get discount => subtotal >= 500 ? 70 : 0;
  int get payableTotal => subtotal + deliveryFee - discount;

  String? get checkoutValidationError {
    if (isCartEmpty) return 'Your cart is empty.';

    if (_deliveryAddress.trim().length < 10) {
      return 'Enter a complete delivery address.';
    }

    if (_selectedPharmacy.trim().isEmpty) {
      return 'Select a pharmacy.';
    }

    for (final item in cartItems) {
      if (!item.medicine.isInStock) {
        return '${item.medicine.brandName} is out of stock.';
      }

      if (item.quantity > item.medicine.stockQuantity) {
        return 'Only ${item.medicine.stockQuantity} units of '
            '${item.medicine.brandName} are available.';
      }

      if (item.quantity > maxQuantityPerMedicine) {
        return 'Maximum $maxQuantityPerMedicine units are allowed per medicine.';
      }
    }

    final requiresPrescription = cartItems.any(
      (item) => item.medicine.prescriptionRequired,
    );

    if (requiresPrescription && _recentPrescription?.isVerified != true) {
      return 'A verified prescription is required for one or more medicines.';
    }

    if (_paymentMethod == PharmacyPaymentMethod.asaancareWallet &&
        payableTotal > demoWalletBalance) {
      return 'Demo wallet balance is insufficient. Select another method.';
    }

    return null;
  }

  bool get canCheckout => checkoutValidationError == null;

  Future<void> load({bool forceRefresh = false}) async {
    if (_status == PharmacyStatus.loading) return;
    if (!forceRefresh && _status == PharmacyStatus.loaded) return;

    _setStatus(PharmacyStatus.loading, null);

    try {
      final results = await Future.wait<Object>([
        _getPopularMedicines(),
        _getRecentPrescription(),
      ]);

      _medicines = UnmodifiableListView<Medicine>(results[0] as List<Medicine>);
      _recentPrescription = results[1] as PrescriptionOrder;
      _setStatus(PharmacyStatus.loaded, null);
    } catch (error, stackTrace) {
      AppLogger.error('PharmacyController.load', error, stackTrace);
      _setStatus(
        PharmacyStatus.error,
        'Failed to load pharmacy data. Please try again.',
      );
    }
  }

  Future<void> refresh() => load(forceRefresh: true);

  List<Medicine> searchMedicines({
    String query = '',
    MedicineCategory? category,
    bool onlyInStock = false,
  }) {
    final normalized = query.trim().toLowerCase();

    return _medicines
        .where((medicine) {
          return (normalized.isEmpty ||
                  medicine.searchableText.contains(normalized)) &&
              (category == null || medicine.category == category) &&
              (!onlyInStock || medicine.isInStock);
        })
        .toList(growable: false);
  }

  List<Medicine> similarMedicines(Medicine medicine, {int limit = 4}) {
    return _medicines
        .where(
          (candidate) =>
              candidate.id != medicine.id &&
              candidate.category == medicine.category,
        )
        .take(limit)
        .toList(growable: false);
  }

  bool isFavorite(String medicineId) => _favoriteIds.contains(medicineId);

  void toggleFavorite(String medicineId) {
    if (!_favoriteIds.add(medicineId)) {
      _favoriteIds.remove(medicineId);
    }
    notifyListeners();
  }

  int quantityFor(String medicineId) => _cartQuantities[medicineId] ?? 0;

  void addToCart(Medicine medicine, {int quantity = 1}) {
    if (!medicine.isInStock || quantity <= 0) return;

    final current = quantityFor(medicine.id);
    final maximum = math.min(maxQuantityPerMedicine, medicine.stockQuantity);
    final next = math.min(current + quantity, maximum);

    if (next == current) {
      _errorMessage = 'Maximum quantity reached for ${medicine.brandName}.';
      notifyListeners();
      return;
    }

    _cartQuantities[medicine.id] = next;
    _errorMessage = null;
    notifyListeners();
  }

  void setQuantity(String medicineId, int quantity) {
    if (quantity <= 0) {
      _cartQuantities.remove(medicineId);
      _errorMessage = null;
      notifyListeners();
      return;
    }

    Medicine? medicine;

    for (final candidate in _medicines) {
      if (candidate.id == medicineId) {
        medicine = candidate;
        break;
      }
    }

    if (medicine == null || !medicine.isInStock) return;

    final maximum = math.min(maxQuantityPerMedicine, medicine.stockQuantity);

    _cartQuantities[medicineId] = math.min(quantity, maximum);
    _errorMessage = null;
    notifyListeners();
  }

  void removeFromCart(String medicineId) {
    _cartQuantities.remove(medicineId);
    notifyListeners();
  }

  void clearCart({bool resetSession = false}) {
    _cartQuantities.clear();

    if (resetSession) {
      _favoriteIds.clear();
      _activeOrder = null;
      _paymentMethod = PharmacyPaymentMethod.cashOnDelivery;
      _deliveryAddress = '123, Model Town, Block B, Lahore, Punjab 54000';
      _selectedPharmacy = 'MediPlus Pharmacy';
      _selectedCity = 'Lahore';
      _errorMessage = null;
      _isPlacingOrder = false;
    }

    notifyListeners();
  }

  void selectPaymentMethod(PharmacyPaymentMethod value) {
    _paymentMethod = value;
    notifyListeners();
  }

  void updateDeliveryAddress(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _deliveryAddress = trimmed;
    notifyListeners();
  }

  void selectPharmacy(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _selectedPharmacy = trimmed;
    notifyListeners();
  }

  void selectCity(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _selectedCity = trimmed;
    notifyListeners();
  }

  Future<PharmacyOrder?> placeDemoOrder({required String patientId}) async {
    if (_isPlacingOrder) return null;

    final cleanPatientId = patientId.trim();
    if (cleanPatientId.isEmpty) {
      _errorMessage = 'Your session is missing. Please login again.';
      notifyListeners();
      return null;
    }

    final validationError = checkoutValidationError;

    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return null;
    }

    _isPlacingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 850));

      final order = PharmacyOrder(
        id: 'AC${DateTime.now().millisecondsSinceEpoch}',
        patientId: cleanPatientId,
        items: List<CartItem>.unmodifiable(cartItems),
        deliveryAddress: _deliveryAddress,
        pharmacyName: _selectedPharmacy,
        paymentMethod: _paymentMethod,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        discount: discount,
        total: payableTotal,
        createdAt: DateTime.now(),
        stage: _paymentMethod == PharmacyPaymentMethod.cashOnDelivery
            ? PharmacyOrderStage.confirmed
            : PharmacyOrderStage.paymentSuccessful,
      );

      _activeOrder = order;
      _cartQuantities.clear();
      return order;
    } catch (error, stackTrace) {
      AppLogger.error('PharmacyController.placeDemoOrder', error, stackTrace);
      _errorMessage = 'Could not place the demo order.';
      return null;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  void advanceDemoOrder() {
    final order = _activeOrder;
    if (order == null) return;

    final stages = order.stagePath;
    final current = stages.indexOf(order.stage);

    if (current == -1 || current >= stages.length - 1) return;

    _activeOrder = order.copyWith(stage: stages[current + 1]);
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void _setStatus(PharmacyStatus value, String? error) {
    _status = value;
    _errorMessage = error;
    notifyListeners();
  }
}
