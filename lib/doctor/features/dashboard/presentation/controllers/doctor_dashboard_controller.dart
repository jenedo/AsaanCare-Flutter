import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../domain/entities/doctor_dashboard_snapshot.dart';
import '../../domain/usecases/doctor_dashboard_usecases.dart';

class DoctorDashboardController extends ChangeNotifier {
  DoctorDashboardController({
    required this._getDashboard,
    required this._updateAppointmentStatus,
    required this._updateAvailability,
  });

  final GetDoctorDashboard _getDashboard;
  final UpdateDoctorAppointmentStatus _updateAppointmentStatus;
  final UpdateDoctorAvailability _updateAvailability;
  final Set<String> _updatingIds = <String>{};
  bool _isUpdatingAvailability = false;

  DoctorDashboardLoadStatus _status = DoctorDashboardLoadStatus.initial;
  DoctorDashboardSnapshot? _snapshot;
  DoctorAppointmentFilter _appointmentFilter = DoctorAppointmentFilter.all;
  String? _doctorId;
  String? _errorMessage;

  DoctorDashboardLoadStatus get status => _status;
  DoctorDashboardSnapshot? get snapshot => _snapshot;
  DoctorAppointmentFilter get appointmentFilter => _appointmentFilter;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == DoctorDashboardLoadStatus.loading;
  int get notificationCount =>
      _snapshot?.unreadNotifications ?? pendingRequests.length;

  UnmodifiableListView<DoctorAppointmentRecord> get pendingRequests =>
      UnmodifiableListView(
        (_snapshot?.appointments ?? const <DoctorAppointmentRecord>[]).where(
          (item) => item.status == DoctorAppointmentStatus.pending,
        ),
      );

  UnmodifiableListView<DoctorAppointmentRecord> get todayAppointments {
    final now = DateTime.now();
    return UnmodifiableListView(
      (_snapshot?.appointments ?? const <DoctorAppointmentRecord>[])
          .where((item) => _isSameDay(item.scheduledAt, now))
          .where((item) => item.status != DoctorAppointmentStatus.cancelled)
          .toList(growable: false)
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt)),
    );
  }

  UnmodifiableListView<DoctorAppointmentRecord> get filteredAppointments {
    final records =
        _snapshot?.appointments ?? const <DoctorAppointmentRecord>[];
    return UnmodifiableListView(
      records.where(
        (item) => switch (_appointmentFilter) {
          DoctorAppointmentFilter.all =>
            item.status != DoctorAppointmentStatus.cancelled,
          DoctorAppointmentFilter.pending =>
            item.status == DoctorAppointmentStatus.pending,
          DoctorAppointmentFilter.completed =>
            item.status == DoctorAppointmentStatus.completed,
        },
      ),
    );
  }

  int get completedCount => (_snapshot?.appointments ?? const [])
      .where((item) => item.status == DoctorAppointmentStatus.completed)
      .length;

  Future<void> load({required String doctorId, bool force = false}) async {
    final normalizedId = doctorId.trim();
    if (normalizedId.isEmpty) {
      _status = DoctorDashboardLoadStatus.failure;
      _errorMessage = 'A verified doctor session is required.';
      notifyListeners();
      return;
    }
    if (!force && _doctorId == normalizedId && _snapshot != null) return;
    _doctorId = normalizedId;
    _status = DoctorDashboardLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _snapshot = await _getDashboard(doctorId: normalizedId);
      _status = _snapshot!.appointments.isEmpty
          ? DoctorDashboardLoadStatus.empty
          : DoctorDashboardLoadStatus.ready;
    } catch (_) {
      _status = DoctorDashboardLoadStatus.failure;
      _errorMessage = 'Could not load the doctor dashboard. Please retry.';
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    final doctorId = _doctorId;
    if (doctorId != null) await load(doctorId: doctorId, force: true);
  }

  void selectAppointmentFilter(DoctorAppointmentFilter filter) {
    if (_appointmentFilter == filter) return;
    _appointmentFilter = filter;
    notifyListeners();
  }

  bool isUpdating(String appointmentId) => _updatingIds.contains(appointmentId);
  bool get isUpdatingAvailability => _isUpdatingAvailability;

  Future<void> acceptRequest(String appointmentId) {
    return updateStatus(appointmentId, DoctorAppointmentStatus.confirmed);
  }

  Future<void> rejectRequest(String appointmentId) {
    return updateStatus(appointmentId, DoctorAppointmentStatus.cancelled);
  }

  Future<void> setAvailability(bool isOnline) async {
    final doctorId = _doctorId;
    if (doctorId == null || _isUpdatingAvailability) return;
    final previous = _snapshot?.profile.isOnline;
    // Optimistic local update so the switch feels immediate.
    if (_snapshot != null) {
      _snapshot = _snapshot!.copyWith(
        profile: _snapshot!.profile.copyWith(isOnline: isOnline),
      );
    }
    _isUpdatingAvailability = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _snapshot = await _updateAvailability(
        doctorId: doctorId,
        isOnline: isOnline,
      );
      _status = DoctorDashboardLoadStatus.ready;
    } catch (_) {
      if (_snapshot != null && previous != null) {
        _snapshot = _snapshot!.copyWith(
          profile: _snapshot!.profile.copyWith(isOnline: previous),
        );
      }
      _errorMessage = 'Could not update availability. Try again.';
    } finally {
      _isUpdatingAvailability = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(
    String appointmentId,
    DoctorAppointmentStatus status,
  ) async {
    final doctorId = _doctorId;
    if (doctorId == null || _updatingIds.contains(appointmentId)) return;
    _updatingIds.add(appointmentId);
    _errorMessage = null;
    notifyListeners();
    try {
      _snapshot = await _updateAppointmentStatus(
        doctorId: doctorId,
        appointmentId: appointmentId,
        status: status,
      );
      _status = DoctorDashboardLoadStatus.ready;
    } catch (_) {
      _errorMessage = 'The appointment could not be updated. Try again.';
    } finally {
      _updatingIds.remove(appointmentId);
      notifyListeners();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
