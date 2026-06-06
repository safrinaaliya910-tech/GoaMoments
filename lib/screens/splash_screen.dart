import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../services/supabase_service.dart';
import '../widgets/luxury_glow_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Only keep the background pulsing luxury glow
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 80,
      end: 220,
    ).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppFlow();
    });
  }

  Future<void> _initializeAppFlow() async {
    final supabaseService = SupabaseService();
    await supabaseService.initialize();

    if (!mounted) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    await authVM.tryAutoLogin(
      supabaseService.isDemoMode,
    );

    // Displays the unified splash screen for exactly 5.5 seconds
    await Future.delayed(
      const Duration(milliseconds: 5500),
    );

    if (!mounted) return;

    if (authVM.isAuthenticated) {
      Navigator.pushReplacementNamed(
        context,
        '/dashboard',
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/welcome',
      );
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  // Logo now appears instantly with the rest of the screen
  Widget buildCenterLogo() {
    return Image.asset(
      'assets/images/goa_moments_logo.png',
      width: 300,
      fit: BoxFit.contain,
    );
  }

  Widget buildLuxuryTexts() {
    return Column(
      children: [
        Text(
          "EXCLUSIVE PRIVILEGE CLUB",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: const Color(0xFFCF9E2C),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 4.5,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: 80,
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Color(0xFFCF9E2C),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "EXPERIENCE GOA LIKE ROYALTY",
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget buildPartnerSection() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 30,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFCF9E2C).withOpacity(0.18),
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF8A6125),
                    Color(0xFFCF9E2C),
                  ],
                ),
              ),
              child: const Icon(
                Icons.verified,
                color: Colors.black,
                size: 18,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "OFFICIAL",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFCF9E2C),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  "TOURISM PARTNER",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              height: 24,
              width: 1,
              color: Colors.white12,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/goa_tourism.png',
                  height: 34,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(
                  "GOA\nTOURISM",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.grey.shade400,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LuxuryGlowBackground(
        glowPositions: const [Alignment.center],
        child: Stack(
          children: [
            // Background pulsing glow
            Positioned.fill(
              child: Center(
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFCF9E2C).withOpacity(0.15),
                            blurRadius: _glowAnimation.value,
                            spreadRadius: 30,
                          ),
                          BoxShadow(
                            color: const Color(0xFFEBC760).withOpacity(0.08),
                            blurRadius: _glowAnimation.value * 1.5,
                            spreadRadius: 50,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Foreground Content (Appears instantly)
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  buildCenterLogo(),
                  const SizedBox(height: 24),
                  buildLuxuryTexts(),
                  const Spacer(flex: 4),
                  buildPartnerSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}