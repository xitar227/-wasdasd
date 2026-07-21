class VideoItem {
  const VideoItem({
    required this.id,
    required this.assetPath,
    required this.caption,
    required this.hashtags,
    required this.createdAt,
  });

  final String id;
  final String assetPath;
  final String caption;
  final List<String> hashtags;
  final DateTime? createdAt;

  String get hashtagText => hashtags.join(' ');

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    final rawHashtags = json['hashtags'];
    final hashtags = rawHashtags is List
        ? rawHashtags
            .whereType<Object>()
            .map((value) => value.toString().trim())
            .where((value) => value.isNotEmpty)
            .map((value) => value.startsWith('#') ? value : '#$value')
            .toList(growable: false)
        : const <String>[];

    return VideoItem(
      id: json['id']?.toString().trim() ?? '',
      assetPath: json['file']?.toString().trim() ?? '',
      caption: json['caption']?.toString().trim() ?? '',
      hashtags: hashtags,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
