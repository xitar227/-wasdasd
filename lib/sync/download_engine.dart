import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/kalo_manifest.dart';
import '../services/network_service.dart';
import '../services/storage_service.dart';

class DownloadReport {
  const DownloadReport(this.downloaded, this.failed);
  final int downloaded, failed;
}

class DownloadEngine {
  DownloadEngine(this.storage, this.network, {http.Client? client})
      : client = client ?? http.Client();

  final StorageService storage;
  final NetworkService network;
  final http.Client client;

  Future<DownloadReport> downloadAll(List<KaloVideo> queue) async {
    var ok = 0, failed = 0;
    for (final video in queue) {
      try {
        await _download(video);
        ok++;
      } catch (e) {
        failed++;
        print('[KALO] Tải lỗi ${video.file}: $e');
      }
    }
    return DownloadReport(ok, failed);
  }

  Future<void> _download(KaloVideo video) async {
    if (!await network.isWifi()) throw Exception('Wi-Fi đã ngắt');

    final raw = video.url.trim();
    final uri = Uri.parse(raw.startsWith('http')
        ? raw
        : '${NetworkService.serverUrl}${raw.startsWith('/') ? raw : '/$raw'}');

    final target = await storage.destinationFile(video.file);
    final temp = await storage.temporaryFile(video.file);
    await storage.delete(temp);

    final response = await client.send(http.Request('GET', uri))
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');

    final sink = temp.openWrite();
    await response.stream.pipe(sink);

    if (video.size > 0 && await temp.length() != video.size) {
      await storage.delete(temp);
      throw Exception('Sai kích thước');
    }
    if (video.normalizedSha256.isNotEmpty) {
      final actual = await storage.calculateSha256(temp);
      if (actual != video.normalizedSha256) {
        await storage.delete(temp);
        throw Exception('SHA-256 không khớp');
      }
    }

    if (await target.exists()) await target.delete();
    await temp.rename(target.path);
  }

  void dispose() => client.close();
}
