abstract final class ApiEndpoints {
  const ApiEndpoints._();

  static const String authLogin = '/v1/auth/login';
  static const String authRegister = '/v1/auth/register';
  static const String authBootstrap = '/v1/auth/bootstrap';
  static const String authMe = '/v1/auth/me';
  static const String usersMe = '/v1/users/me';
  static const String authLogout = '/v1/auth/logout';
  static const String authForgotPassword = '/v1/auth/forgot-password';
  static const String doctorVerificationDocuments =
      '/v1/doctors/verification/documents';

  static const String doctors = '/v1/doctors';
  static const String appointments = '/v1/appointments';
  static const String prescriptions = '/v1/prescriptions';
  static const String medicalRecords = '/v1/medical-records';
  static const String pharmacyCategories = '/v1/pharmacy/categories';
  static const String pharmacyProducts = '/v1/pharmacy/products';
  static const String pharmacyCart = '/v1/pharmacy/cart';
  static const String pharmacyCartItems = '/v1/pharmacy/cart/items';
  static const String pharmacyAddresses = '/v1/pharmacy/addresses';
  static const String pharmacyOrders = '/v1/pharmacy/orders';
  static const String notifications = '/v1/notifications';
  static const String patientProfile = '/v1/patients/me';
  static const String healthReadings = '/v1/health/readings';
  static const String paymentIntents = '/v1/payments/intents';
  static const String wallet = '/v1/wallet';
  static const String walletTransactions = '/v1/wallet/transactions';
  static const String walletEarnings = '/v1/wallet/earnings';
  static const String paymentsIntent = '/v1/payments/intent';
  static String paymentStatus(String id) => '/v1/payments/$id';

  static const Map<String, String> declared = {
    'authLogin': authLogin,
    'authRegister': authRegister,
    'authMe': authMe,
    'usersMe': usersMe,
    'authLogout': authLogout,
    'authForgotPassword': authForgotPassword,
    'doctorVerificationDocuments': doctorVerificationDocuments,
    'doctors': doctors,
    'appointments': appointments,
    'prescriptions': prescriptions,
    'medicalRecords': medicalRecords,
    'pharmacyCategories': pharmacyCategories,
    'pharmacyProducts': pharmacyProducts,
    'pharmacyCart': pharmacyCart,
    'pharmacyCartItems': pharmacyCartItems,
    'pharmacyAddresses': pharmacyAddresses,
    'pharmacyOrders': pharmacyOrders,
    'notifications': notifications,
    'patientProfile': patientProfile,
    'healthReadings': healthReadings,
    'paymentIntents': paymentIntents,
    'wallet': wallet,
    'walletTransactions': walletTransactions,
    'walletEarnings': walletEarnings,
    'paymentsIntent': paymentsIntent,
  };
}
