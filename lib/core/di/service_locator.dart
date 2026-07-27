import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../doctor/features/dashboard/data/datasources/doctor_dashboard_mock_data_source.dart';
import '../../doctor/features/dashboard/data/repositories/doctor_dashboard_repository_impl.dart';
import '../../doctor/features/dashboard/domain/repositories/doctor_dashboard_repository.dart';
import '../../doctor/features/dashboard/domain/usecases/doctor_dashboard_usecases.dart';
import '../../doctor/features/dashboard/presentation/controllers/doctor_dashboard_controller.dart';
import '../../doctor/features/finance/data/datasources/doctor_finance_mock_data_source.dart';
import '../../doctor/features/finance/data/repositories/doctor_finance_repository_impl.dart';
import '../../doctor/features/finance/domain/repositories/doctor_finance_repository.dart';
import '../../doctor/features/finance/domain/usecases/get_doctor_finance.dart';
import '../../doctor/features/finance/presentation/controllers/doctor_finance_controller.dart';
import '../../doctor/features/patient_notes/data/datasources/doctor_patient_notes_mock_data_source.dart';
import '../../doctor/features/patient_notes/data/repositories/doctor_patient_notes_repository_impl.dart';
import '../../doctor/features/patient_notes/domain/repositories/doctor_patient_notes_repository.dart';
import '../../doctor/features/patient_notes/presentation/controllers/doctor_patient_notes_controller.dart';
import '../../doctor/features/prescription_writer/data/datasources/doctor_prescription_draft_mock_data_source.dart';
import '../../doctor/features/prescription_writer/data/repositories/doctor_prescription_draft_repository_impl.dart';
import '../../doctor/features/prescription_writer/domain/repositories/doctor_prescription_draft_repository.dart';
import '../../doctor/features/prescription_writer/presentation/controllers/doctor_prescription_controller.dart';
import '../../doctor/features/profile/data/datasources/doctor_profile_mock_data_source.dart';
import '../../doctor/features/profile/data/repositories/doctor_profile_repository_impl.dart';
import '../../doctor/features/profile/domain/repositories/doctor_profile_repository.dart';
import '../../doctor/features/profile/presentation/controllers/doctor_profile_controller.dart';
import '../../features/appointments/data/datasources/appointment_mock_data_source.dart';
import '../../features/appointments/data/datasources/appointment_remote_data_source.dart';
import '../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../features/appointments/domain/repositories/appointment_repository.dart';
import '../../features/appointments/domain/usecases/book_appointment.dart';
import '../../features/appointments/domain/usecases/get_appointments.dart';
import '../../features/appointments/presentation/controllers/appointment_booking_controller.dart';
import '../../features/appointments/presentation/controllers/appointment_list_controller.dart';
import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/datasources/auth_mock_data_source.dart';
import '../../features/auth/data/datasources/supabase_auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/storage/auth_token_store.dart';
import '../../features/auth/data/storage/secure_auth_token_store.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_doctor.dart';
import '../../features/auth/domain/usecases/register_patient.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/doctors/data/datasources/doctor_mock_data_source.dart';
import '../../features/doctors/data/datasources/doctor_remote_data_source.dart';
import '../../features/doctors/data/repositories/doctor_repository_impl.dart';
import '../../features/doctors/domain/repositories/doctor_repository.dart';
import '../../features/doctors/domain/usecases/get_doctor_detail.dart';
import '../../features/doctors/domain/usecases/get_doctors.dart';
import '../../features/doctors/presentation/controllers/doctor_detail_controller.dart';
import '../../features/doctors/presentation/controllers/find_doctors_controller.dart';
import '../../features/pharmacy/data/datasources/pharmacy_mock_data_source.dart';
import '../../features/pharmacy/data/datasources/pharmacy_remote_data_source.dart';
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
import '../../features/wallet/data/datasources/wallet_mock_data_source.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/add_wallet_money.dart';
import '../../features/wallet/domain/usecases/charge_wallet.dart';
import '../../features/wallet/domain/usecases/get_wallet_snapshot.dart';
import '../../features/wallet/domain/usecases/refund_wallet.dart';
import '../../features/wallet/domain/usecases/wallet_payment_method_actions.dart';
import '../../features/wallet/presentation/controllers/wallet_controller.dart';
import '../../features/clinical_prescriptions/data/datasources/clinical_prescription_remote_data_source.dart';
import '../../features/clinical_prescriptions/data/repositories/clinical_prescription_repository_impl.dart';
import '../../features/clinical_prescriptions/data/repositories/mock_clinical_prescription_repository.dart';
import '../../features/clinical_prescriptions/domain/repositories/clinical_prescription_repository.dart';
import '../../features/clinical_prescriptions/presentation/controllers/clinical_prescriptions_controller.dart';
import '../../features/medical_records/data/datasources/medical_records_remote_data_source.dart';
import '../../features/medical_records/data/repositories/medical_records_repository_impl.dart';
import '../../features/medical_records/data/repositories/mock_medical_records_repository.dart';
import '../../features/medical_records/domain/repositories/medical_records_repository.dart';
import '../../features/medical_records/presentation/controllers/medical_records_controller.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator({bool? isMockApi}) async {
  final useMock = isMockApi ?? AppConfig.useMockApi;
  // AppConfig.validate(); // disabled: no NestJS backend

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
  sl.registerLazySingleton<FlutterSecureStorage>(() => FlutterSecureStorage());
  sl.registerLazySingleton<AuthTokenStore>(
    () => SecureAuthTokenStore(sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<AuthDataSource>(
    () => AppConfig.useMockApi
        ? AuthMockDataSource()
        : SupabaseAuthDataSource(client: Supabase.instance.client),
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
  sl.registerLazySingleton<RegisterDoctor>(
    () => RegisterDoctor(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUser>(() => LogoutUser(sl<AuthRepository>()));
  sl.registerLazySingleton<AuthController>(
    () => AuthController(
      getCurrentUser: sl<GetCurrentUser>(),
      loginUser: sl<LoginUser>(),
      registerPatient: sl<RegisterPatient>(),
      registerDoctor: sl<RegisterDoctor>(),
      logoutUser: sl<LogoutUser>(),
    ),
  );

  // Doctor dashboard. Datasource/repository persist state for the signed-in
  // session while controllers remain screen-scoped and disposable.
  sl.registerLazySingleton<DoctorDashboardMockDataSource>(
    DoctorDashboardMockDataSource.new,
  );
  sl.registerLazySingleton<DoctorDashboardRepository>(
    () => DoctorDashboardRepositoryImpl(
      dataSource: sl<DoctorDashboardMockDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetDoctorDashboard>(
    () => GetDoctorDashboard(sl<DoctorDashboardRepository>()),
  );
  sl.registerLazySingleton<UpdateDoctorAppointmentStatus>(
    () => UpdateDoctorAppointmentStatus(sl<DoctorDashboardRepository>()),
  );
  sl.registerLazySingleton<UpdateDoctorAvailability>(
    () => UpdateDoctorAvailability(sl<DoctorDashboardRepository>()),
  );
  sl.registerFactory<DoctorDashboardController>(
    () => DoctorDashboardController(
      getDashboard: sl<GetDoctorDashboard>(),
      updateAppointmentStatus: sl<UpdateDoctorAppointmentStatus>(),
      updateAvailability: sl<UpdateDoctorAvailability>(),
    ),
  );

  // Doctor earnings and wallet. Money-moving capabilities stay gated until
  // authenticated payout APIs are available.
  sl.registerLazySingleton<DoctorFinanceMockDataSource>(
    DoctorFinanceMockDataSource.new,
  );
  sl.registerLazySingleton<DoctorFinanceRepository>(
    () => DoctorFinanceRepositoryImpl(
      dataSource: sl<DoctorFinanceMockDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetDoctorFinance>(
    () => GetDoctorFinance(sl<DoctorFinanceRepository>()),
  );
  sl.registerFactory<DoctorFinanceController>(
    () => DoctorFinanceController(getFinance: sl<GetDoctorFinance>()),
  );

  // Doctor profile, patient notes, and prescription drafting persist per
  // signed-in session through datasource-backed repositories while controllers
  // stay screen-scoped and disposable.
  sl.registerLazySingleton<DoctorProfileMockDataSource>(
    DoctorProfileMockDataSource.new,
  );
  sl.registerLazySingleton<DoctorProfileRepository>(
    () => DoctorProfileRepositoryImpl(
      dataSource: sl<DoctorProfileMockDataSource>(),
    ),
  );
  sl.registerFactory<DoctorProfileController>(
    () => DoctorProfileController(repository: sl<DoctorProfileRepository>()),
  );
  sl.registerLazySingleton<DoctorPatientNotesMockDataSource>(
    DoctorPatientNotesMockDataSource.new,
  );
  sl.registerLazySingleton<DoctorPatientNotesRepository>(
    () => DoctorPatientNotesRepositoryImpl(
      dataSource: sl<DoctorPatientNotesMockDataSource>(),
    ),
  );
  sl.registerFactory<DoctorPatientNotesController>(
    () => DoctorPatientNotesController(
      repository: sl<DoctorPatientNotesRepository>(),
    ),
  );
  sl.registerLazySingleton<DoctorPrescriptionDraftMockDataSource>(
    DoctorPrescriptionDraftMockDataSource.new,
  );
  sl.registerLazySingleton<DoctorPrescriptionDraftRepository>(
    () => DoctorPrescriptionDraftRepositoryImpl(
      dataSource: sl<DoctorPrescriptionDraftMockDataSource>(),
    ),
  );
  sl.registerFactory<DoctorPrescriptionController>(
    () => DoctorPrescriptionController(
      repository: sl<DoctorPrescriptionDraftRepository>(),
    ),
  );

  // Doctors
  sl.registerLazySingleton<DoctorMockDataSource>(() => DoctorMockDataSource());
  sl.registerLazySingleton<DoctorRemoteDataSource>(
    () => DoctorRemoteDataSource(
      apiClient: sl<ApiClient>(),
      tokenProvider: () async =>
          Supabase.instance.client.auth.currentSession?.accessToken,
    ),
  );
  sl.registerLazySingleton<DoctorRepository>(
    () => AppConfig.useMockApi
        ? DoctorRepositoryImpl(mockDataSource: sl<DoctorMockDataSource>())
        : DoctorRepositoryImpl(remoteDataSource: sl<DoctorRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetDoctors>(
    () => GetDoctors(sl<DoctorRepository>()),
  );
  sl.registerFactory<FindDoctorsController>(
    () => FindDoctorsController(getDoctors: sl<GetDoctors>()),
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
  sl.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSource(
      apiClient: sl<ApiClient>(),
      tokenProvider: () async =>
          Supabase.instance.client.auth.currentSession?.accessToken,
    ),
  );
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppConfig.useMockApi
        ? AppointmentRepositoryImpl(
            mockDataSource: sl<AppointmentMockDataSource>(),
          )
        : AppointmentRepositoryImpl(
            remoteDataSource: sl<AppointmentRemoteDataSource>(),
          ),
  );
  sl.registerLazySingleton<BookAppointment>(
    () => BookAppointment(sl<AppointmentRepository>()),
  );
  sl.registerLazySingleton<GetAppointments>(
    () => GetAppointments(sl<AppointmentRepository>()),
  );
  sl.registerFactory<AppointmentBookingController>(
    () => AppointmentBookingController(bookAppointment: sl<BookAppointment>()),
  );
  sl.registerFactory<AppointmentListController>(
    () => AppointmentListController(getAppointments: sl<GetAppointments>()),
  );

  // Pharmacy. Keep as a lazy singleton so the cart persists while logged in.
  sl.registerLazySingleton<PharmacyMockDataSource>(
    () => PharmacyMockDataSource(),
  );
  sl.registerLazySingleton<PharmacyRemoteDataSource>(
    () => PharmacyRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<PharmacyRepository>(
    () => AppConfig.useMockApi
        ? PharmacyRepositoryImpl(mockDataSource: sl<PharmacyMockDataSource>())
        : PharmacyRepositoryImpl(
            remoteDataSource: sl<PharmacyRemoteDataSource>(),
            mockDataSource: sl<PharmacyMockDataSource>(),
          ),
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

  // Wallet. Repository and mock datasource stay alive so balance and ledger
  // changes persist while the application session is running.
  sl.registerLazySingleton<WalletMockDataSource>(() => WalletMockDataSource());
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(mockDataSource: sl<WalletMockDataSource>()),
  );
  sl.registerLazySingleton<GetWalletSnapshot>(
    () => GetWalletSnapshot(sl<WalletRepository>()),
  );
  sl.registerLazySingleton<AddWalletMoney>(
    () => AddWalletMoney(sl<WalletRepository>()),
  );
  sl.registerLazySingleton<ChargeWallet>(
    () => ChargeWallet(sl<WalletRepository>()),
  );
  sl.registerLazySingleton<RefundWallet>(
    () => RefundWallet(sl<WalletRepository>()),
  );
  sl.registerLazySingleton<AddWalletPaymentMethod>(
    () => AddWalletPaymentMethod(sl<WalletRepository>()),
  );
  sl.registerLazySingleton<SetDefaultWalletPaymentMethod>(
    () => SetDefaultWalletPaymentMethod(sl<WalletRepository>()),
  );
  sl.registerLazySingleton<RemoveWalletPaymentMethod>(
    () => RemoveWalletPaymentMethod(sl<WalletRepository>()),
  );
  sl.registerFactory<WalletController>(
    () => WalletController(
      getWalletSnapshot: sl<GetWalletSnapshot>(),
      addWalletMoney: sl<AddWalletMoney>(),
      addPaymentMethod: sl<AddWalletPaymentMethod>(),
      setDefaultPaymentMethod: sl<SetDefaultWalletPaymentMethod>(),
      removePaymentMethod: sl<RemoveWalletPaymentMethod>(),
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

  // Clinical Prescriptions
  if (useMock) {
    sl.registerLazySingleton<ClinicalPrescriptionRepository>(
      () => MockClinicalPrescriptionRepository(),
    );
  } else {
    sl.registerLazySingleton<ClinicalPrescriptionRemoteDataSource>(
      () => ClinicalPrescriptionRemoteDataSource(
        apiClient: sl<ApiClient>(),
        tokenProvider: () async {
          try {
            return Supabase.instance.client.auth.currentSession?.accessToken;
          } catch (_) {
            return null;
          }
        },
      ),
    );
    sl.registerLazySingleton<ClinicalPrescriptionRepository>(
      () => ClinicalPrescriptionRepositoryImpl(
        remoteDataSource: sl<ClinicalPrescriptionRemoteDataSource>(),
      ),
    );
  }

  // Medical Records
  if (useMock) {
    sl.registerLazySingleton<MedicalRecordsRepository>(
      () => MockMedicalRecordsRepository(),
    );
  } else {
    sl.registerLazySingleton<MedicalRecordsRemoteDataSource>(
      () => MedicalRecordsRemoteDataSource(
        apiClient: sl<ApiClient>(),
        tokenProvider: () async {
          try {
            return Supabase.instance.client.auth.currentSession?.accessToken;
          } catch (_) {
            return null;
          }
        },
        supabaseClient: () {
          try {
            return Supabase.instance.client;
          } catch (_) {
            return null;
          }
        }(),
      ),
    );
    sl.registerLazySingleton<MedicalRecordsRepository>(
      () => MedicalRecordsRepositoryImpl(
        remoteDataSource: sl<MedicalRecordsRemoteDataSource>(),
      ),
    );
  }

  sl.registerFactory<ClinicalPrescriptionsController>(
    () => ClinicalPrescriptionsController(
      repository: sl<ClinicalPrescriptionRepository>(),
    ),
  );

  sl.registerFactory<MedicalRecordsController>(
    () => MedicalRecordsController(repository: sl<MedicalRecordsRepository>()),
  );
}
