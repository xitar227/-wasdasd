import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/video_item.dart';
import 'action_button.dart';
import 'bottom_navigation_overlay.dart';
import 'top_feed_bar.dart';

class _CaptionPack {
  const _CaptionPack(this.caption, this.hashtags);

  final String caption;
  final String hashtags;
}

class VideoScreen extends StatefulWidget {
  const VideoScreen({
    super.key,
    required this.video,
    required this.feedIndex,
    required this.isActive,
  });

  final VideoItem video;
  final int feedIndex;
  final bool isActive;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with TickerProviderStateMixin {
  static const _captionPacks = <_CaptionPack>[
    _CaptionPack('Muốn thương thì phải hiểu.\nMuốn bên nhau thì phải tin. 💓', '#YêuThương #TinTưởng'),
    _CaptionPack('Chậm một chút cũng không sao.\nMiễn là mình vẫn đang tiến về phía trước. 🌱', '#SốngTíchCực #CốGắng'),
    _CaptionPack('Đúng người sẽ khiến bạn hiểu rằng\nyêu thương vốn dĩ rất bình yên.', '#TìnhYêu #BìnhYên'),
    _CaptionPack('Không cần hơn ai cả.\nHôm nay tốt hơn hôm qua là đủ rồi. ✨', '#ĐộngLực #MỗiNgàyMộtTốtHơn'),
    _CaptionPack('Có những ngày rất mệt.\nNhưng rồi mọi chuyện cũng sẽ ổn thôi.', '#ChữaLành #RồiSẽỔn'),
    _CaptionPack('Bình yên là khi có một người\nluôn muốn nghe bạn kể về một ngày của mình.', '#BìnhYên #YêuThương'),
    _CaptionPack('Đừng sợ bắt đầu muộn.\nChỉ sợ mình chưa từng bắt đầu.', '#BắtĐầu #CốGắng'),
    _CaptionPack('Gom bao nhiêu may mắn\nmới gặp được một người thật lòng. 🌸', '#MayMắn #ChânThành'),
    _CaptionPack('Hãy sống tử tế.\nĐiều tốt đẹp rồi sẽ tìm đường quay lại.', '#TửTế #SốngĐẹp'),
    _CaptionPack('Nghỉ ngơi không phải là bỏ cuộc.\nChỉ là mình đang lấy lại sức thôi.', '#ChữaLành #YêuBảnThân'),
    _CaptionPack('Tình yêu đẹp nhất là khi\nhai người cùng nhau trưởng thành.', '#TìnhYêu #TrưởngThành'),
    _CaptionPack('Mỗi ngày cố gắng một chút.\nRồi bạn sẽ cảm ơn chính mình của hôm nay.', '#ĐộngLực #SốngTíchCực'),
    _CaptionPack('Đừng quên mỉm cười với chính mình hôm nay. 🌸', '#NụCười #TíchCực'),
    _CaptionPack('Có những ngày chậm lại\nđể ngày mai mình đi được xa hơn. 🍀', '#BìnhYên #CuộcSống #ChậmLại'),
    _CaptionPack('Bạn xứng đáng với những điều tử tế nhất.', '#YêuBảnThân #TửTế'),
    _CaptionPack('Một chút dịu dàng cũng đủ làm ngày dài đẹp hơn.', '#DịuDàng #NgàyMới'),
    _CaptionPack('Không cần hoàn hảo.\nChỉ cần chân thành là đủ.', '#ChânThành #YêuThương'),
    _CaptionPack('Mọi chuyện rồi sẽ ổn\ntheo cách riêng của nó. ☀️', '#HyVọng #RồiSẽỔn'),
    _CaptionPack('Yêu đời một chút,\nđời sẽ yêu lại bạn nhiều hơn.', '#YêuĐời #SốngVui'),
    _CaptionPack('Hạnh phúc đôi khi chỉ là\nmột ngày bình thường nhưng lòng mình nhẹ tênh.', '#HạnhPhúc #BìnhYên'),
  ];

  static const _avatars = <String>[
    'assets/avatar/avatar01.jpg',
    'assets/avatar/avatar02.jpg',
    'assets/avatar/avatar03.jpg',
    'assets/avatar/avatar04.jpg',
    'assets/avatar/avatar05.jpg',
    'assets/avatar/avatar06.jpg',
    'assets/avatar/avatar07.jpg',
    'assets/avatar/avatar08.jpg',
  ];

  late final VideoPlayerController _videoController;
  late final AnimationController _discController;
  late final AnimationController _heartController;
  late final _CaptionPack _captionPack;
  late final String _avatarPath;

  bool _isLiked = false;
  bool _isSaved = false;
  bool _isInitialized = false;
  bool _hasError = false;
  Offset? _heartPosition;

  late int _likeCount;
  late int _commentCount;
  late int _saveCount;
  late int _shareCount;

  @override
  void initState() {
    super.initState();

    final stableSeed = Object.hash(widget.video.id, widget.feedIndex);
    final random = Random(stableSeed);
    _likeCount = 500 + random.nextInt(9501);
    _commentCount = 20 + random.nextInt(981);
    _saveCount = 10 + random.nextInt(491);
    _shareCount = 5 + random.nextInt(296);
    final fallback = _captionPacks[random.nextInt(_captionPacks.length)];
    _captionPack = _CaptionPack(
      widget.video.caption.isEmpty ? fallback.caption : widget.video.caption,
      widget.video.hashtags.isEmpty ? fallback.hashtags : widget.video.hashtagText,
    );
    _avatarPath = _avatars[random.nextInt(_avatars.length)];

    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    );

    _videoController = VideoPlayerController.asset(widget.video.assetPath);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.setVolume(1);
      if (widget.isActive) await _videoController.play();
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (error) {
      debugPrint('Không thể mở video: $error');
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  @override
  void didUpdateWidget(covariant VideoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isInitialized) return;

    if (widget.isActive && !oldWidget.isActive) {
      _videoController.play();
      _discController.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _videoController.pause();
      _discController.stop();
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _playHeartBurst(Offset position) {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _likeCount += 1;
      });
    }

    setState(() => _heartPosition = position);
    _heartController
      ..stop()
      ..reset()
      ..forward();
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
      _saveCount += _isSaved ? 1 : -1;
    });
  }

  void _showOfflineMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 90),
        ),
      );
  }

  void _togglePlayback() {
    if (!_isInitialized) return;
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        _discController.stop();
      } else {
        _videoController.play();
        _discController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _discController.dispose();
    _heartController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlayback,
      onDoubleTapDown: (details) => _playHeartBurst(details.localPosition),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          _buildVideo(),
          _buildShade(),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(child: TopFeedBar()),
          ),
          Positioned(
            left: 14,
            right: 82,
            bottom: 78 + safeBottom,
            child: _buildVideoInfo(),
          ),
          Positioned(
            right: 8,
            bottom: 76 + safeBottom,
            child: _buildActions(),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(child: BottomNavigationOverlay()),
          ),
          _buildHeartBurst(),
          _buildPauseIcon(),
        ],
      ),
    );
  }

  Widget _buildVideo() {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Không mở được ${widget.video.assetPath}\n\nHãy chạy lại QUAN_LY_VIDEO.bat và kiểm tra file video.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final size = _videoController.value.size;
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(_videoController),
        ),
      ),
    );
  }

  Widget _buildShade() {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x52000000), Colors.transparent, Color(0xEE000000)],
            stops: [0, .43, 1],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return IgnorePointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Khánh Linh 💓',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
              SizedBox(width: 5),
              Icon(Icons.verified, color: Color(0xFF20A7F5), size: 16),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            _captionPack.caption,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              height: 1.32,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(color: Colors.black, blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _captionPack.hashtags,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              height: 1.25,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(color: Colors.black, blurRadius: 7)],
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.music_note_rounded, color: Colors.white, size: 17),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Âm thanh gốc - Khánh Linh 💓',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(color: Colors.black, blurRadius: 7)],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAvatar(),
        const SizedBox(height: 15),
        ActionButton(
          icon: Icons.favorite,
          iconColor: _isLiked ? const Color(0xFFFE2C55) : Colors.white,
          count: _likeCount,
          onTap: _toggleLike,
        ),
        const SizedBox(height: 10),
        ActionButton(
          icon: Icons.chat_bubble_rounded,
          count: _commentCount,
          onTap: () => _showOfflineMessage('Bình luận sẽ được thêm sau nhé.'),
        ),
        const SizedBox(height: 10),
        ActionButton(
          icon: Icons.bookmark_rounded,
          iconColor: _isSaved ? const Color(0xFFFFD54F) : Colors.white,
          count: _saveCount,
          onTap: _toggleSave,
        ),
        const SizedBox(height: 10),
        ActionButton(
          icon: Icons.share_rounded,
          count: _shareCount,
          onTap: () => _showOfflineMessage('Chia sẻ sẽ được thêm sau nhé.'),
        ),
        const SizedBox(height: 13),
        _buildMusicDisc(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(2.2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8)],
          ),
          child: CircleAvatar(
            backgroundColor: Colors.black,
            backgroundImage: AssetImage(_avatarPath),
          ),
        ),
        Positioned(
          bottom: -8,
          child: Container(
            width: 21,
            height: 21,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFE2C55),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 17),
          ),
        ),
      ],
    );
  }

  Widget _buildMusicDisc() {
    return RotationTransition(
      turns: _discController,
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color(0xFF707070), Color(0xFF171717), Colors.black],
          ),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
        ),
        child: CircleAvatar(backgroundImage: AssetImage(_avatarPath)),
      ),
    );
  }

  Widget _buildHeartBurst() {
    if (_heartPosition == null) return const SizedBox.shrink();

    const particles = <Offset>[
      Offset(-78, -38),
      Offset(-48, -92),
      Offset(6, -116),
      Offset(58, -86),
      Offset(82, -24),
      Offset(-88, 14),
      Offset(72, 20),
      Offset(-28, -138),
    ];

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _heartController,
        builder: (context, child) {
          final t = Curves.easeOutCubic.transform(_heartController.value);
          final fade = (1 - Curves.easeIn.transform(
            ((_heartController.value - .55) / .45).clamp(0.0, 1.0),
          )).clamp(0.0, 1.0);
          final mainScale = TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween(begin: .25, end: 1.18).chain(
                CurveTween(curve: Curves.easeOutBack),
              ),
              weight: 58,
            ),
            TweenSequenceItem(
              tween: Tween(begin: 1.18, end: .92),
              weight: 42,
            ),
          ]).transform(_heartController.value);

          return Stack(
            children: [
              for (var i = 0; i < particles.length; i++)
                Positioned(
                  left: _heartPosition!.dx - 17 + particles[i].dx * t,
                  top: _heartPosition!.dy - 17 + particles[i].dy * t,
                  child: Opacity(
                    opacity: fade * (.72 + (i % 3) * .12),
                    child: Transform.rotate(
                      angle: (i.isEven ? -1 : 1) * .28 * t,
                      child: Transform.scale(
                        scale: .55 + .35 * (1 - t),
                        child: const Icon(
                          Icons.favorite,
                          color: Color(0xFFFE2C55),
                          size: 34,
                          shadows: [
                            Shadow(color: Colors.black38, blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: _heartPosition!.dx - 62,
                top: _heartPosition!.dy - 62,
                child: Opacity(
                  opacity: fade,
                  child: Transform.scale(
                    scale: mainScale,
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFFFE2C55),
                      size: 124,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPauseIcon() {
    if (!_isInitialized || _videoController.value.isPlaying) {
      return const SizedBox.shrink();
    }
    return const IgnorePointer(
      child: Center(
        child: Icon(Icons.play_arrow_rounded, color: Colors.white70, size: 86),
      ),
    );
  }
}
