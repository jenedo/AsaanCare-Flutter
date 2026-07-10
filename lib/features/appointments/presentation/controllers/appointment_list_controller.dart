// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/appointment_record.dart';
import '../../domain/exceptions/appointment_exception.dart';
import '../../domain/usecases/get_appointments.dart';

enum AppointmentListStatus { initial, loading, loaded, empty, error }

class AppointmentListController extends ChangeNotifier {
  AppointmentListController({required GetAppointments getAppointments})
    : _getAppointments = getAppointments;

  final GetAppointments _getAppointments;

  UnmodifiableListView<AppointmentRecord> _appointments =
      UnmodifiableListView<AppointmentRecord>(const []);

  AppointmentListStatus _status = AppointmentListStatus.initial;
  String? _errorMessage;

  UnmodifiableListView<AppointmentRecord> get appointments => _appointments;

  AppointmentListStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isInitial => _status == AppointmentListStatus.initial;
  bool get isLoading => _status == AppointmentListStatus.loading;
  bool get hasError => _status == AppointmentListStatus.error;
  bool get isEmpty => _status == AppointmentListStatus.empty;

  UnmodifiableListView<AppointmentRecord> get upcomingAppointments =>
      UnmodifiableListView<AppointmentRecord>(
        _appointments
            .where((appointment) => appointment.isUpcoming)
            .toList(growable: false),
      );

  UnmodifiableListView<AppointmentRecord> get historyAppointments =>
      UnmodifiableListView<AppointmentRecord>(
        _appointments
            .where((appointment) => appointment.isHistory)
            .toList(growable: false),
      );

  Future<void> load({
    required String patientId,
    bool forceRefresh = false,
  }) async {
    if (_status == AppointmentListStatus.loading) return;

    if (!forceRefresh &&
        (_status == AppointmentListStatus.loaded ||
            _status == AppointmentListStatus.empty)) {
      return;
    }

    _setState(status: AppointmentListStatus.loading, errorMessage: null);

    try {
      final appointments = await _getAppointments(patientId: patientId);

      _appointments = UnmodifiableListView<AppointmentRecord>(appointments);

      _setState(
        status: appointments.isEmpty
            ? AppointmentListStatus.empty
            : AppointmentListStatus.loaded,
        errorMessage: null,
      );
    } on AppointmentException catch (error, stackTrace) {
      AppLogger.error('AppointmentListController.load', error, stackTrace);

      _setState(
        status: AppointmentListStatus.error,
        errorMessage: error.message,
      );
    } catch (error, stackTrace) {
      AppLogger.error('AppointmentListController.load', error, stackTrace);

      _setState(
        status: AppointmentListStatus.error,
        errorMessage: 'Could not load appointments. Please try again.',
      );
    }
  }

  Future<void> refresh(String patientId) {
    return load(patientId: patientId, forceRefresh: true);
  }

  void _setState({
    required AppointmentListStatus status,
    required String? errorMessage,
  }) {
    _status = status;
    _errorMessage = errorMessage;
    notifyListeners();
  }
}
