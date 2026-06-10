import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/activation_viewmodel.dart';
import '../widgets/gold_button.dart';
import '../widgets/luxury_card.dart';
import '../widgets/luxury_glow_background.dart';

class GoaLocationVerificationScreen extends StatefulWidget {
  const GoaLocationVerificationScreen({super.key});

  @override
  State<GoaLocationVerificationScreen> createState() => _GoaLocationVerificationScreenState();
}

class _GoaLocationVerificationScreenState extends State<GoaLocationVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isChecking = false;
  bool _checked = false;
  bool _passed = false;
  
  // Local state for the Simulator Toggle
  bool _useSimulator = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkLocation() async {
    setState(() {
      _isChecking = true;
      _checked = false;
    });

    final activationVM = Provider.of<ActivationViewModel>(context, listen: false);

    // Call the logic using the local Simulator toggle state
    final success = await activationVM.verifyGoaLocation(isDemoMode: _useSimulator);

    if (mounted) {
      setState(() {
        _isChecking = false;
        _checked = true;
        _passed = success;
      });

      if (success) {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pushNamed(context, '/otp-verification');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LuxuryGlowBackground(
        glowPositions: const [Alignment.topRight, Alignment.bottomLeft],
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFCF9E2C)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'LOCATION VERIFICATION',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              centerTitle: true,
            ),
          ],
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  'LOCATION BOUNDARY CHECK',
                  style: GoogleFonts.cormorantGaramond(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Membership benefits can only be activated while you are physically present inside Goa.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.grey[450], fontSize: 13.5),
                ),
                const Spacer(),

                // Radar UI
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isChecking)
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) => Container(
                          width: 200 * _pulseAnimation.value,
                          height: 200 * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFCF9E2C).withOpacity(1.0 - _pulseAnimation.value),
                            ),
                          ),
                        ),
                      ),
                    Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0C0C0C),
                        border: Border.all(
                          color: _checked ? (_passed ? Colors.green : Colors.redAccent) : const Color(0xFFCF9E2C),
                        ),
                      ),
                      child: Center(
                        child: _isChecking
                            ? const CircularProgressIndicator(color: Color(0xFFCF9E2C))
                            : Icon(
                                _checked ? (_passed ? Icons.verified : Icons.gpp_maybe) : Icons.location_on,
                                color: _checked ? (_passed ? Colors.green : Colors.redAccent) : const Color(0xFFCF9E2C),
                                size: 44,
                              ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Status Message
                if (_checked)
                  LuxuryCard(
                    child: Text(
                      _passed ? 'VERIFICATION SUCCESSFUL' : 'LOCATION GATE BLOCKED',
                      style: GoogleFonts.outfit(color: _passed ? Colors.green : Colors.redAccent),
                    ),
                  ),

                // Simulator Switch
                const SizedBox(height: 20),
                LuxuryCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Simulate Inside Goa:', style: GoogleFonts.outfit(color: Colors.grey[400])),
                      Switch(
                        value: _useSimulator,
                        activeColor: const Color(0xFFCF9E2C),
                        onChanged: (val) {
                          setState(() {
                            _useSimulator = val;
                            _checked = false; // Reset the UI if they toggle the switch
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                if (!_isChecking && !_passed)
                  GoldButton(label: 'CHECK GPS LOCATION', onPressed: _checkLocation),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}