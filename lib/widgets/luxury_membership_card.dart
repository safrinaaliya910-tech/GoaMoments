import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LuxuryMembershipCard extends StatefulWidget {
  final String membershipId;
  final String memberName;
  final String tier;
  final String activationDate;
  final String status;

  const LuxuryMembershipCard({
    super.key,
    required this.membershipId,
    required this.memberName,
    required this.tier,
    required this.activationDate,
    this.status = 'ACTIVE',
  });

  @override
  State<LuxuryMembershipCard> createState() => _LuxuryMembershipCardState();
}

class _LuxuryMembershipCardState extends State<LuxuryMembershipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAlignment;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    _shimmerAlignment = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDiamond = widget.tier.toLowerCase().contains('diamond');
    final isPlatinum = widget.tier.toLowerCase().contains('platinum');

    // Base card color based on Tier
    final List<Color> cardColors = isDiamond
        ? [const Color(0xFF0F1219), const Color(0xFF1E2430), const Color(0xFF0A0C10)]
        : isPlatinum
            ? [const Color(0xFF191919), const Color(0xFF2C2C2C), const Color(0xFF121212)]
            : [const Color(0xFF0A0A0A), const Color(0xFF1E170A), const Color(0xFF050505)];

    final borderGold = const Color(0xFFCF9E2C);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.0),
            gradient: LinearGradient(
              colors: cardColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: borderGold.withOpacity(0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: borderGold.withOpacity(0.12),
                blurRadius: 30.0,
                spreadRadius: 2.0,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 15.0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.0),
            child: Stack(
              children: [
                // Metallic Shine Overlay Effect
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(_shimmerAlignment.value - 0.5, -1.0),
                        end: Alignment(_shimmerAlignment.value + 0.5, 1.0),
                        colors: [
                          Colors.transparent,
                          borderGold.withOpacity(0.04),
                          Colors.white.withOpacity(0.12),
                          borderGold.withOpacity(0.04),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.42, 0.5, 0.58, 1.0],
                      ),
                    ),
                  ),
                ),

                // Subtle Fine Golden Embossed Patterns
                Positioned(
                  right: -40,
                  top: -40,
                  child: Opacity(
                    opacity: 0.05,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borderGold, width: 2),
                      ),
                    ),
                  ),
                ),

                // Card details padding
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GOA MOMENTS',
                                style: GoogleFonts.cormorantGaramond(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4.0,
                                ),
                              ),
                              Text(
                                'EXCLUSIVE MEMBER',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFF5D06F).withOpacity(0.9),
                                  fontSize: 8.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCF9E2C).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFF5D06F).withOpacity(0.6),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              widget.status.toUpperCase(),
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFF5D06F),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 36.0),

                      // Logo Silhouette Embossed in the Center-Right
                      Align(
                        alignment: Alignment.centerRight,
                        child: Opacity(
                          opacity: 0.15,
                          child: Image.asset(
                            'assets/images/goa_moments_logo.png',
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12.0),

                      // Card number / membership code
                      Text(
                        widget.membershipId.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 19.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.5,
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Bottom Info Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MEMBER',
                                style: GoogleFonts.outfit(
                                  color: Colors.grey[500],
                                  fontSize: 8.0,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.memberName.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'TIER LEVEL',
                                style: GoogleFonts.outfit(
                                  color: Colors.grey[500],
                                  fontSize: 8.0,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.tier.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFCF9E2C),
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
