import 'dart:ui';

import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:flutter/material.dart';

class GlassBottomNavBar extends StatelessWidget {
  const GlassBottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onItemTap,
    this.onCenterTap,
  });

  final int activeIndex;
  final ValueChanged<int> onItemTap;
  final VoidCallback? onCenterTap;

  @override
  Widget build(BuildContext context) {
    const double barHeight = 80;
    const double buttonSize = 70;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: barHeight + 20,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: barHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: ArenaColor.darkAmethyst.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NavIcon(
                        icon: Icons.videogame_asset,
                        isActive: activeIndex == 0,
                        onTap: () => onItemTap(0),
                      ),
                      _NavIcon(
                        icon: Icons.chat_bubble_outline,
                        isActive: activeIndex == 1,
                        onTap: () => onItemTap(1),
                      ),
                      const SizedBox(width: 60),
                      _NavIcon(
                        icon: Icons.bar_chart,
                        isActive: activeIndex == 2,
                        onTap: () => onItemTap(2),
                      ),
                      _NavIcon(
                        icon: Icons.person_outline,
                        isActive: activeIndex == 3,
                        onTap: () => onItemTap(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              height: buttonSize,
              width: buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFA855F7),
                    Color(0xFF4F46E5),
                  ],
                ),
                border: Border.all(
                  color: Colors.black,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ArenaColor.purpleX11.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onCenterTap,
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: isActive ? Colors.white : Colors.white54,
      ),
    );
  }
}
