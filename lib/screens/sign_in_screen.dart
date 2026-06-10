import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../models/member_model.dart';
import '../widgets/gold_button.dart';
import '../widgets/luxury_card.dart';
import '../widgets/luxury_glow_background.dart';
import '../widgets/premium_dialog.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isVerifyingEmail = false;
  bool _isOtpSent = false;
  MemberModel? _foundMember;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showLuxuryError(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => PremiumDialog(
        title: title,
        content: message,
        icon: Icons.gpp_bad_outlined,
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

  Future<void> _handleEmailSubmit() async {
    final email = _emailController.text.trim().toLowerCase(); // FIXED: Force lowercase
    if (email.isEmpty || !email.contains('@')) {
      _showLuxuryError('INVALID ENTRY', 'Please enter a valid registered email address.');
      return;
    }

    setState(() => _isVerifyingEmail = true);

    try {
      // FIXED: Using limit(1) prevents the app from crashing if there are duplicate test accounts
      final response = await Supabase.instance.client
          .from('memberships')
          .select()
          .eq('email', email)
          .limit(1);

      if (response.isEmpty) {
        setState(() => _isVerifyingEmail = false);
        _showLuxuryError('ACCESS DENIED', 'This email is not associated with any Goa Moments membership. Please check for typos or return to activation.');
        return;
      }

      _foundMember = MemberModel.fromJson(response.first);

      if (_foundMember!.status != 'active') {
        setState(() => _isVerifyingEmail = false);
        _showLuxuryError('MEMBERSHIP PENDING', 'This membership has not been fully activated yet. Please return to the Activation screen to complete your setup.');
        return;
      }

      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final success = await authVM.sendEmailOTP(email);

      if (success && mounted) {
        setState(() {
          _isOtpSent = true;
          _isVerifyingEmail = false;
        });
      } else {
        setState(() => _isVerifyingEmail = false);
        _showLuxuryError('DELIVERY FAILED', 'Failed to send the secure passkey. You may have requested too many codes recently.');
      }

    } catch (e) {
      debugPrint("Sign In Catch Error: $e");
      setState(() => _isVerifyingEmail = false);
      _showLuxuryError('SYSTEM ERROR', 'Unable to connect to the secure server. Please check your internet connection.');
    }
  }

  Future<void> _handleOtpSubmit() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    
    final success = await authVM.verifyEmailOTP(
      _emailController.text.trim().toLowerCase(), 
      otp, 
      _foundMember!
    );

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
    } else if (mounted) {
      _showLuxuryError('VERIFICATION FAILED', 'The passkey entered is incorrect or has expired. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

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
                'MEMBER SIGN IN',
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
                    _isOtpSent ? 'ENTER SECURE PASSKEY' : 'WELCOME BACK',
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isOtpSent 
                      ? 'A 6-digit access code has been sent to ${_emailController.text}'
                      : 'Please enter your registered email address to receive your secure access passkey.',
                    style: GoogleFonts.outfit(
                      color: Colors.grey[450],
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  LuxuryCard(
                    child: Column(
                      children: [
                        if (!_isOtpSent) ...[
                          _buildTextField(
                            controller: _emailController,
                            label: 'REGISTERED EMAIL',
                            hint: 'e.g. member@goamoments.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ] else ...[
                          _buildTextField(
                            controller: _otpController,
                            label: '6-DIGIT PASSKEY',
                            hint: '• • • • • •',
                            icon: Icons.lock_outline,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (!_isOtpSent)
                    GoldButton(
                      label: 'SEND SECURE PASSKEY',
                      isLoading: _isVerifyingEmail,
                      onPressed: _handleEmailSubmit,
                    )
                  else
                    GoldButton(
                      label: 'VERIFY & ENTER',
                      isLoading: authVM.isLoading,
                      onPressed: _handleOtpSubmit,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
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
          maxLength: maxLength,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            letterSpacing: maxLength != null ? 8.0 : 1.0,
          ),
          decoration: InputDecoration(
            counterText: "",
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: Colors.grey[650], fontSize: 13, letterSpacing: 1.0),
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
          ),
        ),
      ],
    );
  }
}