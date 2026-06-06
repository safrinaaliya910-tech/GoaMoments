import 'dart:ui';
import 'package:flutter/material.dart';

class LuxuryCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final bool hasGlow;
  final double borderRadius;
  final double borderOpacity;

  const LuxuryCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.hasGlow = false,
    this.borderRadius = 16.0,
    this.borderOpacity = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: const Color(0xFFCF9E2C).withOpacity(0.12),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.60),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                width: 1.0,
                color: const Color(0xFFCF9E2C).withOpacity(borderOpacity),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A double-border metallic gold card decoration (e.g. for membership card display)
class MetallicGoldCardDecoration extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const MetallicGoldCardDecoration({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0F0F),
            Color(0xFF020202),
            Color(0xFF161616),
            Color(0xFF020202),
          ],
        ),
        border: Border.all(
          width: 1.2,
          color: const Color(0xFFCF9E2C).withOpacity(0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCF9E2C).withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0), // Outer golden track spacing
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius - 4),
            border: Border.all(
              width: 0.8,
              color: const Color(0xFFF5D06F).withOpacity(0.25),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
