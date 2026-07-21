import '../models/library_manifest.dart';
import '../models/server_status.dart';
import '../services/api_service.dart';

class ConnectionSnapshot {
  const ConnectionSnapshot({
    required this.status,
    required this.manifest,
  });

  final ServerStatus status;
  final LibraryManifest manifest;
}

class SyncRepository {
  SyncRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<ConnectionSnapshot> checkConnection() async {
    final results = await Future.wait<Map<String, dynamic>>([
      _apiService.getJson('/status'),
      _apiService.getJson('/manifest'),
    ]);

    return ConnectionSnapshot(
      status: ServerStatus.fromJson(results[0]),
      manifest: LibraryManifest.fromJson(results[1]),
    );
  }

  void close() => _apiService.close();
}
