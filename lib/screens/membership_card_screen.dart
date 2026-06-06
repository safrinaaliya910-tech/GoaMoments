import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/qr_service.dart';
import '../widgets/luxury_card.dart';
import '../widgets/luxury_glow_background.dart';

class MembershipCardScreen extends StatefulWidget {
  const MembershipCardScreen({super.key});

  @override
  State<MembershipCardScreen> createState() => _MembershipCardScreenState();
}

class _MembershipCardScreenState extends State<MembershipCardScreen> {
  final _qrService = QrService();

  @override
  void initState() {
    super.initState();
    _enableScreenshotProtection();
  }

  @override
  void dispose() {
    _disableScreenshotProtection();
    super.dispose();
  }

  Future<void> _enableScreenshotProtection() async {
    try {
      await ScreenProtector.preventScreenshotOn();
      print('--- GOA MOMENTS SECURITY: Screenshot protection enabled on Membership Card Screen ---');
    } catch (e) {
      print('Screenshot protection enable error: $e');
    }
  }

  Future<void> _disableScreenshotProtection() async {
    try {
      await ScreenProtector.preventScreenshotOff();
      print('--- GOA MOMENTS SECURITY: Screenshot protection disabled ---');
    } catch (e) {
      print('Screenshot protection disable error: $e');
    }
  }

  String _formatPlanTitle(String? planId) {
    if (planId == null) return 'Club Member';
    if (planId.toLowerCase() == 'diamond') return 'Diamond Member';
    if (planId.toLowerCase() == 'platinum') return 'Platinum Member';
    if (planId.toLowerCase() == 'gold') return 'Gold Member';
    return '${planId[0].toUpperCase()}${planId.substring(1)} Member';
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final member = authVM.currentMember;

    if (member == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: Center(
          child: Text(
            'Unauthorized',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
        ),
      );
    }

    final planTitle = _formatPlanTitle(member.planId);
    final activationDateStr = member.activationDate != null
        ? '${member.activationDate!.day}/${member.activationDate!.month}/${member.activationDate!.year}'
        : 'Active';

    // Generate secure QR payload
    final qrData = _qrService.generateMembershipQrData(
      membershipId: member.id,
      memberName: member.name,
      planName: planTitle,
      status: member.status,
      activationDate: activationDateStr,
    );

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
                'VIP DIGITAL PASS',
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  
                  // Decorative Premium physical card simulator
                  MetallicGoldCardDecoration(
                    child: AspectRatio(
                      aspectRatio: 1.6,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'GOA MOMENTS',
                                  style: GoogleFonts.cormorantGaramond(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCF9E2C).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFCF9E2C), width: 0.5),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFF5D06F),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const Spacer(),
                            Text(
                              member.name.toUpperCase(),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.id,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFCF9E2C).withOpacity(0.9),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  planTitle.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  'DATE: $activationDateStr',
                                  style: GoogleFonts.outfit(
                                    color: Colors.grey[500],
                                    fontSize: 9.5,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Glassmorphic QR Container
                  LuxuryCard(
                    borderRadius: 20,
                    hasGlow: true,
                    child: Column(
                      children: [
                        Text(
                          'PARTNER SCAN GATES',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFCF9E2C),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Present this secure QR code to the service provider at partner lounges, hotels, or events for automatic ticket activation checks.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.grey[400],
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        // Secure QR displaying
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 170.0,
                            gapless: false,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Colors.black,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline, color: Color(0xFFCF9E2C), size: 13),
                            const SizedBox(width: 8),
                            Text(
                              'SCREENSHOT PROTECTION ACTIVE',
                              style: GoogleFonts.outfit(
                                color: Colors.grey[550],
                                fontSize: 9.5,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
