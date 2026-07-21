class LibraryManifest {
  const LibraryManifest({
    required this.schemaVersion,
    required this.libraryVersion,
    required this.videoCount,
    required this.generatedAt,
  });

  final int schemaVersion;
  final Object? libraryVersion;
  final int videoCount;
  final DateTime? generatedAt;

  factory LibraryManifest.fromJson(Map<String, dynamic> json) {
    final videos = json['videos'];
    final rawCount = json['video_count'];
    final rawGeneratedAt = json['generated_at'];

    return LibraryManifest(
      schemaVersion: json['schema_version'] is int
          ? json['schema_version'] as int
          : int.tryParse(json['schema_version']?.toString() ?? '') ?? 0,
      libraryVersion: json['library_version'],
      videoCount: rawCount is int
          ? rawCount
          : int.tryParse(rawCount?.toString() ?? '') ??
              (videos is List ? videos.length : 0),
      generatedAt: rawGeneratedAt == null
          ? null
          : DateTime.tryParse(rawGeneratedAt.toString()),
    );
  }
}
