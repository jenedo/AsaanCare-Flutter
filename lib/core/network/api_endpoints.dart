abstract final class ApiEndpoints {
  const ApiEndpoints._();

  static const String authLogin = '/v1/auth/login';
  static const String authRegister = '/v1/auth/register';
  static const String authMe = '/v1/auth/me';
  static const String authLogout = '/v1/auth/logout';
  static const String authForgotPassword = '/v1/auth/forgot-password';

  static const String doctors = '/v1/doctors';
  static const String appointments = '/v1/appointments';
  static const String prescriptions = '/v1/prescriptions';
  static const String medicalRecords = '/v1/medical-records';
  static const String pharmacyMedicines = '/v1/pharmacy/medicines';
  static const String pharmacyOrders = '/v1/pharmacy/orders';
  static const String notifications = '/v1/notifications';
  static const String patientProfile = '/v1/patients/me';
  static const String healthReadings = '/v1/health/readings';
  static const String paymentIntents = '/v1/payments/intents';

  static const Map<String, String> declared = {
    'authLogin': authLogin,
    'authRegister': authRegister,
    'authMe': authMe,
    'authLogout': authLogout,
    'authForgotPassword': authForgotPassword,
    'doctors': doctors,
    'appointments': appointments,
    'prescriptions': prescriptions,
    'medicalRecords': medicalRecords,
    'pharmacyMedicines': pharmacyMedicines,
    'pharmacyOrders': pharmacyOrders,
    'notifications': notifications,
    'patientProfile': patientProfile,
    'healthReadings': healthReadings,
    'paymentIntents': paymentIntents,
  };
}
