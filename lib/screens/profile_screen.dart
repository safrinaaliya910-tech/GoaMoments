import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/gold_button.dart';
import '../widgets/luxury_card.dart';
import '../widgets/luxury_glow_background.dart';
import '../widgets/premium_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final member = authVM.currentMember;

    _nameController = TextEditingController(text: member?.name ?? '');
    _emailController = TextEditingController(text: member?.email ?? '');
    _phoneController = TextEditingController(text: member?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (mounted) {
      if (success) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0C0C0C),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.green, width: 1.2),
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              'Profile updated successfully.',
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
              'Failed to update profile.',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
            ),
          ),
        );
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => PremiumDialog(
        title: 'LOG OUT',
        content: 'Are you sure you want to end your luxury membership session?',
        icon: Icons.logout,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.outfit(
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GoldButton(
            label: 'LOG OUT',
            height: 40,
            onPressed: () async {
              Navigator.pop(ctx);
              final authVM = Provider.of<AuthViewModel>(context, listen: false);
              await authVM.clearSession();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
              }
            },
          ),
        ],
      ),
    );
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
                'MEMBER PROFILE',
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
                    
                    // VIP Profile Banner
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0C0C0C),
                              border: Border.all(
                                color: const Color(0xFFCF9E2C),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFCF9E2C).withOpacity(0.12),
                                  blurRadius: 24,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.workspace_premium,
                              color: Color(0xFFCF9E2C),
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            member.name.toUpperCase(),
                            style: GoogleFonts.cormorantGaramond(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            planTitle.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFCF9E2C),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Member Details Form Card
                    LuxuryCard(
                      child: Column(
                        children: [
                          _buildProfileField(
                            label: 'MEMBERSHIP ID',
                            controller: TextEditingController(text: member.id),
                            enabled: false,
                          ),
                          const Divider(color: Colors.white10, height: 24),
                          
                          _buildProfileField(
                            label: 'MEMBER NAME',
                            controller: _nameController,
                            enabled: _isEditing,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                          ),
                          const Divider(color: Colors.white10, height: 24),

                          _buildProfileField(
                            label: 'EMAIL ADDRESS',
                            controller: _emailController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Email is required' : null,
                          ),
                          const Divider(color: Colors.white10, height: 24),

                          _buildProfileField(
                            label: 'PHONE NUMBER',
                            controller: _phoneController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Phone is required' : null,
                          ),
                          const Divider(color: Colors.white10, height: 24),

                          _buildProfileField(
                            label: 'ACTIVATION DATE',
                            controller: TextEditingController(text: activationDateStr),
                            enabled: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Save or Edit CTA Buttons
                    if (_isEditing) ...[
                      GoldButton(
                        label: 'SAVE CHANGES',
                        isLoading: authVM.isLoading,
                        onPressed: _handleSave,
                      ),
                      const SizedBox(height: 16),
                      GoldButton(
                        label: 'CANCEL',
                        isSecondary: true,
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _nameController.text = member.name;
                            _emailController.text = member.email;
                            _phoneController.text = member.phone;
                          });
                        },
                      ),
                    ] else ...[
                      GoldButton(
                        label: 'EDIT PROFILE',
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      GoldButton(
                        label: 'SECURE LOG OUT',
                        isSecondary: true,
                        onPressed: _confirmLogout,
                      ),
                    ],
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

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: const Color(0xFFCF9E2C),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: enabled
              ? TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    fillColor: const Color(0xFF0C0C0C),
                    filled: true,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFCF9E2C), width: 1.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white12, width: 1.0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                )
              : Text(
                  controller.text,
                  style: GoogleFonts.outfit(
                    color: Colors.grey[400],
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
