import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/activation_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/gold_button.dart';
import '../widgets/luxury_card.dart';
import '../widgets/luxury_glow_background.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _codeSent = false;
  String? _selectedMethod;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return "${name[0]}*@$domain";
    return "${name.substring(0, 2)}****${name.substring(name.length - 1)}@$domain";
  }

  String _maskPhone(String phone) {
    if (phone.isEmpty) return phone;
    if (phone.length <= 4) return "****";
    return "${phone.substring(0, 3)}*****${phone.substring(phone.length - 4)}";
  }

  Future<void> _sendCode(String method) async {
    setState(() {
      _selectedMethod = method;
    });

    final activationVM = Provider.of<ActivationViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final member = activationVM.verifiedMember;

    if (member == null) return;

    // 🟢 FIXED: We route ALL activation OTPs (Email and Phone) to the ActivationViewModel
    bool success = await activationVM.triggerOtpCode(
      method: method,
      isDemoMode: authVM.isDemoMode,
    );

    if (success) {
      setState(() {
        _codeSent = true;
      });
      if (authVM.isDemoMode) {
        final otp = "123456";
        for (int i = 0; i < 6; i++) {
          _controllers[i].text = otp[i];
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0C0C0C),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFCF9E2C), width: 1.2),
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              activationVM.errorMessage ?? 'Failed to send OTP code. Please try again.',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
            ),
          ),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    final otpCode = _controllers.map((c) => c.text.trim()).join();
    if (otpCode.length < 6) return;

    final activationVM = Provider.of<ActivationViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final member = activationVM.verifiedMember;

    if (member == null) return;

    // 🟢 FIXED: We route ALL verification (Email and Phone) to the ActivationViewModel
    // This guarantees the database update logic runs before changing screens!
    bool success = await activationVM.verifyOtpAndActivate(
      otpCode: otpCode,
      isDemoMode: authVM.isDemoMode,
    );

    if (success) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/activation-success', (route) => false);
      }
    } else {
      if (mounted) {
        if (activationVM.showDeviceConflictWarning) {
          Navigator.pushReplacementNamed(context, '/device-registration');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF0C0C0C),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.redAccent, width: 1.2),
                borderRadius: BorderRadius.circular(12),
              ),
              content: Text(
                activationVM.errorMessage ?? 'Verification code is incorrect.',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              ),
            ),
          );
          for (var c in _controllers) {
            c.clear();
          }
          _focusNodes[0].requestFocus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activationVM = Provider.of<ActivationViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final member = activationVM.verifiedMember;

    if (member == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: Center(
          child: Text(
            'Activation session expired. Please restart.',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
        ),
      );
    }

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
                'IDENTITY SECURITY',
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'TWO-FACTOR VALIDATION',
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _codeSent
                        ? 'Enter the 6-digit premium passkey sent to your selected credential.'
                        : 'To verify your identity, select where you would like to receive your luxury validation passkey.',
                    style: GoogleFonts.outfit(
                      color: Colors.grey[450],
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  if (!_codeSent) ...[
                    // METHOD SELECTOR VIEW
                    LuxuryCard(
                      child: Column(
                        children: [
                          _buildMethodTile(
                            icon: Icons.email_outlined,
                            title: 'Email Address OTP',
                            subtitle: _maskEmail(member.email),
                            onTap: () => _sendCode('email'),
                          ),
                          
                        ],
                      ),
                    ),
                  ] else ...[
                    // CODE ENTRY VIEW
                    LuxuryCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'PASSKEY SENT TO ${_selectedMethod == 'email' ? 'EMAIL' : 'PHONE'}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFCF9E2C),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedMethod == 'email' ? _maskEmail(member.email) : _maskPhone(member.phone),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // 6 Digits input boxes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: 42,
                                height: 50,
                                child: TextFormField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    fillColor: const Color(0xFF0C0C0C),
                                    filled: true,
                                    contentPadding: EdgeInsets.zero,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey[900]!, width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFCF9E2C), width: 1.2),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    }
                                    if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                    if (value.isNotEmpty && index == 5) {
                                      _focusNodes[index].unfocus();
                                      _verifyOtp();
                                    }
                                  },
                                ),
                              );
                            }),
                          ),
                          
                          if (authVM.isDemoMode) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCF9E2C).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFCF9E2C).withOpacity(0.25),
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                'Demo Code: 123456 (Auto-filled)',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFCF9E2C),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          TextButton(
                            onPressed: authVM.isLoading || activationVM.isLoading ? null : () => _sendCode(_selectedMethod!),
                            child: Text(
                              'RESEND PASSKEY',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFF5D06F),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                fontSize: 11.5,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    GoldButton(
                      label: 'VERIFY & SECURE',
                      isLoading: authVM.isLoading || activationVM.isLoading,
                      onPressed: _controllers.map((c) => c.text).join().length == 6 ? _verifyOtp : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFFCF9E2C).withOpacity(0.04),
        highlightColor: const Color(0xFFCF9E2C).withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                  border: Border.all(color: const Color(0xFFCF9E2C).withOpacity(0.25), width: 1),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        color: Colors.grey[400],
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFCF9E2C), size: 12),
            ],
          ),
        ),
      ),
    );
  }
}