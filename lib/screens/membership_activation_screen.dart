import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/activation_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/gold_button.dart';
import '../widgets/luxury_card.dart';
import '../widgets/luxury_glow_background.dart';
import '../widgets/premium_dialog.dart';

class MembershipActivationScreen extends StatefulWidget {
  const MembershipActivationScreen({super.key});

  @override
  State<MembershipActivationScreen> createState() => _MembershipActivationScreenState();
}

class _MembershipActivationScreenState extends State<MembershipActivationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showLuxuryError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => PremiumDialog(
        title: 'VERIFICATION FAILED',
        content: message,
        icon: Icons.gpp_bad_outlined,
        actions: [
          GoldButton(
            label: 'DISMISS',
            height: 44,
            onPressed: () {
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleVerification() async {
    if (!_formKey.currentState!.validate()) return;

    final activationVM = Provider.of<ActivationViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    // Verify details
    final isValid = await activationVM.verifyMemberDetails(
      membershipId: _idController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      isDemoMode: authVM.isDemoMode,
    );

    if (!isValid) {
      if (mounted) {
        _showLuxuryError(activationVM.errorMessage ?? "Invalid credentials. Membership details not found.");
      }
    } else {
      if (mounted) {
        Navigator.pushNamed(context, '/location-verification');
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
                'MEMBERSHIP ACTIVATION',
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'VERIFY PRIVILEGES',
                      style: GoogleFonts.cormorantGaramond(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enter the credentials associated with your Goa Moments luxury club subscription.',
                      style: GoogleFonts.outfit(
                        color: Colors.grey[450],
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Form Container in Luxury Card
                    LuxuryCard(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _idController,
                            label: 'MEMBERSHIP ID',
                            hint: 'e.g. GM-111-DIAMOND',
                            icon: Icons.card_membership,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                  return 'Membership ID is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildTextField(
                            controller: _emailController,
                            label: 'REGISTERED EMAIL',
                            hint: 'e.g. member@goamoments.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email address is required';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildTextField(
                            controller: _phoneController,
                            label: 'PHONE NUMBER',
                            hint: 'e.g. +919999999999',
                            icon: Icons.phone_android,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Submit Button
                    Consumer<ActivationViewModel>(
                      builder: (context, activationVM, child) {
                        return GoldButton(
                          label: 'VERIFY MEMBERSHIP',
                          isLoading: activationVM.isLoading,
                          onPressed: _handleVerification,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: const Color(0xFFCF9E2C),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
              color: Colors.grey[650],
              fontSize: 13,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFFCF9E2C).withOpacity(0.65), size: 18),
            filled: true,
            fillColor: const Color(0xFF0C0C0C),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[900]!, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCF9E2C), width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}