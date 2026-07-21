import 'package:flutter/material.dart';

class BottomNavigationOverlay extends StatelessWidget {
  const BottomNavigationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 66 + bottomPadding,
      padding: EdgeInsets.only(top: 5, bottom: bottomPadding),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0xE6000000), Colors.black],
          stops: [0, .38, 1],
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(icon: Icons.home_filled, label: 'Trang chủ', selected: true),
          _BottomItem(icon: Icons.people_outline_rounded, label: 'Bạn bè'),
          _CreateButton(),
          _BottomItem(icon: Icons.mail_outline_rounded, label: 'Hộp thư'),
          _BottomItem(icon: Icons.person_outline_rounded, label: 'Hồ sơ'),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({required this.icon, required this.label, this.selected = false});

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.white.withValues(alpha: .72);
    return SizedBox(
      width: 64,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: const Offset(-4, 0),
              child: Container(
                width: 39,
                height: 27,
                decoration: BoxDecoration(
                  color: const Color(0xFF25F4EE),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(4, 0),
              child: Container(
                width: 39,
                height: 27,
                decoration: BoxDecoration(
                  color: const Color(0xFFFE2C55),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Container(
              width: 39,
              height: 27,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 23),
            ),
          ],
        ),
      ),
    );
  }
}
