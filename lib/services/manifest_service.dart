import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/kalo_manifest.dart';
import 'network_service.dart';

class ManifestService {
  ManifestService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<KaloManifest> fetchManifest() async {
    final uri = Uri.parse('${NetworkService.serverUrl}/manifest');

    final response = await _httpClient
        .get(uri)
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw ManifestException(
        'Server trả về HTTP ${response.statusCode} khi tải manifest.',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! Map) {
      throw const ManifestException('Manifest không phải là một JSON object.');
    }

    return KaloManifest.fromJson(Map<String, dynamic>.from(decoded));
  }

  void dispose() {
    _httpClient.close();
  }
}

class ManifestException implements Exception {
  const ManifestException(this.message);

  final String message;

  @override
  String toString() => 'ManifestException: $message';
}
