import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // REQUIRED FOR REAL APP LAUNCHING

import '../widgets/gold_button.dart';
import '../widgets/luxury_card.dart';
import '../widgets/luxury_glow_background.dart';
import '../widgets/premium_dialog.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // Official Goa Moments Contact Details
  final String _whatsappNumber = '918807965030'; 
  final String _phoneNumber = '+918807965030';
  final String _emailAddress = 'Goamoments.com@gmail.com';

  void _showLaunchError() {
    showDialog(
      context: context,
      builder: (ctx) => PremiumDialog(
        title: 'CONNECTION FAILED',
        content: 'Unable to open the requested application. Please ensure the app is installed on your device or contact us directly at $_phoneNumber.',
        icon: Icons.error_outline,
        actions: [
          GoldButton(
            label: 'DISMISS',
            height: 44,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  // --- NATIVE LAUNCHER FUNCTIONS ---

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/$_whatsappNumber?text=Hello Goa Moments Concierge, I require bespoke assistance.');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showLaunchError();
    }
  }

  Future<void> _launchPhone() async {
    final Uri url = Uri.parse('tel:$_phoneNumber');
    if (!await launchUrl(url)) {
      _showLaunchError();
    }
  }

  // Helper function to safely encode email subjects and bodies
  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> _launchEmail() async {
    // 🟢 UPDATED: Uses native mailto scheme with externalApplication mode
    // This strictly breaks out of the app and opens the native Gmail/Mail composer.
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: _emailAddress,
      query: _encodeQueryParameters(<String, String>{
        'subject': 'VIP Concierge Request - Goa Moments',
      }),
    );

    try {
      if (!await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication)) {
        _showLaunchError();
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      _showLaunchError();
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
                'VIP CONCIERGE',
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'BESPOKE ASSISTANCE',
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your dedicated luxury concierge team is available 24/7 to manage your bookings, arrange private charters, and fulfill exclusive requests with absolute discretion.',
                    style: GoogleFonts.outfit(
                      color: Colors.grey[450],
                      fontSize: 13.5,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Direct Communication Channels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildContactCircleButton(
                        icon: Icons.chat,
                        label: 'WHATSAPP',
                        onTap: _launchWhatsApp,
                      ),
                      _buildContactCircleButton(
                        icon: Icons.phone_in_talk,
                        label: 'DIRECT CALL',
                        onTap: _launchPhone,
                      ),
                      _buildContactCircleButton(
                        icon: Icons.mail_outline,
                        label: 'EMAIL US',
                        onTap: _launchEmail, // 🟢 Now triggers the updated native email function
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  const Divider(color: Colors.white10),
                  const SizedBox(height: 32),

                  // Enhanced Content
                  Text(
                    'CONCIERGE PRIVILEGES',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  LuxuryCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildServiceItem(
                          icon: Icons.sailing,
                          title: 'Private Yacht Charters',
                          description: 'Sail the Arabian Sea on fully-staffed luxury vessels tailored to your itinerary.',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(color: Colors.white10, height: 1),
                        ),
                        _buildServiceItem(
                          icon: Icons.restaurant,
                          title: 'Bespoke Culinary Journeys',
                          description: 'Priority reservations and private chef experiences at Goa\'s most exclusive dining venues.',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(color: Colors.white10, height: 1),
                        ),
                        _buildServiceItem(
                          icon: Icons.directions_car,
                          title: 'Chauffeur & Transfers',
                          description: 'Seamless airport transfers and dedicated premium vehicles at your disposal.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem({required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFCF9E2C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFCF9E2C), size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.outfit(
                  color: Colors.grey[500],
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCircleButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFFCF9E2C).withOpacity(0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCF9E2C).withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFCF9E2C), size: 28),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}