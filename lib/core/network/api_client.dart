// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../logging/app_logger.dart';
import 'api_exception.dart';

typedef JsonObject = Map<String, dynamic>;
typedef AccessTokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({
    required http.Client client,
    required String baseUrl,
    required Duration timeout,
    AccessTokenProvider? tokenProvider,
  }) : _client = client,
       _baseUrl = baseUrl.trim(),
       _timeout = timeout,
       _tokenProvider = tokenProvider;

  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;
  final AccessTokenProvider? _tokenProvider;

  Future<JsonObject> getJson(
    String path, {
    String? bearerToken,
    Map<String, String>? queryParameters,
  }) {
    return _send(
      method: 'GET',
      path: path,
      bearerToken: bearerToken,
      queryParameters: queryParameters,
    );
  }

  Future<JsonObject> postJson(
    String path, {
    String? bearerToken,
    JsonObject? body,
  }) {
    return _send(
      method: 'POST',
      path: path,
      bearerToken: bearerToken,
      body: body,
    );
  }

  Future<JsonObject> postMultipart(
    String path, {
    String? bearerToken,
    Map<String, String> fields = const {},
    List<http.MultipartFile> files = const [],
  }) async {
    final uri = _buildUri(path, null);
    final request = http.MultipartRequest('POST', uri)
      ..fields.addAll(fields)
      ..files.addAll(files)
      ..headers['Accept'] = 'application/json';

    final cleanToken = bearerToken?.trim();
    if (cleanToken != null && cleanToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $cleanToken';
    }

    try {
      final streamedResponse = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(_timeout);

      final decoded = _decodeBody(response);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _readMessage(decoded) ?? 'Request failed. Please try again.',
          statusCode: response.statusCode,
        );
      }

      if (decoded == null) return <String, dynamic>{};

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      if (decoded is List) {
        return <String, dynamic>{'data': decoded};
      }

      throw ApiException(
        'The server returned an unsupported response format.',
        statusCode: response.statusCode,
      );
    } on TimeoutException catch (error, stackTrace) {
      AppLogger.error('ApiClient.POST(multipart) $path', error, stackTrace);
      throw ApiException(
        'The request timed out. Check your connection and try again.',
        cause: error,
      );
    } on ApiException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error('ApiClient.POST(multipart) $path', error, stackTrace);
      throw ApiException(
        'Could not connect to the service. Please try again.',
        cause: error,
      );
    }
  }

  Future<JsonObject> _send({
    required String method,
    required String path,
    String? bearerToken,
    Map<String, String>? queryParameters,
    JsonObject? body,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final request = http.Request(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      });

    var cleanToken = bearerToken?.trim();
    final provider = _tokenProvider;
    if ((cleanToken == null || cleanToken.isEmpty) && provider != null) {
      try {
        cleanToken = (await provider())?.trim();
      } catch (_) {
        // Suppress token provider resolution errors and send request unauthenticated
      }
    }

    if (cleanToken != null && cleanToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $cleanToken';
    }

    if (body != null) {
      request.body = jsonEncode(body);
    }

    try {
      final streamedResponse = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(_timeout);

      final decoded = _decodeBody(response);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _readMessage(decoded) ?? 'Request failed. Please try again.',
          statusCode: response.statusCode,
        );
      }

      if (decoded == null) return <String, dynamic>{};

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      if (decoded is List) {
        return <String, dynamic>{'data': decoded};
      }

      throw ApiException(
        'The server returned an unsupported response format.',
        statusCode: response.statusCode,
      );
    } on TimeoutException catch (error, stackTrace) {
      AppLogger.error('ApiClient.$method $path', error, stackTrace);
      throw ApiException(
        'The request timed out. Check your connection and try again.',
        cause: error,
      );
    } on ApiException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error('ApiClient.$method $path', error, stackTrace);
      throw ApiException(
        'Could not connect to the service. Please try again.',
        cause: error,
      );
    }
  }

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final route = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$base$route').replace(
      queryParameters: queryParameters?.isEmpty == true
          ? null
          : queryParameters,
    );
  }

  Object? _decodeBody(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;

    final text = utf8.decode(response.bodyBytes).trim();
    if (text.isEmpty) return null;

    try {
      return jsonDecode(text);
    } on FormatException {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        throw ApiException(
          'The server returned invalid JSON.',
          statusCode: response.statusCode,
        );
      }

      return <String, dynamic>{'message': text};
    }
  }

  String? _readMessage(Object? decoded) {
    if (decoded is! Map) return null;

    final direct =
        _messageFrom(decoded['message']) ?? _messageFrom(decoded['error']);
    if (direct != null) return direct;

    final data = decoded['data'];
    if (data is Map) {
      return _messageFrom(data['message']) ?? _messageFrom(data['error']);
    }

    return null;
  }

  String? _messageFrom(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    if (value is Map) {
      return _messageFrom(value['message']) ?? _messageFrom(value['error']);
    }

    return null;
  }
}
