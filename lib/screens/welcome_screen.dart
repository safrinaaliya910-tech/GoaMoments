import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../widgets/gold_button.dart';
import '../widgets/luxury_glow_background.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize the background video
    _videoController = VideoPlayerController.asset('assets/videos/goa.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
        _videoController.setVolume(0.0); // Mute background video
        _videoController.setLooping(true); // Loop infinitely
        _videoController.play();
      }).catchError((error) {
        debugPrint("Error loading background video: $error");
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Video (Anchored Right to perfectly frame the walking couple)
          if (_isVideoInitialized)
            FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.centerRight, // <--- Keeps the couple on-screen
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
          else
            Container(color: Colors.black), // Fallback while video loads

          // 2. Cinematic Gradient Overlay
          // Dark at top for text, clear in middle for the couple, dark at bottom for buttons
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.65), // Top: Dark enough for white text
                  Colors.black.withValues(alpha: 0.15), // Middle: Clear for the video/couple
                  Colors.black.withValues(alpha: 0.85), // Bottom-Mid: Darkens behind buttons
                  const Color(0xFF050505),              // Bottom: Solid black
                ],
                stops: const [0.0, 0.45, 0.80, 1.0],
              ),
            ),
          ),

          // 3. Foreground Content
          // Anti-Overflow Architecture for small screens
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2), // Pushes logo down gracefully
                            
                            // Brand Crest Logo
                            Image.asset(
                              'assets/images/goa_moments_logo.png', // Updated exactly as requested
                              height: 90,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const SizedBox(height: 90),
                            ),
                            const SizedBox(height: 24.0),
                            
                            // Main Title
                            Text(
                              'GOA MOMENTS',
                              style: GoogleFonts.cormorantGaramond(
                                color: Colors.white,
                                fontSize: 36.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6.0,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12.0),
                            
                            // Subtitle
                            Text(
                              'THE LUXURY MEMBERSHIP CLUB',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFCF9E2C),
                                fontSize: 11.0,
                                letterSpacing: 4.0,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24.0),
                            
                            // Description Text
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                'Access the finest boutique villas, private yachts, chef-led dining, and elite concierge services on the sun-kissed coast of Goa.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.9), 
                                  fontSize: 14.0,
                                  height: 1.6,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            
                            const Spacer(flex: 5), // Drives buttons to the bottom of the screen

                            // 4. CTA Action Buttons
                            GoldButton(
                              label: 'ACTIVATE MEMBERSHIP',
                              onPressed: () {
                                Navigator.pushNamed(context, '/activate');
                              },
                            ),
                            const SizedBox(height: 16.0),
                            
                            GoldButton(
                              label: 'ALREADY ACTIVATED? SIGN IN',
                              isSecondary: true,
                              onPressed: () {
                                Navigator.pushNamed(context, '/otp-verification'); 
                              },
                            ),
                            const SizedBox(height: 20.0),
                            
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/benefits', arguments: true);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              ),
                              child: Text(
                                'EXPLORE ELITE BENEFITS',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFF5D06F),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.0,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          )
        ],
      ),
    );
  }
}