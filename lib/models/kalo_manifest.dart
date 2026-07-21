class KaloManifest {
  const KaloManifest({
    required this.schemaVersion,
    required this.libraryVersion,
    required this.generatedAt,
    required this.reportedVideoCount,
    required this.syncMode,
    required this.wifiOnlyRecommended,
    required this.videos,
    required this.raw,
  });

  final int schemaVersion;
  final int libraryVersion;
  final DateTime? generatedAt;
  final int reportedVideoCount;
  final String syncMode;
  final bool wifiOnlyRecommended;
  final List<KaloVideo> videos;
  final Map<String, dynamic> raw;

  int get videoCount => videos.length;

  List<KaloVideo> get activeVideos =>
      videos.where((video) => video.active).toList(growable: false);

  factory KaloManifest.fromJson(Map<String, dynamic> json) {
    final rawVideos = json['videos'];

    final videos = rawVideos is List
        ? rawVideos
            .whereType<Map>()
            .map(
              (item) => KaloVideo.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <KaloVideo>[];

    return KaloManifest(
      schemaVersion: _asInt(json['schema_version']),
      libraryVersion: _asInt(json['library_version']),
      generatedAt: DateTime.tryParse((json['generated_at'] ?? '').toString()),
      reportedVideoCount: _asInt(
        json['video_count'],
        fallback: videos.length,
      ),
      syncMode: (json['sync_mode'] ?? 'mirror').toString(),
      wifiOnlyRecommended: json['wifi_only_recommended'] == true,
      videos: List<KaloVideo>.unmodifiable(videos),
      raw: Map<String, dynamic>.unmodifiable(json),
    );
  }

  static int _asInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class KaloVideo {
  const KaloVideo({
    required this.id,
    required this.file,
    required this.url,
    required this.thumbnail,
    required this.caption,
    required this.width,
    required this.height,
    required this.fps,
    required this.duration,
    required this.size,
    required this.sha256,
    required this.active,
  });

  final String id;
  final String file;
  final String url;
  final String thumbnail;
  final String caption;
  final int width;
  final int height;
  final double fps;
  final double duration;
  final int size;
  final String sha256;
  final bool active;

  String get normalizedSha256 => sha256.trim().toLowerCase();

  factory KaloVideo.fromJson(Map<String, dynamic> json) {
    return KaloVideo(
      id: (json['id'] ?? '').toString(),
      file: (json['file'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      thumbnail: (json['thumbnail'] ?? '').toString(),
      caption: (json['caption'] ?? '').toString(),
      width: _asInt(json['width']),
      height: _asInt(json['height']),
      fps: _asDouble(json['fps']),
      duration: _asDouble(json['duration']),
      size: _asInt(json['size']),
      sha256: (json['sha256'] ?? '').toString(),
      active: json['active'] != false,
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
