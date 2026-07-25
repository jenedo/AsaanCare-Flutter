// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/domain/exceptions/auth_exception.dart';
import '../../domain/entities/appointment_record.dart';
import '../../domain/entities/consultation_type.dart';
import '../../domain/exceptions/appointment_exception.dart';

class AppointmentRemoteDataSource {
  AppointmentRemoteDataSource({
    required ApiClient apiClient,
    required AccessTokenProvider tokenProvider,
  }) : _apiClient = apiClient,
       _tokenProvider = tokenProvider;

  final ApiClient _apiClient;
  final AccessTokenProvider _tokenProvider;

  Future<List<AppointmentRecord>> getAppointments({
    required String patientId,
  }) async {
    final token = await _getToken();
    final response = await _apiClient.getJson(
      ApiEndpoints.appointments,
      bearerToken: token,
      queryParameters: {'patientId': patientId.trim()},
    );

    final rawList = response['appointments'] ?? response['data'] ?? response;
    if (rawList is List) {
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(_mapAppointmentRecord)
          .toList(growable: false);
    }

    return const [];
  }

  Future<AppointmentRecord> bookAppointment({
    required String patientId,
    required String doctorId,
    required ConsultationType consultationType,
    required DateTime appointmentDate,
    required String dateLabel,
    required String timeLabel,
    required int totalFee,
  }) async {
    final token = await _getToken();

    final body = <String, dynamic>{
      'doctorProfileId': doctorId.trim(),
      'consultationType': consultationType.name.toUpperCase(),
      'slotStart': appointmentDate.toUtc().toIso8601String(),
    };

    try {
      final response = await _apiClient.postJson(
        ApiEndpoints.appointments,
        bearerToken: token,
        body: body,
      );

      final data = response['appointment'] ?? response['data'] ?? response;
      if (data is Map<String, dynamic>) {
        return _mapAppointmentRecord(data);
      }

      throw const AppointmentException(
        'Failed to book appointment. Unexpected response structure.',
      );
    } catch (error) {
      if (error is AppointmentException) rethrow;
      throw AppointmentException(error.toString());
    }
  }

  Future<String> _getToken() async {
    final token = await _tokenProvider();
    final currentSessionToken =
        Supabase.instance.client.auth.currentSession?.accessToken;
    final resolvedToken = token ?? currentSessionToken;

    if (resolvedToken == null || resolvedToken.trim().isEmpty) {
      throw const AuthException('Session expired. Please log in again.');
    }

    return resolvedToken.trim();
  }

  AppointmentRecord _mapAppointmentRecord(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString().toUpperCase() ?? 'PENDING';
    final status = switch (rawStatus) {
      'COMPLETED' => AppointmentStatus.completed,
      'CANCELLED' || 'REJECTED' => AppointmentStatus.cancelled,
      _ => AppointmentStatus.confirmed,
    };

    final rawType =
        json['consultationType']?.toString().toLowerCase() ?? 'video';
    final type = switch (rawType) {
      'audio' => ConsultationType.audio,
      'chat' => ConsultationType.chat,
      _ => ConsultationType.video,
    };

    final slotStart = json['slotStart'] != null
        ? DateTime.tryParse(json['slotStart'].toString())?.toLocal() ??
              DateTime.now()
        : DateTime.now();

    final doctorProfile = json['doctorProfile'] as Map<String, dynamic>?;
    final doctorName =
        doctorProfile?['fullName']?.toString() ??
        json['doctorName']?.toString() ??
        'Doctor';
    final doctorSpecialty =
        doctorProfile?['specialty']?.toString() ??
        json['doctorSpecialty']?.toString() ??
        'General Physician';

    return AppointmentRecord(
      id: json['id']?.toString() ?? '',
      patientId:
          json['patientProfileId']?.toString() ??
          json['patientId']?.toString() ??
          '',
      doctorId:
          json['doctorProfileId']?.toString() ??
          json['doctorId']?.toString() ??
          '',
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      doctorImageAsset:
          json['doctorImageAsset']?.toString() ??
          'assets/images/doctor_sara.png',
      consultationType: type,
      appointmentDate: slotStart,
      dateLabel: _formatDateLabel(slotStart),
      timeLabel: _formatTimeLabel(slotStart),
      totalFee: (json['totalFee'] as num?)?.toInt() ?? 1000,
      status: status,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal() ??
                DateTime.now()
          : DateTime.now(),
    );
  }

  String _formatDateLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTimeLabel(DateTime dateTime) {
    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
        ? dateTime.hour - 12
        : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
