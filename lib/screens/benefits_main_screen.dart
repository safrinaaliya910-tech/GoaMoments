import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'benefits_screen.dart';

class BenefitsMainScreen extends StatelessWidget {
  final List<String> categories = ['HOTELS', 'RESORTS', 'RESTAURANTS', 'CAFES', 'NIGHTLIFE', 'WATER ACTIVITIES', 'TRANSPORT', 'BEACHES'];

  BenefitsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text('ELITE DIRECTORY', style: GoogleFonts.outfit(color: const Color(0xFFCF9E2C), letterSpacing: 2))),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.2),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return InkWell(
           onTap: () {
  Navigator.pushNamed(
    context, 
    '/benefits', 
    // This creates the envelope with the two notes inside
    arguments: {
      'category': categories[index], 
      'isGuestMode': false
    }
  );
},
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                border: Border.all(color: const Color(0xFFCF9E2C)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(categories[index], style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          );
        },
      ),
    );
  }
}