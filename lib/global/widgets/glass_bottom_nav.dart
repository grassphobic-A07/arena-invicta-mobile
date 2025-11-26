import 'dart:ui';

import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:flutter/material.dart';

class GlassBottomNavBar extends StatelessWidget {
  const GlassBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: ArenaColor.darkAmethyst.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
