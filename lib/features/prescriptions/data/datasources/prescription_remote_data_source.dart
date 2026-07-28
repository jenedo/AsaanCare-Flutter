// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/prescription_record.dart';

class PrescriptionRemoteDataSource {
  PrescriptionRemoteDataSource({
    required ApiClient apiClient,
    AccessTokenProvider? tokenProvider,
    SupabaseClient? supabaseClient,
    http.Client? httpClient,
  }) : _apiClient = apiClient,
       _tokenProvider = tokenProvider,
       _supabaseClient = supabaseClient,
       _httpClient = httpClient;

  final ApiClient _apiClient;
  final AccessTokenProvider? _tokenProvider;
  final SupabaseClient? _supabaseClient;
  final http.Client? _httpClient;

  Future<String> _requireToken() async {
    final provider = _tokenProvider;
    String? token;
    if (provider != null) {
      token = await provider();
    }
    if (token == null || token.trim().isEmpty) {
      try {
        token = Supabase.instance.client.auth.currentSession?.accessToken;
      } catch (_) {}
    }
    if (token == null || token.trim().isEmpty) {
      throw const ApiException('Unauthenticated session.', statusCode: 401);
    }
    return token.trim();
  }

  Future<List<PrescriptionRecord>> getPrescriptions({
    required String patientId,
  }) async {
    final token = await _requireToken();
    final response = await _apiClient.getJson(
      ApiEndpoints.prescriptions,
      bearerToken: token,
    );

    final rawList = response['data'] ?? response['prescriptions'] ?? response;
    if (rawList is List) {
      return rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => _mapToPrescriptionRecord(json, patientId))
          .toList(growable: false);
    }

    return const [];
  }

  Future<PrescriptionRecord> uploadPrescription({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    final token = await _requireToken();

    final normalizedMime = contentType.trim().toLowerCase();
    final intentResponse = await _apiClient.postJson(
      '${ApiEndpoints.medicalRecords}/upload-intent',
      bearerToken: token,
      body: {
        'mimeType': normalizedMime,
        'sizeBytes': fileBytes.lengthInBytes,
        'purpose': 'PRESCRIPTION',
      },
    );

    final intentData = (intentResponse['data'] is Map<String, dynamic>)
        ? intentResponse['data'] as Map<String, dynamic>
        : intentResponse;

    final storedObjectId =
        intentData['id']?.toString() ??
        intentData['storedObjectId']?.toString();
    final uploadUrl = intentData['uploadUrl']?.toString();
    final bucket = intentData['bucket']?.toString();
    final objectPath =
        intentData['path']?.toString() ?? intentData['objectPath']?.toString();

    if (uploadUrl != null &&
        uploadUrl.isNotEmpty &&
        bucket != null &&
        objectPath != null) {
      await _uploadToSignedUrl(
        uploadUrl: uploadUrl,
        bucket: bucket,
        objectPath: objectPath,
        fileBytes: fileBytes,
        mimeType: normalizedMime,
      );
    }

    if (storedObjectId != null && storedObjectId.isNotEmpty) {
      final confirmResponse = await _apiClient.postJson(
        '${ApiEndpoints.medicalRecords}/confirm',
        bearerToken: token,
        body: {'storedObjectId': storedObjectId},
      );

      final confirmData = (confirmResponse['data'] is Map<String, dynamic>)
          ? confirmResponse['data'] as Map<String, dynamic>
          : confirmResponse;

      return PrescriptionRecord(
        id: confirmData['id']?.toString() ?? storedObjectId,
        patientId: patientId,
        fileName: fileName,
        fileBytes: fileBytes,
        uploadedAt:
            DateTime.tryParse(confirmData['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        source: PrescriptionSource.patientUploaded,
        status: PrescriptionStatus.pending,
        recordType: HealthRecordType.prescription,
        title: 'Uploaded Prescription',
        summary: fileName,
        issuer: 'Patient Upload',
      );
    }

    return PrescriptionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      fileName: fileName,
      fileBytes: fileBytes,
      uploadedAt: DateTime.now(),
      source: PrescriptionSource.patientUploaded,
      status: PrescriptionStatus.pending,
      recordType: HealthRecordType.prescription,
      title: 'Uploaded Prescription',
      summary: fileName,
      issuer: 'Patient Upload',
    );
  }

  Future<void> deletePrescription({
    required String patientId,
    required String prescriptionId,
  }) async {
    // Prescriptions are immutable clinical records server-side.
    // Local UI removal is managed via repo state.
    return;
  }

  Future<void> _uploadToSignedUrl({
    required String uploadUrl,
    required String bucket,
    required String objectPath,
    required Uint8List fileBytes,
    required String mimeType,
  }) async {
    final uri = Uri.tryParse(uploadUrl);
    if (uri == null) return;

    final token = uri.queryParameters['token']?.trim();
    if (token != null && token.isNotEmpty) {
      SupabaseClient? client = _supabaseClient;
      if (client == null) {
        try {
          client = Supabase.instance.client;
        } catch (_) {}
      }
      if (client != null) {
        try {
          await client.storage
              .from(bucket)
              .uploadBinaryToSignedUrl(objectPath, token, fileBytes);
          return;
        } catch (_) {}
      }
    }

    final httpClient = _httpClient ?? http.Client();
    final request = http.Request('PUT', uri)
      ..bodyBytes = fileBytes
      ..headers['Content-Type'] = mimeType;

    final streamed = await httpClient.send(request);
    await http.Response.fromStream(streamed);
  }

  PrescriptionRecord _mapToPrescriptionRecord(
    Map<String, dynamic> json,
    String fallbackPatientId,
  ) {
    final doctorProfile = json['doctorProfile'] as Map<String, dynamic>?;
    final patientProfile = json['patientProfile'] as Map<String, dynamic>?;

    final issuerName = doctorProfile?['fullName']?.toString() ?? 'Doctor';
    final specialty = doctorProfile?['specialty']?.toString();
    final summaryText =
        json['instructions']?.toString() ??
        (specialty != null
            ? 'Prescription ($specialty)'
            : 'Issued Prescription');

    return PrescriptionRecord(
      id: json['id']?.toString() ?? '',
      patientId: patientProfile?['id']?.toString() ?? fallbackPatientId,
      fileName: 'Prescription_${json['id']}.pdf',
      uploadedAt:
          DateTime.tryParse(
            json['issuedAt']?.toString() ?? json['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
      source: PrescriptionSource.doctorIssued,
      status: PrescriptionStatus.reviewed,
      recordType: HealthRecordType.prescription,
      title: 'Prescription',
      summary: summaryText,
      issuer: issuerName,
    );
  }
}
