import 'dart:io';
import 'kalo_manifest.dart';

class LocalVideo {
  const LocalVideo({required this.fileName, required this.path, required this.size, required this.sha256});
  final String fileName;
  final String path;
  final int size;
  final String sha256;
  File get file => File(path);
}

class SyncPlan {
  const SyncPlan({required this.toDownload, required this.toDelete, required this.unchanged});
  final List<KaloVideo> toDownload;
  final List<LocalVideo> toDelete;
  final List<KaloVideo> unchanged;
}

enum SyncStatus { completed, skippedNoWifi, skippedServerOffline, failed }

class SyncResult {
  const SyncResult({
    required this.status, required this.message,
    this.downloadedCount=0, this.deletedCount=0,
    this.unchangedCount=0, this.failedCount=0,
  });
  final SyncStatus status;
  final String message;
  final int downloadedCount, deletedCount, unchangedCount, failedCount;
}
