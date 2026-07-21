import 'package:path/path.dart' as p;

import '../models/kalo_manifest.dart';
import '../models/sync_models.dart';

class CompareEngine {
  const CompareEngine();

  SyncPlan buildPlan(
    KaloManifest manifest,
    List<LocalVideo> localVideos,
  ) {
    final active = manifest.activeVideos;

    final localByName = <String, LocalVideo>{
      for (final video in localVideos)
        p.basename(video.fileName).toLowerCase(): video,
    };

    final serverNames = <String>{
      for (final video in active)
        p.basename(video.file).toLowerCase(),
    };

    final download = <KaloVideo>[];
    final unchanged = <KaloVideo>[];

    for (final server in active) {
      final serverFileName = p.basename(server.file).toLowerCase();
      final local = localByName[serverFileName];
      final expectedHash = server.normalizedSha256;

      final isSame = local != null &&
          (expectedHash.isNotEmpty
              ? local.sha256.trim().toLowerCase() == expectedHash
              : server.size > 0 && local.size == server.size);

      if (isSame) {
        unchanged.add(server);
      } else {
        download.add(server);
      }
    }

    final delete = manifest.syncMode.toLowerCase() == 'mirror'
        ? localVideos
            .where(
              (video) => !serverNames.contains(
                p.basename(video.fileName).toLowerCase(),
              ),
            )
            .toList(growable: false)
        : <LocalVideo>[];

    return SyncPlan(
      toDownload: List.unmodifiable(download),
      toDelete: List.unmodifiable(delete),
      unchanged: List.unmodifiable(unchanged),
    );
  }
}
