import 'package:flutter/foundation.dart';
import '../models/sync_models.dart';
import '../services/manifest_service.dart';
import '../services/network_service.dart';
import '../services/storage_service.dart';
import 'compare_engine.dart';
import 'download_engine.dart';

class SyncEngine {
  SyncEngine()
      : network = NetworkService(),
        manifestService = ManifestService(),
        storage = StorageService() {
    downloader = DownloadEngine(storage, network);
  }

  final NetworkService network;
  final ManifestService manifestService;
  final StorageService storage;
  final CompareEngine comparer = const CompareEngine();
  late final DownloadEngine downloader;

  Future<SyncResult> run() async {
    debugPrint('========== KALO SPRINT 5.3 ==========');
    try {
      final wifi = await network.isWifi();
      debugPrint('Wi-Fi       : $wifi');
      if (!wifi) return const SyncResult(
        status: SyncStatus.skippedNoWifi,
        message: 'Bỏ qua vì không có Wi-Fi.',
      );

      final online = await network.isServerOnline();
      debugPrint('Server      : $online');
      if (!online) return const SyncResult(
        status: SyncStatus.skippedServerOffline,
        message: 'Server chưa sẵn sàng.',
      );

      final manifest = await manifestService.fetchManifest();
      final local = await storage.readLocalVideos();
      final plan = comparer.buildPlan(manifest, local);

      debugPrint('Schema      : ${manifest.schemaVersion}');
      debugPrint('Library     : ${manifest.libraryVersion}');
      debugPrint('Mode        : ${manifest.syncMode}');
      debugPrint('Active      : ${manifest.activeVideos.length}');
      debugPrint('Local       : ${local.length}');
      debugPrint('Download    : ${plan.toDownload.length}');
      debugPrint('Delete      : ${plan.toDelete.length}');
      debugPrint('Unchanged   : ${plan.unchanged.length}');

      final report = await downloader.downloadAll(plan.toDownload);
      var deleted = 0;

      // Chỉ xóa file thừa khi tất cả file cần tải đều thành công.
      if (report.failed == 0) {
        for (final item in plan.toDelete) {
          await storage.delete(item.file);
          deleted++;
        }
      }

      debugPrint('Downloaded  : ${report.downloaded}');
      debugPrint('Deleted     : $deleted');
      debugPrint('Failed      : ${report.failed}');
      debugPrint('Kết quả     : ${report.failed == 0 ? "Sprint 5.3 hoàn thành." : "Chưa hoàn tất."}');
      debugPrint('=====================================');

      return SyncResult(
        status: report.failed == 0 ? SyncStatus.completed : SyncStatus.failed,
        message: report.failed == 0 ? 'Sprint 5.3 hoàn thành.' : 'Đồng bộ chưa hoàn tất.',
        downloadedCount: report.downloaded,
        deletedCount: deleted,
        unchangedCount: plan.unchanged.length,
        failedCount: report.failed,
      );
    } catch (e, st) {
      debugPrint('Lỗi         : $e');
      debugPrintStack(stackTrace: st);
      return SyncResult(status: SyncStatus.failed, message: '$e', failedCount: 1);
    }
  }

  void dispose() {
    network.dispose();
    manifestService.dispose();
    downloader.dispose();
  }
}
