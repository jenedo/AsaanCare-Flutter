import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:asaancare/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test(
    'native client negotiates gzip, transparently decodes it, and parses JSON',
    () async {
      final payload = <String, dynamic>{
        'data': List.generate(
          100,
          (index) => <String, dynamic>{
            'id': 'appointment-$index',
            'status': 'CONFIRMED',
            'instructions': 'Join five minutes before the consultation.',
          },
        ),
      };
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final responseBody = gzip.encode(utf8.encode(jsonEncode(payload)));
      final requestHeaders = Completer<HttpHeaders>();
      final subscription = server.listen((request) async {
        requestHeaders.complete(request.headers);
        request.response
          ..headers.contentType = ContentType.json
          ..headers.set(HttpHeaders.contentEncodingHeader, 'gzip')
          ..add(responseBody);
        await request.response.close();
      });
      final transport = http.Client();
      final apiClient = ApiClient(
        client: transport,
        baseUrl: 'http://${server.address.host}:${server.port}',
        timeout: const Duration(seconds: 5),
      );

      try {
        final decoded = await apiClient.getJson('/appointments');
        final observedHeaders = await requestHeaders.future;

        expect(
          observedHeaders.value(HttpHeaders.acceptEncodingHeader),
          contains('gzip'),
        );
        expect(decoded, payload);
      } finally {
        transport.close();
        await subscription.cancel();
        await server.close(force: true);
      }
    },
  );
}
