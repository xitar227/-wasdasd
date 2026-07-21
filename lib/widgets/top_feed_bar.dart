import 'package:flutter/material.dart';

/// Thanh điều hướng trên cùng của màn hình video.
///
/// Bố cục được giữ cố định theo ba vùng để không còn hiện tượng biểu tượng
/// LIVE bị lệch hoặc các nhãn bị co nhỏ bất thường:
/// LIVE badge | các tab ở giữa | tìm kiếm.
class TopFeedBar extends StatelessWidget {
  const TopFeedBar({super.key});

  static const _shadow = <Shadow>[
    Shadow(
      color: Color(0xCC000000),
      blurRadius: 7,
      offset: Offset(0, 1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 410;
          final tabFontSize = compact ? 14.4 : 17.2;
          final sideWidth = compact ? 43.0 : 50.0;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 7 : 11,
              compact ? 7 : 10,
              compact ? 7 : 10,
              0,
            ),
            child: SizedBox(
              height: compact ? 47 : 52,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: sideWidth,
                    height: 44,
                    child: const _LiveBadge(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 2 : 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _FeedTab(
                            label: 'LIVE',
                            fontSize: tabFontSize,
                          ),
                          _FeedTab(
                            label: 'Nghệ An',
                            fontSize: tabFontSize,
                          ),
                          _FeedTab(
                            label: 'Bạn bè',
                            fontSize: tabFontSize,
                            showDot: true,
                          ),
                          _FeedTab(
                            label: 'Đã follow',
                            fontSize: tabFontSize,
                          ),
                          _FeedTab(
                            label: 'Đề xuất',
                            fontSize: tabFontSize,
                            selected: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: sideWidth,
                    height: 44,
                    child: const Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 35,
                          shadows: _shadow,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Biểu tượng TV LIVE tự vẽ để kích thước và vị trí luôn cân đối trên mọi máy.
class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 42,
        height: 41,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 7,
              left: 4,
              right: 4,
              bottom: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2.4),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 5),
                  ],
                ),
              ),
            ),
            const Positioned(
              top: 0,
              left: 11,
              child: _Antenna(angle: -0.58),
            ),
            const Positioned(
              top: 0,
              right: 11,
              child: _Antenna(angle: 0.58),
            ),
            const Positioned(
              top: 15,
              child: Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.3,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -0.45,
                  shadows: TopFeedBar._shadow,
                ),
              ),
            ),
            Positioned(
              bottom: 1,
              left: 9,
              right: 9,
              child: Container(
                height: 2.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Antenna extends StatelessWidget {
  const _Antenna({required this.angle});

  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 2.2,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(99),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 3)],
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.label,
    required this.fontSize,
    this.selected = false,
    this.showDot = false,
  });

  final String label;
  final double fontSize;
  final bool selected;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 28,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: .91),
                    // Không gán font serif: Flutter sẽ dùng font hệ thống Roboto,
                    // đồng bộ với chữ Khánh Linh trong phần caption.
                    fontSize: fontSize,
                    fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w700,
                    letterSpacing: -0.48,
                    height: 1.05,
                    shadows: TopFeedBar._shadow,
                  ),
                ),
                if (showDot)
                  Positioned(
                    top: -1,
                    right: -7,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFE2C55),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black38, blurRadius: 3),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 39 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
