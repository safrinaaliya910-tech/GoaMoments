import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/benefit_model.dart';
import '../viewmodels/content_viewmodel.dart';
import '../widgets/luxury_glow_background.dart';

class BenefitsScreen extends StatefulWidget {
  final String category;
  final bool isGuestMode;

  const BenefitsScreen({
    super.key,
    this.category = 'ALL',
    this.isGuestMode = false,
  });

  @override
  State<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category.trim().toUpperCase();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContentViewModel>(context, listen: false).loadBenefits(widget.isGuestMode);
    });
  }

  Map<String, List<BenefitModel>> _groupSubcategories(List<BenefitModel> benefits) {
    Map<String, List<BenefitModel>> grouped = {};
    for (var b in benefits) {
      final groupName = (b.subcategory?.isNotEmpty == true) ? b.subcategory! : 'EXCLUSIVE EXPERIENCES';
      grouped.putIfAbsent(groupName, () => []).add(b);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final contentVM = Provider.of<ContentViewModel>(context);

    final Set<String> uniqueCategories = {'ALL'};
    for (var b in contentVM.benefits) {
      uniqueCategories.add(b.category.trim().toUpperCase());
    }
    final categoryList = uniqueCategories.toList();

    final filteredBenefits = (_selectedCategory == 'ALL')
        ? contentVM.benefits
        : contentVM.benefits.where((b) => b.category.trim().toUpperCase() == _selectedCategory).toList();

    final groupedSections = _groupSubcategories(filteredBenefits);

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050505),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFCF9E2C), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("MEMBER BENEFITS",
            style: GoogleFonts.outfit(color: Colors.white, letterSpacing: 3, fontSize: 13, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: LuxuryGlowBackground(
        child: Column(
          children: [
            // --- TOP MENU ---
            Container(
              height: 55,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  final cat = categoryList[index];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cat,
                            style: GoogleFonts.cormorantGaramond(
                              color: isSelected ? const Color(0xFFCF9E2C) : Colors.grey[500],
                              fontSize: isSelected ? 16 : 15,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (isSelected)
                            Container(height: 3, width: 3, decoration: const BoxDecoration(color: Color(0xFFCF9E2C), shape: BoxShape.circle))
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // --- DYNAMIC CONTENT AREA ---
            Expanded(
              child: contentVM.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFCF9E2C)))
                  : filteredBenefits.isEmpty
                      ? Center(child: Text("Curating exclusive experiences soon.", style: GoogleFonts.cormorantGaramond(color: Colors.grey, fontSize: 18, fontStyle: FontStyle.italic)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 16, bottom: 40),
                          itemCount: groupedSections.length,
                          itemBuilder: (context, index) {
                            String sectionTitle = groupedSections.keys.elementAt(index);
                            List<BenefitModel> sectionItems = groupedSections[sectionTitle]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- FIXED SECTION HEADER (No more yellow/black stripes) ---
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(height: 14, width: 2, color: const Color(0xFFCF9E2C)),
                                      const SizedBox(width: 10),
                                      // Wrapped in Expanded to prevent overflow errors
                                      Expanded(
                                        child: Text(
                                          sectionTitle.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.cormorantGaramond(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 2.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                if (_selectedCategory == 'ALL')
                                  SizedBox(
                                    height: 240, 
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      itemCount: sectionItems.length,
                                      itemBuilder: (context, cardIndex) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: EnhancedLuxuryCard(
                                            benefit: sectionItems[cardIndex], 
                                            width: 280, 
                                            height: 224,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Column(
                                      children: sectionItems.map((item) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 16, top: 8),
                                          child: EnhancedLuxuryCard(
                                            benefit: item, 
                                            width: double.infinity, 
                                            height: 220,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- INSTANTLY REACTIVE "ALIVE" CARD ---
class EnhancedLuxuryCard extends StatefulWidget {
  final BenefitModel benefit;
  final double width;
  final double height;

  const EnhancedLuxuryCard({
    super.key, 
    required this.benefit, 
    required this.width, 
    required this.height
  });

  @override
  State<EnhancedLuxuryCard> createState() => _EnhancedLuxuryCardState();
}

class _EnhancedLuxuryCardState extends State<EnhancedLuxuryCard> {
  bool _isActive = false; // Tracks both Hover (Web) and Touch (Mobile)

  @override
  Widget build(BuildContext context) {
    final String tagText = (widget.benefit.subcategory?.isNotEmpty == true) 
        ? widget.benefit.subcategory!.toUpperCase() 
        : widget.benefit.category.trim().toUpperCase();

    // MouseRegion handles Web Hovers, Listener handles Zero-Latency Mobile Touches
    return MouseRegion(
      onEnter: (_) => setState(() => _isActive = true),
      onExit: (_) => setState(() => _isActive = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _isActive = true),
        onPointerUp: (_) => setState(() => _isActive = false),
        onPointerCancel: (_) => setState(() => _isActive = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150), // Made faster to feel instantly "alive"
          curve: Curves.easeOutCubic,
          height: widget.height,
          width: widget.width,
          transform: Matrix4.identity()..scale(_isActive ? 0.96 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF111111),
            border: Border.all(
              color: _isActive ? const Color(0xFFCF9E2C) : const Color(0xFFCF9E2C).withOpacity(0.15),
              width: 1.0,
            ),
            boxShadow: _isActive
                ? [BoxShadow(color: const Color(0xFFCF9E2C).withOpacity(0.25), blurRadius: 20, spreadRadius: 2)]
                : [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 6))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Stack(
              children: [
                // --- IMAGE ---
                if (widget.benefit.imageUrl != null && widget.benefit.imageUrl!.isNotEmpty)
                  Positioned.fill(
                    child: Image.network(
                      widget.benefit.imageUrl!, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF1A1A1A),
                        child: Center(child: Icon(Icons.image_not_supported, color: Colors.white.withOpacity(0.1), size: 30)),
                      ),
                    )
                  ),
                // --- GRADIENT ---
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.95),
                        ],
                        stops: const [0.3, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
                // --- TYPOGRAPHY ---
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 10, height: 1, color: const Color(0xFFCF9E2C)),
                          const SizedBox(width: 6),
                          Text(
                            tagText,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFCF9E2C), 
                              fontSize: 9, 
                              fontWeight: FontWeight.w600, 
                              letterSpacing: 2.0
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.benefit.title,
                        style: GoogleFonts.cormorantGaramond(
                          color: Colors.white, 
                          fontSize: 24, 
                          fontWeight: FontWeight.w600, 
                          height: 1.1
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.benefit.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: Colors.grey[400], 
                          fontSize: 12, 
                          height: 1.4, 
                          fontWeight: FontWeight.w300
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}