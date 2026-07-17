import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/doctor/features/dashboard/data/datasources/doctor_dashboard_mock_data_source.dart';
import 'package:asaancare/doctor/features/dashboard/data/repositories/doctor_dashboard_repository_impl.dart';
import 'package:asaancare/doctor/features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';
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
    );
  }

  test('loads a dashboard and exposes derived overview totals', () async {
    final controller = buildController(DoctorDashboardMockDataSource());

    await controller.load(doctorId: doctorId);

    expect(controller.status, DoctorDashboardLoadStatus.ready);
    expect(controller.snapshot, isNotNull);
    expect(controller.pendingRequests, isNotEmpty);
    expect(controller.todayAppointments.length, greaterThanOrEqualTo(3));
    expect(controller.notificationCount, controller.pendingRequests.length);
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
}
