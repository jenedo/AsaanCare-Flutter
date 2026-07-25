// ignore_for_file: prefer_initializing_formals
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/clinical_prescription_model.dart';

class ClinicalPrescriptionRemoteDataSource {
  ClinicalPrescriptionRemoteDataSource({
    required ApiClient apiClient,
    AccessTokenProvider? tokenProvider,
  }) : _apiClient = apiClient,
       _tokenProvider = tokenProvider;

  final ApiClient _apiClient;
  final AccessTokenProvider? _tokenProvider;

  Future<String> _requireToken() async {
    final provider = _tokenProvider;
    if (provider == null) {
      throw const ApiException('Unauthenticated session.', statusCode: 401);
    }
    final token = await provider();
    if (token == null || token.trim().isEmpty) {
      throw const ApiException('Unauthenticated session.', statusCode: 401);
    }
    return token.trim();
  }

  Future<List<ClinicalPrescriptionModel>> getClinicalPrescriptions() async {
    final token = await _requireToken();
    final json = await _apiClient.getJson(
      ApiEndpoints.prescriptions,
      bearerToken: token,
    );

    final rawList = json['data'] ?? json['items'] ?? json;
    if (rawList is List) {
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(ClinicalPrescriptionModel.fromJson)
          .toList(growable: false);
    }

    throw const ApiException(
      'Unexpected response structure for prescriptions list.',
    );
  }

  Future<ClinicalPrescriptionModel> getClinicalPrescription(String id) async {
    final token = await _requireToken();
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const ApiException('Prescription ID is required.', statusCode: 400);
    }

    final json = await _apiClient.getJson(
      '${ApiEndpoints.prescriptions}/$trimmedId',
      bearerToken: token,
    );

    final map = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return ClinicalPrescriptionModel.fromJson(map);
  }
}
