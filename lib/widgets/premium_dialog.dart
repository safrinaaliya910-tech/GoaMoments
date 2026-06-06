import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final List<Widget> actions;

  const PremiumDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: const Color(0xFFCF9E2C).withOpacity(0.35),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCF9E2C).withOpacity(0.1),
                  blurRadius: 25.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.4),
                      border: Border.all(
                        color: const Color(0xFFCF9E2C).withOpacity(0.4),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFFCF9E2C),
                      size: 28.0,
                    ),
                  ),
                  const SizedBox(height: 18.0),
                ],
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.grey[400],
                    fontSize: 13.0,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: actions.map((action) => Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: action,
                  ))).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
