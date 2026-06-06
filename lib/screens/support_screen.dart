import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/content_viewmodel.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedContactMethod = 'WhatsApp';

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final contentVM = Provider.of<ContentViewModel>(context, listen: false);

    final memberId = authVM.currentMember?.id ?? 'GUEST';

    final success = await contentVM.submitConciergeTicket(
      memberId: memberId,
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      contactMethod: _selectedContactMethod,
      isDemoMode: authVM.isDemoMode,
    );

    if (mounted) {
      if (success) {
        _subjectController.clear();
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0C0C0C),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.green, width: 1.2),
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              'Ticket submitted. A VIP Concierge will respond shortly.',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0C0C0C),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.redAccent, width: 1.2),
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              'Failed to submit ticket. Please contact support directly.',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
            ),
          ),
        );
      }
    }
  }

  void _simulateContactLaunch(String type, String detail) {
    showDialog(
      context: context,
      builder: (ctx) => PremiumDialog(
        title: 'LAUNCHING CONCIERGE',
        content: 'Opening connection to: $detail',
        icon: type == 'CALL'
            ? Icons.phone_callback
            : (type == 'WHATSAPP' ? Icons.chat : Icons.email_outlined),
        actions: [
          GoldButton(
            label: 'OK',
            height: 40,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentVM = Provider.of<ContentViewModel>(context);

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
                'VIP CONCIERGE SUPPORT',
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
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our dedicated luxury concierge team is available 24/7 to manage your bookings, private charters, and exclusive requests.',
                    style: GoogleFonts.outfit(
                      color: Colors.grey[450],
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Direct Communication Channels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildContactCircleButton(
                        icon: Icons.chat,
                        label: 'WHATSAPP',
                        onTap: () => _simulateContactLaunch('WHATSAPP', '+91 999 999 9999 (WhatsApp)'),
                      ),
                      _buildContactCircleButton(
                        icon: Icons.phone_in_talk,
                        label: 'CALL',
                        onTap: () => _simulateContactLaunch('CALL', '+91 999 999 9999 (Phone)'),
                      ),
                      _buildContactCircleButton(
                        icon: Icons.mail_outline,
                        label: 'EMAIL',
                        onTap: () => _simulateContactLaunch('EMAIL', 'concierge@goamoments.com'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  const Divider(color: Colors.white10),
                  const SizedBox(height: 24),

                  Text(
                    'SUBMIT CONCIERGE TICKET',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ticket Submission Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LuxuryCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('SUBJECT'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _subjectController,
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13.5),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Subject is required' : null,
                                decoration: _buildInputDecoration('e.g. Yacht Charter Booking Request'),
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('MESSAGE DETAILS'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _messageController,
                                maxLines: 4,
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13.5),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Message details required' : null,
                                decoration: _buildInputDecoration('Describe your bespoke request...'),
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('PREFERRED CONTACT METHOD'),
                              const SizedBox(height: 10),
                              Row(
                                children: ['WhatsApp', 'Call', 'Email'].map((method) {
                                  final isSelected = _selectedContactMethod == method;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: ChoiceChip(
                                      label: Text(
                                        method,
                                        style: GoogleFonts.outfit(
                                          color: isSelected ? Colors.black : Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                      selected: isSelected,
                                      selectedColor: const Color(0xFFCF9E2C),
                                      backgroundColor: const Color(0xFF0C0C0C),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: isSelected ? const Color(0xFFCF9E2C) : Colors.grey[900]!,
                                          width: 1,
                                        ),
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            _selectedContactMethod = method;
                                          });
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),

                        GoldButton(
                          label: 'SUBMIT TICKET',
                          isLoading: contentVM.isLoading,
                          onPressed: _submitTicket,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: const Color(0xFFCF9E2C),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(color: Colors.grey[650], fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF0C0C0C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[900]!, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCF9E2C), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
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
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFCF9E2C), size: 26),
              const SizedBox(height: 10),
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
