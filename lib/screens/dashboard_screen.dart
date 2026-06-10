import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/activation_viewmodel.dart'; // 🟢 ADDED IMPORT
import '../viewmodels/content_viewmodel.dart';
import '../widgets/luxury_card.dart';
import '../widgets/dashboard_tile.dart';
import '../widgets/luxury_glow_background.dart';
import '../widgets/luxury_membership_card.dart';
import '../widgets/luxury_section_header.dart';
import '../widgets/luxury_stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final activationVM = Provider.of<ActivationViewModel>(context, listen: false);
      final contentVM = Provider.of<ContentViewModel>(context, listen: false);

      // 🟢 THE BATON PASS: Sync the newly activated user into the persistent auth session
      if (authVM.currentMember == null && activationVM.verifiedMember != null) {
        debugPrint("🟢 HANDOFF: Saving activated user to persistent session.");
        await authVM.setSession(activationVM.verifiedMember!);
      } else if (authVM.currentMember == null) {
        debugPrint("🟢 HANDOFF: Attempting auto-login from secure storage.");
        await authVM.tryAutoLogin(authVM.isDemoMode);
      }

      contentVM.loadBenefits(authVM.isDemoMode);
    });
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
      return const Scaffold(
        backgroundColor: Color(0xFF050505),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFCF9E2C))),
      );
    }

    final planTitle = _formatPlanTitle(member.planId);
    final activationDateStr = member.activationDate != null
        ? '${member.activationDate!.day}/${member.activationDate!.month}/${member.activationDate!.year}'
        : 'Active';

    return Scaffold(
      body: LuxuryGlowBackground(
        glowPositions: const [Alignment.topRight, Alignment.bottomLeft],
        child: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFFCF9E2C),
            backgroundColor: const Color(0xFF0C0C0C),
            onRefresh: () async {
              final contentVM = Provider.of<ContentViewModel>(context, listen: false);
              await authVM.refreshProfile();
              await contentVM.loadBenefits(authVM.isDemoMode);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section with Welcome Greeting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WELCOME BACK,',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFCF9E2C).withOpacity(0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.name.toUpperCase(),
                              style: GoogleFonts.cormorantGaramond(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        
                        // Custom profile crest button
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0C0C0C),
                              border: Border.all(
                                color: const Color(0xFFCF9E2C).withOpacity(0.35),
                                width: 1.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: Color(0xFFCF9E2C),
                              size: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Shimmering Luxury Membership Card
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/membership-card'),
                      child: LuxuryMembershipCard(
                        membershipId: member.id,
                        memberName: member.name,
                        tier: planTitle,
                        activationDate: activationDateStr,
                        status: member.status,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick member stats row
                    Row(
                      children: [
                        Expanded(
                          child: LuxuryStatCard(
                            value: planTitle.replaceAll(' Member', '').toUpperCase(),
                            label: 'Tier Level',
                            icon: Icons.workspace_premium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LuxuryStatCard(
                            value: 'ACTIVE',
                            label: 'Status',
                            icon: Icons.offline_pin,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LuxuryStatCard(
                            value: member.id.split('-').last,
                            label: 'ID Ref',
                            icon: Icons.fingerprint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // Exclusive services header
                    const LuxurySectionHeader(
                      title: 'EXCLUSIVE SERVICES',
                      subtitle: 'PREMIUM PRIVILEGES',
                    ),
                    const SizedBox(height: 12),
                    
                    DashboardTile(
                      icon: Icons.qr_code_2,
                      title: 'Digital Concierge Pass',
                      subtitle: 'Present this QR for validation at partners',
                      onTap: () {
                        Navigator.pushNamed(context, '/membership-card');
                      },
                    ),

                    DashboardTile(
                      icon: Icons.hotel_outlined,
                      title: 'Elite Club Benefits',
                      subtitle: 'Explore hotels, yachts, and dining reserves',
                      onTap: () {
                        Navigator.pushNamed(context, '/benefits', arguments: false);
                      },
                    ),

                    DashboardTile(
                      icon: Icons.support_agent,
                      title: 'VIP Concierge Desk',
                      subtitle: 'Instant WhatsApp, call, or email support',
                      onTap: () {
                        Navigator.pushNamed(context, '/support');
                      },
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}