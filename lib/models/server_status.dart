class ServerStatus {
  const ServerStatus({
    required this.status,
    required this.serverName,
    required this.serverVersion,
    required this.libraryVersion,
    required this.videoCount,
    required this.generatedAt,
    required this.manifestSha256,
    required this.libraryError,
  });

  final String status;
  final String serverName;
  final String serverVersion;
  final Object? libraryVersion;
  final int videoCount;
  final DateTime? generatedAt;
  final String? manifestSha256;
  final String? libraryError;

  bool get isReady => status == 'ok';

  factory ServerStatus.fromJson(Map<String, dynamic> json) {
    final rawCount = json['video_count'];
    final rawGeneratedAt = json['generated_at'];

    return ServerStatus(
      status: json['status']?.toString() ?? 'unknown',
      serverName: json['server_name']?.toString() ?? 'Kalo Server',
      serverVersion: json['server_version']?.toString() ?? '?',
      libraryVersion: json['library_version'],
      videoCount: rawCount is int
          ? rawCount
          : int.tryParse(rawCount?.toString() ?? '') ?? 0,
      generatedAt: rawGeneratedAt == null
          ? null
          : DateTime.tryParse(rawGeneratedAt.toString()),
      manifestSha256: json['manifest_sha256']?.toString(),
      libraryError: json['library_error']?.toString(),
    );
  }
}
