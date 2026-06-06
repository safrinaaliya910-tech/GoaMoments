import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class GoldButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double width;
  final double height;
  final bool isSecondary;

  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 54.0,
    this.isSecondary = false,
  });

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    final primaryGradient = const LinearGradient(
      colors: [
        Color(0xFFCF9E2C), // Metallic gold
        Color(0xFFEBC760), // Champagne/soft gold
        Color(0xFFB4831B), // Shadow gold
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: isDisabled ? null : widget.onPressed,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            gradient: widget.isSecondary || isDisabled ? null : primaryGradient,
            color: isDisabled
                ? Colors.grey[900]
                : (widget.isSecondary ? Colors.transparent : null),
            border: widget.isSecondary && !isDisabled
                ? Border.all(color: const Color(0xFFCF9E2C), width: 1.5)
                : null,
            boxShadow: !isDisabled && !widget.isSecondary
                ? [
                    BoxShadow(
                      color: const Color(0xFFCF9E2C).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.black54,
                    highlightColor: const Color(0xFFFFFFFF),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : Text(
                    widget.label.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: isDisabled
                          ? Colors.grey[600]
                          : (widget.isSecondary ? const Color(0xFFCF9E2C) : Colors.black),
                      fontWeight: FontWeight.w800,
                      fontSize: 14.0,
                      letterSpacing: 2.0,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
