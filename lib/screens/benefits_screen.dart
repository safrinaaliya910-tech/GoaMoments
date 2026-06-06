import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/content_viewmodel.dart';
import '../models/benefit_model.dart';
import '../widgets/gold_button.dart';
import '../widgets/luxury_card.dart';
import '../widgets/luxury_glow_background.dart';
import '../widgets/premium_dialog.dart';

class BenefitsScreen extends StatefulWidget {
  final bool isGuestMode;

  const BenefitsScreen({super.key, this.isGuestMode = false});

  @override
  State<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = [
    'ALL',
    'HOTELS',
    'RESTAURANTS',
    'NIGHTLIFE',
    'EXPERIENCES',
    'VIP ACCESS'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final contentVM = Provider.of<ContentViewModel>(context, listen: false);
      contentVM.loadBenefits(authVM.isDemoMode);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BenefitModel> _filterBenefits(List<BenefitModel> allBenefits, String category) {
    if (category == 'ALL') return allBenefits;
    return allBenefits.where((b) => b.category.toUpperCase() == category).toList();
  }

  void _onBenefitCardTap(BenefitModel benefit) {
    if (widget.isGuestMode) {
      showDialog(
        context: context,
        builder: (ctx) => PremiumDialog(
          title: 'EXCLUSIVITY GATE',
          content: 'To redeem or activate these premium benefits, you must register and activate your Goa Moments membership.',
          icon: Icons.lock_outline,
          actions: [
            GoldButton(
              label: 'ACTIVATE NOW',
              height: 44,
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          child: LuxuryCard(
            hasGlow: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (benefit.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      benefit.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  benefit.category.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFCF9E2C),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  benefit.title,
                  style: GoogleFonts.cormorantGaramond(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  benefit.description,
                  style: GoogleFonts.outfit(
                    color: Colors.grey[400],
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'CLOSE',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFCF9E2C),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
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
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFCF9E2C)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.isGuestMode ? 'ELITE BENEFITS PREVIEW' : 'MEMBER BENEFITS',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: const Color(0xFFCF9E2C),
                labelColor: const Color(0xFFCF9E2C),
                unselectedLabelColor: Colors.grey[650],
                labelStyle: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
                tabs: _categories.map((c) => Tab(text: c)).toList(),
              ),
            ),
          ],
          body: contentVM.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFCF9E2C)))
              : TabBarView(
                  controller: _tabController,
                  children: _categories.map((cat) {
                    final filtered = _filterBenefits(contentVM.benefits, cat);
                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'No premium services currently listed.',
                          style: GoogleFonts.outfit(color: Colors.grey[600]),
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(20.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // Single-column for extreme detail & high-end visual size
                        childAspectRatio: 1.35,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final benefit = filtered[index];
                        return _buildBenefitCard(benefit);
                      },
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard(BenefitModel benefit) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFCF9E2C).withOpacity(0.25),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            // Image Backdrop
            if (benefit.imageUrl != null)
              Positioned.fill(
                child: Image.network(
                  benefit.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            
            // Bottom Gradient & Glass Info Box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.45, 0.9],
                  ),
                ),
              ),
            ),

            // Benefit details and button
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFFCF9E2C).withOpacity(0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      benefit.category.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFCF9E2C),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    benefit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    benefit.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.grey[350],
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Top right Lock overlay (if in guest mode)
            if (widget.isGuestMode)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.7),
                    border: Border.all(
                      color: const Color(0xFFCF9E2C).withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFCF9E2C),
                    size: 16,
                  ),
                ),
              ),

            // Click Overlay InkWell
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onBenefitCardTap(benefit),
                  splashColor: const Color(0xFFCF9E2C).withOpacity(0.08),
                  highlightColor: const Color(0xFFCF9E2C).withOpacity(0.04),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
