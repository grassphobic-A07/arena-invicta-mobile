import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer( 
          child: _buildGradient(),
        ),
        child,
      ],
    );
  }

  Widget _buildGradient() {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.2,
                colors: [
                  Color(0xFF9333EA),
                  Color(0xFF2A1B54),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.2,
                colors: [
                  Color(0xFF4A49A0),
                  Color(0xFF2A1B54),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

