import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/gold_button.dart';
import '../widgets/luxury_card.dart';
import '../widgets/luxury_glow_background.dart';

class ActivationSuccessScreen extends StatefulWidget {
  const ActivationSuccessScreen({super.key});

  @override
  State<ActivationSuccessScreen> createState() => _ActivationSuccessScreenState();
}

class _ActivationSuccessScreenState extends State<ActivationSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _checkController.forward();
    
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final memberName = authVM.currentMember?.name ?? 'Valued Member';

    return Scaffold(
      body: LuxuryGlowBackground(
        glowPositions: const [Alignment.center],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Animated Gold checkmark
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0C0C0C),
                      border: Border.all(
                        color: const Color(0xFFCF9E2C),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCF9E2C).withOpacity(0.25),
                          blurRadius: 36,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        color: Color(0xFFCF9E2C),
                        size: 56,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  'MEMBERSHIP ACTIVATED',
                  style: GoogleFonts.cormorantGaramond(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'SUCCESSFULLY',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFCF9E2C),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 32),

                LuxuryCard(
                  borderRadius: 16,
                  child: Column(
                    children: [
                      Text(
                        'Welcome, $memberName',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your Goa Moments luxury membership is now fully active. Enjoy bespoke experiences, private charters, and priority concierge access.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.grey[400],
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Bottom loader indicator
                Text(
                  'Entering Goa Moments portal...',
                  style: GoogleFonts.outfit(
                    color: Colors.grey[600],
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 48,
                  height: 2,
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCF9E2C)),
                    backgroundColor: Colors.white10,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
