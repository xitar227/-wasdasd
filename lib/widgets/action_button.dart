import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int? count;
  final VoidCallback onTap;
  final double iconSize;

  const ActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.count,
    this.iconColor = Colors.white,
    this.iconSize = 41,
  });

  String _formatCount(int value) {
    if (value < 1000) return value.toString();

    final result = value / 1000;
    return result >= 10
        ? '${result.toStringAsFixed(0)}K'
        : '${result.toStringAsFixed(1)}K';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 52,
            height: 47,
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor,
                shadows: const [
                  Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 1)),
                ],
              ),
            ),
          ),
        ),
        if (count != null)
          Transform.translate(
            offset: const Offset(0, -1),
            child: Text(
              _formatCount(count!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                height: 1,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 7, color: Colors.black)],
              ),
            ),
          ),
      ],
    );
  }
}
