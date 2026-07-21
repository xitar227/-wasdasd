import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/video_item.dart';

class VideoLibraryService {
  static const metadataAsset = 'assets/data/videos.json';

  Future<List<VideoItem>> loadVideos() async {
    final raw = await rootBundle.loadString(metadataAsset);
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('videos.json phải là một danh sách JSON.');
    }

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final availableAssets = manifest.listAssets().toSet();
    final ids = <String>{};
    final items = <VideoItem>[];

    for (final entry in decoded) {
      if (entry is! Map) continue;
      final item = VideoItem.fromJson(Map<String, dynamic>.from(entry));
      if (item.id.isEmpty || item.assetPath.isEmpty) continue;
      if (!item.assetPath.toLowerCase().endsWith('.mp4')) continue;
      if (!availableAssets.contains(item.assetPath)) continue;
      if (!ids.add(item.id)) continue;
      items.add(item);
    }

    return items;
  }
}
