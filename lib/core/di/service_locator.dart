import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../features/appointments/data/datasources/appointment_mock_data_source.dart';
import '../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../features/appointments/domain/repositories/appointment_repository.dart';
import '../../features/appointments/domain/usecases/book_appointment.dart';
import '../../features/appointments/presentation/controllers/appointment_booking_controller.dart';
import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/datasources/auth_mock_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_patient.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/doctors/data/datasources/doctor_mock_data_source.dart';
import '../../features/doctors/data/repositories/doctor_repository_impl.dart';
import '../../features/doctors/domain/repositories/doctor_repository.dart';
import '../../features/doctors/domain/usecases/get_doctor_detail.dart';
import '../../features/doctors/presentation/controllers/doctor_detail_controller.dart';
import '../../features/pharmacy/data/datasources/pharmacy_mock_data_source.dart';
import '../../features/pharmacy/data/repositories/pharmacy_repository_impl.dart';
import '../../features/pharmacy/domain/repositories/pharmacy_repository.dart';
import '../../features/pharmacy/domain/usecases/get_popular_medicines.dart';
import '../../features/pharmacy/domain/usecases/get_recent_prescription.dart';
import '../../features/pharmacy/presentation/controllers/pharmacy_controller.dart';
import '../../features/prescriptions/data/datasources/prescription_mock_data_source.dart';
import '../../features/prescriptions/data/repositories/prescription_repository_impl.dart';
import '../../features/prescriptions/domain/repositories/prescription_repository.dart';
import '../../features/prescriptions/domain/usecases/delete_prescription.dart';
import '../../features/prescriptions/domain/usecases/get_prescriptions.dart';
import '../../features/prescriptions/domain/usecases/upload_prescription.dart';
import '../../features/prescriptions/presentation/controllers/prescription_controller.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  AppConfig.validate();

  // Networking
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      client: sl<http.Client>(),
      baseUrl: AppConfig.apiBaseUrl,
      timeout: AppConfig.requestTimeout,
    ),
  );

  // Auth: mock by default, remote only when enabled through --dart-define.
  sl.registerLazySingleton<AuthDataSource>(
    () => AppConfig.useMockApi
        ? AuthMockDataSource()
        : AuthRemoteDataSource(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl<AuthDataSource>()),
  );
  sl.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LoginUser>(() => LoginUser(sl<AuthRepository>()));
  sl.registerLazySingleton<RegisterPatient>(
    () => RegisterPatient(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUser>(() => LogoutUser(sl<AuthRepository>()));
  sl.registerLazySingleton<AuthController>(
    () => AuthController(
      getCurrentUser: sl<GetCurrentUser>(),
      loginUser: sl<LoginUser>(),
      registerPatient: sl<RegisterPatient>(),
      logoutUser: sl<LogoutUser>(),
    ),
  );

  // Doctors
  sl.registerLazySingleton<DoctorMockDataSource>(() => DoctorMockDataSource());
  sl.registerLazySingleton<DoctorRepository>(
    () => DoctorRepositoryImpl(mockDataSource: sl<DoctorMockDataSource>()),
  );
  sl.registerLazySingleton<GetDoctorDetail>(
    () => GetDoctorDetail(sl<DoctorRepository>()),
  );
  sl.registerFactory<DoctorDetailController>(
    () => DoctorDetailController(getDoctorDetail: sl<GetDoctorDetail>()),
  );

  // Appointments
  sl.registerLazySingleton<AppointmentMockDataSource>(
    () => AppointmentMockDataSource(),
  );
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(
      mockDataSource: sl<AppointmentMockDataSource>(),
    ),
  );
  sl.registerLazySingleton<BookAppointment>(
    () => BookAppointment(sl<AppointmentRepository>()),
  );
  sl.registerFactory<AppointmentBookingController>(
    () => AppointmentBookingController(bookAppointment: sl<BookAppointment>()),
  );

  // Pharmacy. Keep as a lazy singleton so the cart persists while logged in.
  sl.registerLazySingleton<PharmacyMockDataSource>(
    () => PharmacyMockDataSource(),
  );
  sl.registerLazySingleton<PharmacyRepository>(
    () => PharmacyRepositoryImpl(mockDataSource: sl<PharmacyMockDataSource>()),
  );
  sl.registerLazySingleton<GetPopularMedicines>(
    () => GetPopularMedicines(sl<PharmacyRepository>()),
  );
  sl.registerLazySingleton<GetRecentPrescription>(
    () => GetRecentPrescription(sl<PharmacyRepository>()),
  );
  sl.registerLazySingleton<PharmacyController>(
    () => PharmacyController(
      sl<GetPopularMedicines>(),
      sl<GetRecentPrescription>(),
    ),
  );

  // Prescriptions / Medical Records
  sl.registerLazySingleton<PrescriptionMockDataSource>(
    () => PrescriptionMockDataSource(),
  );
  sl.registerLazySingleton<PrescriptionRepository>(
    () => PrescriptionRepositoryImpl(
      mockDataSource: sl<PrescriptionMockDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetPrescriptions>(
    () => GetPrescriptions(sl<PrescriptionRepository>()),
  );
  sl.registerLazySingleton<UploadPrescription>(
    () => UploadPrescription(sl<PrescriptionRepository>()),
  );
  sl.registerLazySingleton<DeletePrescription>(
    () => DeletePrescription(sl<PrescriptionRepository>()),
  );
  sl.registerFactory<PrescriptionController>(
    () => PrescriptionController(
      getPrescriptions: sl<GetPrescriptions>(),
      uploadPrescription: sl<UploadPrescription>(),
      deletePrescription: sl<DeletePrescription>(),
    ),
  );
}
