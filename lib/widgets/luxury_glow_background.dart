import 'package:flutter/material.dart';

class LuxuryGlowBackground extends StatelessWidget {
  final Widget child;
  final List<Alignment> glowPositions;

  const LuxuryGlowBackground({
    super.key,
    required this.child,
    this.glowPositions = const [
      Alignment.topRight,
      Alignment.bottomLeft,
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Obsidian Black Base Background
        Container(
          color: const Color(0xFF050505),
        ),
        
        // Ambient Gold Glows
        ...glowPositions.map((alignment) {
          final isTop = alignment.y < 0;
          return Align(
            alignment: alignment,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8A6125).withOpacity(isTop ? 0.08 : 0.05),
                    const Color(0xFFCF9E2C).withOpacity(0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          );
        }),
        
        // Content Layer
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
