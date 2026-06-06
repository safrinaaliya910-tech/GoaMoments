import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/activation_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/gold_button.dart';
import '../widgets/luxury_card.dart';
import '../widgets/luxury_glow_background.dart';

class DeviceRegistrationScreen extends StatefulWidget {
  const DeviceRegistrationScreen({super.key});

  @override
  State<DeviceRegistrationScreen> createState() => _DeviceRegistrationScreenState();
}

class _DeviceRegistrationScreenState extends State<DeviceRegistrationScreen> {
  bool _isResetRequested = false;
  bool _submittingRequest = false;

  Future<void> _requestDeviceReset(String membershipId) async {
    setState(() {
      _submittingRequest = true;
    });

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final activationVM = Provider.of<ActivationViewModel>(context, listen: false);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _submittingRequest = false;
      _isResetRequested = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activationVM = Provider.of<ActivationViewModel>(context);
    final member = activationVM.verifiedMember;

    if (member == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: Center(
          child: Text(
            'Session expired. Please restart.',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: LuxuryGlowBackground(
        glowPositions: const [Alignment.center],
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFCF9E2C)),
                onPressed: () {
                  activationVM.resetActivationState();
                  Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                },
              ),
              title: Text(
                'SECURITY COMPLIANCE',
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Warning Security Shield Emblem
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0C0C0C),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.8),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.12),
                        blurRadius: 32,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.gpp_bad_outlined,
                    color: Colors.redAccent,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'SECURITY ALERT',
                  style: GoogleFonts.cormorantGaramond(
                    color: Colors.redAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'DUPLICATE DEVICE REGISTRATION DETECTED',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Details explanation card
                LuxuryCard(
                  borderRadius: 16,
                  child: Column(
                    children: [
                      Text(
                        'Dear ${member.name},',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'To protect the integrity of the Goa Moments club, membership terms enforce a strict "One Membership = One Active Device" rule. Your subscription is currently bound to another active mobile device.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.grey[400],
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Membership ID:',
                            style: GoogleFonts.outfit(color: const Color(0xFFCF9E2C), fontSize: 12.5),
                          ),
                          Text(
                            member.id,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Actions panel
                if (_isResetRequested)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green.withOpacity(0.08),
                      border: Border.all(color: Colors.green.withOpacity(0.25), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Device reset request submitted. Concierge will verify and notify you shortly.',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GoldButton(
                    label: 'REQUEST DEVICE RESET',
                    isLoading: _submittingRequest,
                    onPressed: () => _requestDeviceReset(member.id),
                  ),
                const SizedBox(height: 16),
                
                GoldButton(
                  label: 'CONTACT VIP CONCIERGE',
                  isSecondary: true,
                  onPressed: () {
                    Navigator.pushNamed(context, '/support');
                  },
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
