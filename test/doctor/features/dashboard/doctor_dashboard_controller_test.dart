import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/doctor/features/dashboard/data/datasources/doctor_dashboard_mock_data_source.dart';
import 'package:asaancare/doctor/features/dashboard/data/repositories/doctor_dashboard_repository_impl.dart';
import 'package:asaancare/doctor/features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';
import 'package:asaancare/doctor/features/dashboard/domain/repositories/doctor_dashboard_repository.dart';
import 'package:asaancare/doctor/features/dashboard/domain/usecases/doctor_dashboard_usecases.dart';
import 'package:asaancare/doctor/features/dashboard/presentation/controllers/doctor_dashboard_controller.dart';

void main() {
  const doctorId = 'doctor-test';

  DoctorDashboardController buildController(
    DoctorDashboardMockDataSource dataSource,
  ) {
    final repository = DoctorDashboardRepositoryImpl(dataSource: dataSource);
    return DoctorDashboardController(
      getDashboard: GetDoctorDashboard(repository),
      updateAppointmentStatus: UpdateDoctorAppointmentStatus(repository),
      updateAvailability: UpdateDoctorAvailability(repository),
    );
  }

  DoctorDashboardController buildControllerWithRepository(
    DoctorDashboardRepository repository,
  ) {
    return DoctorDashboardController(
      getDashboard: GetDoctorDashboard(repository),
      updateAppointmentStatus: UpdateDoctorAppointmentStatus(repository),
      updateAvailability: UpdateDoctorAvailability(repository),
    );
  }

  test('loads a dashboard and exposes derived overview totals', () async {
    final controller = buildController(DoctorDashboardMockDataSource());

    await controller.load(doctorId: doctorId);

    expect(controller.status, DoctorDashboardLoadStatus.ready);
    expect(controller.snapshot, isNotNull);
    expect(controller.pendingRequests, isNotEmpty);
    expect(controller.todayAppointments.length, greaterThanOrEqualTo(3));
    expect(controller.notificationCount, 3);
    expect(
      controller.notificationCount,
      controller.snapshot!.unreadNotifications,
    );
  });

  test('appointment filters select pending and completed records', () async {
    final controller = buildController(DoctorDashboardMockDataSource());
    await controller.load(doctorId: doctorId);

    controller.selectAppointmentFilter(DoctorAppointmentFilter.pending);
    expect(
      controller.filteredAppointments,
      everyElement(
        predicate<DoctorAppointmentRecord>(
          (appointment) =>
              appointment.status == DoctorAppointmentStatus.pending,
        ),
      ),
    );

    controller.selectAppointmentFilter(DoctorAppointmentFilter.completed);
    expect(
      controller.filteredAppointments,
      everyElement(
        predicate<DoctorAppointmentRecord>(
          (appointment) =>
              appointment.status == DoctorAppointmentStatus.completed,
        ),
      ),
    );
  });

  test('accepting a request persists through the mock repository', () async {
    final dataSource = DoctorDashboardMockDataSource();
    final controller = buildController(dataSource);
    await controller.load(doctorId: doctorId);
    final request = controller.pendingRequests.first;

    await controller.acceptRequest(request.id);

    expect(controller.isUpdating(request.id), isFalse);
    expect(
      controller.snapshot!.appointments
          .firstWhere((appointment) => appointment.id == request.id)
          .status,
      DoctorAppointmentStatus.confirmed,
    );

    final reloaded = buildController(dataSource);
    await reloaded.load(doctorId: doctorId);
    expect(
      reloaded.snapshot!.appointments
          .firstWhere((appointment) => appointment.id == request.id)
          .status,
      DoctorAppointmentStatus.confirmed,
    );
  });

  test('duplicate request actions are ignored while one is pending', () async {
    final dataSource = DoctorDashboardMockDataSource(
      actionDelay: const Duration(milliseconds: 30),
    );
    final controller = buildController(dataSource);
    await controller.load(doctorId: doctorId);
    final request = controller.pendingRequests.first;

    final first = controller.acceptRequest(request.id);
    final second = controller.rejectRequest(request.id);
    await Future.wait([first, second]);

    expect(
      controller.snapshot!.appointments
          .firstWhere((appointment) => appointment.id == request.id)
          .status,
      DoctorAppointmentStatus.confirmed,
    );
  });

  test('reports empty when the repository has no appointments', () async {
    final controller = buildControllerWithRepository(
      _DashboardRepositoryStub(snapshot: _emptyDashboardSnapshot()),
    );

    await controller.load(doctorId: doctorId);

    expect(controller.status, DoctorDashboardLoadStatus.empty);
    expect(controller.snapshot, isNotNull);
    expect(controller.pendingRequests, isEmpty);
    expect(controller.filteredAppointments, isEmpty);
    expect(controller.errorMessage, isNull);
  });

  test('reports a safe failure message when loading throws', () async {
    final controller = buildControllerWithRepository(
      _DashboardRepositoryStub(error: StateError('private backend detail')),
    );

    await controller.load(doctorId: doctorId);

    expect(controller.status, DoctorDashboardLoadStatus.failure);
    expect(controller.snapshot, isNull);
    expect(
      controller.errorMessage,
      'Could not load the doctor dashboard. Please retry.',
    );
    expect(controller.errorMessage, isNot(contains('private backend detail')));
  });
}

DoctorDashboardSnapshot _emptyDashboardSnapshot() {
  return DoctorDashboardSnapshot(
    profile: const DoctorProfileSummary(
      id: 'doctor-test',
      name: 'Dr. Test',
      specialty: 'General Physician',
      imageAsset: '',
      isOnline: true,
    ),
    appointments: const <DoctorAppointmentRecord>[],
    unreadNotifications: 0,
  );
}

class _DashboardRepositoryStub implements DoctorDashboardRepository {
  const _DashboardRepositoryStub({this.snapshot, this.error});

  final DoctorDashboardSnapshot? snapshot;
  final Object? error;

  @override
  Future<DoctorDashboardSnapshot> getDashboard({required String doctorId}) {
    final failure = error;
    if (failure != null) return Future<DoctorDashboardSnapshot>.error(failure);
    return Future<DoctorDashboardSnapshot>.value(snapshot!);
  }

  @override
  Future<DoctorDashboardSnapshot> updateAppointmentStatus({
    required String doctorId,
    required String appointmentId,
    required DoctorAppointmentStatus status,
  }) {
    final failure = error;
    if (failure != null) return Future<DoctorDashboardSnapshot>.error(failure);
    return Future<DoctorDashboardSnapshot>.value(snapshot!);
  }

  @override
  Future<DoctorDashboardSnapshot> updateAvailability({
    required String doctorId,
    required bool isOnline,
  }) {
    final failure = error;
    if (failure != null) return Future<DoctorDashboardSnapshot>.error(failure);
    return Future<DoctorDashboardSnapshot>.value(snapshot!);
  }
}
