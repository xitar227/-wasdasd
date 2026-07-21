import 'package:flutter/material.dart';

import '../models/video_item.dart';
import '../services/video_library_service.dart';
import '../services/video_queue_service.dart';
import '../widgets/video_screen.dart';

class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({super.key});

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  final VideoLibraryService _libraryService = VideoLibraryService();
  final VideoQueueService _queueService = VideoQueueService();

  PageController? _pageController;
  List<VideoItem> _allVideos = <VideoItem>[];
  Map<String, VideoItem> _videoById = <String, VideoItem>{};
  List<String> _queueIds = <String>[];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final videos = await _libraryService.loadVideos();
      final state = await _queueService.load(videos);

      if (!mounted) return;
      setState(() {
        _allVideos = videos;
        _videoById = {for (final video in videos) video.id: video};
        _queueIds = List<String>.from(state.queueIds);
        _currentIndex = state.initialIndex;
        _pageController = PageController(initialPage: state.initialIndex);
        _isLoading = false;
      });

      _ensureAnotherRound();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _changeVideo(int index) async {
    setState(() => _currentIndex = index);
    _ensureAnotherRound();
    await _queueService.saveProgress(
      queueIds: _queueIds,
      index: index,
      availableVideos: _allVideos,
    );
  }

  void _ensureAnotherRound() {
    if (_allVideos.isEmpty || _queueIds.isEmpty) return;

    if (_currentIndex >= _queueIds.length - 2) {
      final nextRound = _queueService.createNextRound(
        _allVideos,
        previousId: _queueIds.last,
      );
      setState(() => _queueIds.addAll(nextRound));
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _queueIds.isEmpty || _pageController == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              _error == null
                  ? 'Chưa có video. Hãy chép video vào assets/import/ rồi chạy QUAN_LY_VIDEO.bat.'
                  : 'Không thể tải thư viện video.\n\n$_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemCount: _queueIds.length,
        onPageChanged: _changeVideo,
        itemBuilder: (context, index) {
          final video = _videoById[_queueIds[index]];
          if (video == null) return const ColoredBox(color: Colors.black);

          // Chỉ giữ video hiện tại và hai video sát cạnh trong cây widget.
          // Các controller ở xa được dispose để RAM không tăng theo số video.
          if ((index - _currentIndex).abs() > 1) {
            return const ColoredBox(color: Colors.black);
          }

          return VideoScreen(
            key: ValueKey('${video.id}-$index'),
            video: video,
            feedIndex: index,
            isActive: _currentIndex == index,
          );
        },
      ),
    );
  }
}
