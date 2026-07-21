import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/sync_models.dart';

class StorageService {
  Future<Directory> get videoDirectory async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'kalo_videos'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<List<LocalVideo>> readLocalVideos() async {
    final dir = await videoDirectory;
    final result = <LocalVideo>[];
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File || entity.path.endsWith('.part')) continue;
      final stat = await entity.stat();
      result.add(LocalVideo(
        fileName: p.basename(entity.path),
        path: entity.path,
        size: stat.size,
        sha256: await calculateSha256(entity),
      ));
    }
    return result;
  }

  Future<String> calculateSha256(File file) async =>
      (await sha256.bind(file.openRead()).first).toString().toLowerCase();

  Future<File> destinationFile(String name) async {
    final safe = p.basename(name.trim());
    if (safe.isEmpty || safe == '.' || safe == '..') {
      throw const FileSystemException('Tên video không hợp lệ');
    }
    return File(p.join((await videoDirectory).path, safe));
  }

  Future<File> temporaryFile(String name) async =>
      File('${(await destinationFile(name)).path}.part');

  Future<void> delete(File file) async {
    if (await file.exists()) await file.delete();
  }
}
