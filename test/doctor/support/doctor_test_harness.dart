import 'package:asaancare/doctor/features/dashboard/data/datasources/doctor_dashboard_mock_data_source.dart';
import 'package:asaancare/doctor/features/dashboard/data/repositories/doctor_dashboard_repository_impl.dart';
import 'package:asaancare/doctor/features/dashboard/domain/usecases/doctor_dashboard_usecases.dart';
import 'package:asaancare/doctor/features/dashboard/presentation/controllers/doctor_dashboard_controller.dart';
import 'package:asaancare/doctor/features/finance/data/datasources/doctor_finance_mock_data_source.dart';
import 'package:asaancare/doctor/features/finance/data/repositories/doctor_finance_repository_impl.dart';
import 'package:asaancare/doctor/features/finance/domain/usecases/get_doctor_finance.dart';
import 'package:asaancare/doctor/features/finance/presentation/controllers/doctor_finance_controller.dart';
import 'package:asaancare/doctor/screens/dashboard/doctor_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class DoctorTestHarness {
  DoctorTestHarness({required this.dashboard, required this.finance});

  final DoctorDashboardController dashboard;
  final DoctorFinanceController finance;

  void dispose() {
    dashboard.dispose();
    finance.dispose();
  }
}

DoctorTestHarness createDoctorTestHarness({
  Duration actionDelay = Duration.zero,
}) {
  final dashboardRepository = DoctorDashboardRepositoryImpl(
    dataSource: DoctorDashboardMockDataSource(
      loadDelay: Duration.zero,
      actionDelay: actionDelay,
    ),
  );
  final financeRepository = DoctorFinanceRepositoryImpl(
    dataSource: DoctorFinanceMockDataSource(loadDelay: Duration.zero),
  );
  return DoctorTestHarness(
    dashboard: DoctorDashboardController(
      getDashboard: GetDoctorDashboard(dashboardRepository),
      updateAppointmentStatus: UpdateDoctorAppointmentStatus(
        dashboardRepository,
      ),
      updateAvailability: UpdateDoctorAvailability(dashboardRepository),
    ),
    finance: DoctorFinanceController(
      getFinance: GetDoctorFinance(financeRepository),
    ),
  );
}

Future<DoctorTestHarness> pumpDoctorDashboard(
  WidgetTester tester, {
  Size size = const Size(393, 852),
  Duration actionDelay = Duration.zero,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  final harness = createDoctorTestHarness(actionDelay: actionDelay);
  await Future.wait([
    harness.dashboard.load(doctorId: 'doctor-authenticated-1'),
    harness.finance.load(doctorId: 'doctor-authenticated-1'),
  ]);
  await tester.pumpWidget(
    _DoctorDashboardHost(
      dashboardController: harness.dashboard,
      financeController: harness.finance,
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return harness;
}

class _DoctorDashboardHost extends StatefulWidget {
  const _DoctorDashboardHost({
    required this.dashboardController,
    required this.financeController,
  });

  final DoctorDashboardController dashboardController;
  final DoctorFinanceController financeController;

  @override
  State<_DoctorDashboardHost> createState() => _DoctorDashboardHostState();
}

class _DoctorDashboardHostState extends State<_DoctorDashboardHost> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      theme: ThemeData(colorSchemeSeed: const Color(0xFF008F8C)),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF35C7BE),
      ),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: DoctorDashboardScreen(
        doctorId: 'doctor-authenticated-1',
        doctorName: 'Dr. Sara Khan',
        dashboardController: widget.dashboardController,
        financeController: widget.financeController,
        isDarkMode: _dark,
        onThemeToggle: () => setState(() => _dark = !_dark),
      ),
    );
  }
}
