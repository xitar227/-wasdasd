import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/video_item.dart';

class VideoQueueState {
  const VideoQueueState({
    required this.queueIds,
    required this.initialIndex,
  });

  final List<String> queueIds;
  final int initialIndex;
}

class VideoQueueService {
  static const _queueKey = 'video_queue_v3';
  static const _indexKey = 'video_queue_index_v3';
  static const _knownKey = 'known_video_ids_v3';

  final Random _random = Random();

  Future<VideoQueueState> load(List<VideoItem> videos) async {
    final preferences = await SharedPreferences.getInstance();
    final available = videos.map((video) => video.id).toList(growable: false);

    if (available.isEmpty) {
      return const VideoQueueState(queueIds: [], initialIndex: 0);
    }

    final savedQueue = _decodeList(preferences.getString(_queueKey));
    final savedKnown = _decodeList(preferences.getString(_knownKey)).toSet();
    final availableSet = available.toSet();
    final savedIndex = preferences.getInt(_indexKey) ?? 0;

    List<String> queue;
    if (savedQueue.isEmpty) {
      queue = List<String>.from(available);
    } else {
      final safeIndex = savedIndex.clamp(0, savedQueue.length - 1).toInt();
      queue = savedQueue
          .skip(safeIndex)
          .where(availableSet.contains)
          .toList(growable: true);

      if (queue.isEmpty) {
        queue = List<String>.from(available);
      }
    }

    // Video mới luôn được xem là chưa xem và được nối vào vòng hiện tại.
    final newVideos = available
        .where((id) => !savedKnown.contains(id) && !queue.contains(id))
        .toList(growable: false);
    queue.addAll(newVideos);

    await _saveState(
      preferences,
      queue: queue,
      index: 0,
      known: available,
    );

    return VideoQueueState(queueIds: queue, initialIndex: 0);
  }

  Future<void> saveProgress({
    required List<String> queueIds,
    required int index,
    required List<VideoItem> availableVideos,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await _saveState(
      preferences,
      queue: queueIds,
      index: index,
      known: availableVideos.map((video) => video.id).toList(growable: false),
    );
  }

  List<String> createNextRound(
    List<VideoItem> allVideos, {
    String? previousId,
  }) {
    final nextRound = allVideos.map((video) => video.id).toList()..shuffle(_random);

    if (nextRound.length > 1 && nextRound.first == previousId) {
      final swapIndex = 1 + _random.nextInt(nextRound.length - 1);
      final first = nextRound.first;
      nextRound[0] = nextRound[swapIndex];
      nextRound[swapIndex] = first;
    }

    return nextRound;
  }

  Future<void> _saveState(
    SharedPreferences preferences, {
    required List<String> queue,
    required int index,
    required List<String> known,
  }) async {
    await Future.wait([
      preferences.setString(_queueKey, jsonEncode(queue)),
      preferences.setInt(_indexKey, index),
      preferences.setString(_knownKey, jsonEncode(known)),
    ]);
  }

  List<String> _decodeList(String? value) {
    if (value == null || value.isEmpty) return <String>[];
    try {
      return (jsonDecode(value) as List<dynamic>)
          .map((value) => value.toString())
          .toList(growable: false);
    } catch (_) {
      return <String>[];
    }
  }
}
