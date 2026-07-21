import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/config.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getJson(String path) async {
    final uri = Uri.parse('${AppConfig.serverBaseUrl}$path');

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(AppConfig.requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'Server trả về lỗi HTTP ${response.statusCode} tại $path.',
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw ApiException('Dữ liệu tại $path không đúng định dạng JSON.');
      }
      return decoded;
    } on SocketException {
      throw const ApiException(
        'Không kết nối được Kalo Server. Hãy kiểm tra hai thiết bị cùng Wi-Fi và Server đang chạy.',
      );
    } on http.ClientException catch (error) {
      throw ApiException('Lỗi kết nối mạng: ${error.message}');
    } on FormatException {
      throw ApiException('Server trả về dữ liệu JSON không hợp lệ tại $path.');
    }
  }

  void close() => _client.close();
}
