import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: const Color(0xFFCF9E2C).withOpacity(0.18),
                width: 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16.0),
                highlightColor: const Color(0xFFCF9E2C).withOpacity(0.04),
                splashColor: const Color(0xFFCF9E2C).withOpacity(0.08),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                  child: Row(
                    children: [
                      // Luxury Gold Icon Circle
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFCF9E2C).withOpacity(0.35),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: const Color(0xFFCF9E2C),
                          size: 22.0,
                        ),
                      ),
                      const SizedBox(width: 18.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              subtitle,
                              style: GoogleFonts.outfit(
                                color: Colors.grey[400],
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing ?? const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFCF9E2C),
                        size: 14.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
